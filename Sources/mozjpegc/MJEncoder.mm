//
//  MJEncoder.m
//  
//
//  Created by Radzivon Bartoshyk on 19/05/2022.
//

#import "MJEncoder.hxx"
#import "turbojpeg.h"
#import <Accelerate/Accelerate.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation MJEncoder {
    tjhandle tjInstance;
}

-(nonnull id)init {
    tjInstance = tjInitCompress();

    return self;
}

-(void)dealloc {
    tjDestroy(tjInstance);
    tjInstance = nullptr;
}

+ (CGColorSpaceRef)colorSpaceGetDeviceRGB {
    static CGColorSpaceRef colorSpace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    });
    return colorSpace;
}


-(nullable NSData*)compress:(nonnull MozjpegImage*)image quality:(int)quality progressive:(bool)progressive useFastest:(bool)useFastest {
    
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        return nil;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
    
    vImageConverterRef convertor = NULL;
    vImage_Error v_error = kvImageNoError;
    
    vImage_CGImageFormat srcFormat = {
        .bitsPerComponent = (uint32_t)bitsPerComponent,
        .bitsPerPixel = (uint32_t)bitsPerPixel,
        .colorSpace = CGImageGetColorSpace(imageRef),
        .bitmapInfo = bitmapInfo,
        .renderingIntent = CGImageGetRenderingIntent(imageRef)
    };
    vImage_CGImageFormat destFormat = {
        .bitsPerComponent = 8,
        .bitsPerPixel = 32,
        .colorSpace = CGColorSpaceCreateDeviceRGB(),
        .bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host
    };
    
    convertor = vImageConverter_CreateWithCGImageFormat(&srcFormat, &destFormat, NULL, kvImageNoFlags, &v_error);
    if (v_error != kvImageNoError) {
        return nil;
    }
    
    vImage_Buffer src;
    v_error = vImageBuffer_InitWithCGImage(&src, &srcFormat, NULL, imageRef, kvImageNoFlags);
    if (v_error != kvImageNoError) {
        return nil;
    }
    vImage_Buffer dest;
    vImageBuffer_Init(&dest, height, width, 32, kvImageNoFlags);
    if (!dest.data) {
        free(src.data);
        return nil;
    }
    
    v_error = vImageConvert_AnyToAny(convertor, &src, &dest, NULL, kvImageNoFlags);
    free(src.data);
    vImageConverter_Release(convertor);
    if (v_error != kvImageNoError) {
        free(dest.data);
        return nil;
    }
    if (!dest.data) {
        return nil;
    }
    
    const int pixelFormat = TJPF_ARGB;
    
    unsigned char* jpegBuf = nullptr;
    unsigned long jpegSize = 0;
    
    int flags = /*useFastest ? TJFLAG_FASTDCT : TJFLAG_ACCURATEDCT*/ 0;
    if (progressive) {
        flags |= TJFLAG_PROGRESSIVE;
    }
    
    int result = tjCompress2(tjInstance, static_cast<const unsigned char *>(dest.data), static_cast<int>(dest.width), 0, static_cast<int>(dest.height), pixelFormat, &jpegBuf, &jpegSize, TJSAMP_420, quality, flags);
    free(dest.data);
    if (result < 0) {
        NSLog(@"%@", [NSString stringWithFormat:@"JPEG encoding error with : %s", tjGetErrorStr2(tjInstance)]);
        tjFree(jpegBuf);
        return nil;
    }
    
    auto resultData = [[NSMutableData alloc] initWithBytes:jpegBuf length:jpegSize];
    tjFree(jpegBuf);
    return resultData;
    
}

@end
