//
//  MozjpegBinding.m
//  PDFScanner
//
//  Created by Radzivon Bartoshyk on 3.09.21.
//

#import <Foundation/Foundation.h>
#import "MozjpegBinding.h"
#import "jpeglib.h"
#import "turbojpeg.h"

/*
 * Here's the routine that will replace the standard error_exit method:
 */

struct my_error_mgr {
    struct jpeg_error_mgr pub;    /* "public" fields */
    
    jmp_buf setjmp_buffer;    /* for return to caller */
};

typedef struct my_error_mgr * my_error_ptr;

METHODDEF(void)
my_error_exit (j_common_ptr cinfo)
{
    /* cinfo->err really points to a my_error_mgr struct, so coerce pointer */
    my_error_ptr myerr = (my_error_ptr) cinfo->err;
    
    /* Always display the message. */
    /* We could postpone this until after returning, if we chose. */
    (*cinfo->err->output_message) (cinfo);
    
    /* Return control to the setjmp point */
    longjmp(myerr->setjmp_buffer, 1);
}

uint8_t * createRGB8Buffer(MozjpegImage * _Nonnull sourceImage) {
    int width = (int)(sourceImage.size.width * sourceImage.scale);
    int height = (int)(sourceImage.size.height * sourceImage.scale);
    int targetBytesPerRow = ((4 * (int)width) + 31) & (~31);
    uint8_t *targetMemory = malloc((int)(targetBytesPerRow * height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, width, height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    
    UIGraphicsPushContext(targetContext);
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(targetContext, CGRectMake(0, 0, width, height), sourceImage.CGImage);
    
    UIGraphicsPopContext();
    
    int bufferBytesPerRow = ((3 * (int)width) + 31) & (~31);
    uint8_t *buffer = malloc(bufferBytesPerRow * height);
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            uint32_t *color = ((uint32_t *)&targetMemory[y * targetBytesPerRow + x * 4]);
            
            uint32_t r = ((*color >> 16) & 0xff);
            uint32_t g = ((*color >> 8) & 0xff);
            uint32_t b = (*color & 0xff);
            
            buffer[y * bufferBytesPerRow + x * 3 + 0] = r;
            buffer[y * bufferBytesPerRow + x * 3 + 1] = g;
            buffer[y * bufferBytesPerRow + x * 3 + 2] = b;
        }
    }
    
    CGContextRelease(targetContext);
    
    free(targetMemory);
    
    return buffer;
}

@implementation JPEGCompression {
    struct jpeg_compress_struct cinfo;
    struct my_error_mgr jerr;
    unsigned int width;
    uint8_t *outBuffer;
    unsigned long outSize;
    bool compressStarted;
}

- (void)dealloc {
    if (compressStarted) {
        [self finishCompress];
    }
}

- (id)init
{
    self = [super init];
    compressStarted = false;
    outSize = 0;
    outBuffer = nil;
    return self;
}


- (NSData * _Nonnull)finishCompress {
    jpeg_finish_compress(&cinfo);
    NSData *result = [[NSData alloc] initWithBytes:outBuffer length:outSize];
    jpeg_destroy_compress(&cinfo);
    compressStarted = false;
    if (outBuffer != NULL) {
        free(outBuffer);
    }
    outBuffer = nil;
    outSize = 0;
    return result;
}

-(void* _Nullable) addEncoderImage:(MozjpegImage *_Nonnull)sourceImage error:(NSError *_Nullable*_Nullable)error {
    int width = (int)(sourceImage.size.width * sourceImage.scale);
    int height = (int)(sourceImage.size.height * sourceImage.scale);
    uint8_t* buffer = createRGB8Buffer(sourceImage);
    if (width != self->width) {
        *error = [[NSError alloc] initWithDomain:@"JPEGCompression" code:500 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"`addEncoderImage due to invalid image sizes` failed", nil) }];
        jpeg_destroy_compress(&cinfo);
        compressStarted = false;
        if (outBuffer != NULL) {
            free(outBuffer);
        }
        outBuffer = nil;
        outSize = 0;
        return nil;
    }
    int bufferBytesPerRow = ((3 * (int)width) + 31) & (~31);
    JSAMPROW rowPointer[1];
    int lines = 0;
    while (lines < height) {
        rowPointer[0] = (JSAMPROW)(buffer + lines * bufferBytesPerRow);
        jpeg_write_scanlines(&cinfo, rowPointer, 1);
        lines = lines + 1;
    }
    
    free(buffer);
    return @"ok";
}

-(void) createCompress:(int)quality width:(int)width height:(int)height{
    compressStarted = true;
    cinfo.err = jpeg_std_error(&jerr.pub);
    jpeg_create_compress(&cinfo);
    
    self->outBuffer = NULL;
    self->outSize = 0;
    jpeg_mem_dest(&cinfo, &outBuffer, &self->outSize);
    
    cinfo.image_width = (uint32_t)width;
    cinfo.image_height = (uint32_t)height;
    cinfo.input_components = 3;
    cinfo.in_color_space = JCS_RGB;
    jpeg_c_set_int_param(&cinfo, JINT_COMPRESS_PROFILE, JCP_FASTEST);
    jpeg_set_defaults(&cinfo);
    cinfo.write_JFIF_header = true;
    cinfo.write_Adobe_marker = true;
    cinfo.arith_code = FALSE;
    cinfo.dct_method = JDCT_ISLOW;
    cinfo.optimize_coding = TRUE;
    jpeg_set_quality(&cinfo, quality, 1);
    jpeg_simple_progression(&cinfo);
    jpeg_start_compress(&cinfo, 1);
    self->width = width;
}

@end

NSError* _Nullable compressJPEGDataTo(NSString* _Nonnull path, UIImage * _Nonnull sourceImage, int quality) {
    int width = (int)(sourceImage.size.width * sourceImage.scale);
    int height = (int)(sourceImage.size.height * sourceImage.scale);
    uint8_t* buffer = createRGB8Buffer(sourceImage);
    int bufferBytesPerRow = ((3 * (int)width) + 31) & (~31);
    
    struct jpeg_compress_struct cinfo;
    struct my_error_mgr jerr;
    FILE * outfile = NULL;
    cinfo.err = jpeg_std_error(&jerr.pub);
    jerr.pub.error_exit = my_error_exit;
    if (setjmp(jerr.setjmp_buffer)) {
        jpeg_destroy_compress(&cinfo);
        if (outfile) {
            fclose(outfile);
        }
        return [[NSError alloc] initWithDomain:@"compressJPEGDataTo" code:500 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"`compressJPEGDataTo` failed", nil) }];
    }
    
    if ((outfile = fopen([path UTF8String], "wb")) == NULL) {
        return [[NSError alloc] initWithDomain:@"compressJPEGDataTo" code:500 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"`can't open the file` failed", nil) }];
    }
    
    jpeg_create_compress(&cinfo);
    
    jpeg_stdio_dest(&cinfo, outfile);
    
    cinfo.image_width = (uint32_t)width;
    cinfo.image_height = (uint32_t)height;
    cinfo.input_components = 3;
    cinfo.in_color_space = JCS_RGB;
    jpeg_c_set_int_param(&cinfo, JINT_COMPRESS_PROFILE, JCP_FASTEST);
    jpeg_set_defaults(&cinfo);
    cinfo.write_JFIF_header = true;
    cinfo.write_Adobe_marker = true;
    cinfo.arith_code = FALSE;
    cinfo.dct_method = JDCT_ISLOW;
    cinfo.optimize_coding = TRUE;
    cinfo.jpeg_color_space = JCS_YCbCr;
    jpeg_set_quality(&cinfo, quality, 1);
    jpeg_simple_progression(&cinfo);
    jpeg_start_compress(&cinfo, 1);
    
    JSAMPROW rowPointer[1];
    while (cinfo.next_scanline < cinfo.image_height) {
        rowPointer[0] = (JSAMPROW)(buffer + cinfo.next_scanline * bufferBytesPerRow);
        jpeg_write_scanlines(&cinfo, rowPointer, 1);
    }
    
    jpeg_finish_compress(&cinfo);
    fclose(outfile);
    jpeg_destroy_compress(&cinfo);
    free(buffer);
    
    return nil;
}


NSData * _Nullable compressJPEGData(MozjpegImage * _Nonnull sourceImage, int quality) {
    int width = (int)(sourceImage.size.width * sourceImage.scale);
    int height = (int)(sourceImage.size.height * sourceImage.scale);
    uint8_t* buffer = createRGB8Buffer(sourceImage);
    int bufferBytesPerRow = ((3 * (int)width) + 31) & (~31);
    
    struct jpeg_compress_struct cinfo;
    struct my_error_mgr jerr;
    uint8_t *outBuffer = NULL;
    cinfo.err = jpeg_std_error(&jerr.pub);
    jerr.pub.error_exit = my_error_exit;
    if (setjmp(jerr.setjmp_buffer)) {
        jpeg_destroy_compress(&cinfo);
        if (outBuffer != NULL) {
            free(outBuffer);
        }
        return nil;
    }
    jpeg_create_compress(&cinfo);
    
    unsigned long outSize = 0;
    jpeg_mem_dest(&cinfo, &outBuffer, &outSize);
    
    cinfo.image_width = (uint32_t)width;
    cinfo.image_height = (uint32_t)height;
    cinfo.input_components = 3;
    cinfo.in_color_space = JCS_RGB;
    jpeg_c_set_int_param(&cinfo, JINT_COMPRESS_PROFILE, JCP_FASTEST);
    jpeg_set_defaults(&cinfo);
    cinfo.arith_code = FALSE;
    cinfo.dct_method = JDCT_ISLOW;
    cinfo.optimize_coding = TRUE;
    cinfo.write_JFIF_header = true;
    cinfo.write_Adobe_marker = true;
    cinfo.jpeg_color_space = JCS_YCbCr;
    jpeg_set_quality(&cinfo, quality, 1);
    jpeg_simple_progression(&cinfo);
    jpeg_start_compress(&cinfo, 1);
    
    JSAMPROW rowPointer[1];
    while (cinfo.next_scanline < cinfo.image_height) {
        rowPointer[0] = (JSAMPROW)(buffer + cinfo.next_scanline * bufferBytesPerRow);
        jpeg_write_scanlines(&cinfo, rowPointer, 1);
    }
    
    jpeg_finish_compress(&cinfo);
    
    NSData *result = [[NSData alloc] initWithBytes:outBuffer length:outSize];
    
    jpeg_destroy_compress(&cinfo);
    
    free(outBuffer);
    free(buffer);
    
    return result;
}
