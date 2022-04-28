//
//  MozjpegBinding.h
//  PDFScanner
//
//  Created by Radzivon Bartoshyk on 3.09.21.
//

#ifndef MozjpegBinding_h
#define MozjpegBinding_h

#import <UIKit/UIKit.h>
#import "../jpeglib.h"

struct my_error_mgr {
    struct jpeg_error_mgr pub;    /* "public" fields */
    
    jmp_buf setjmp_buffer;    /* for return to caller */
};

typedef struct my_error_mgr * my_error_ptr;

@interface JPEGCompression : NSObject {
    struct jpeg_compress_struct cinfo;
    struct my_error_mgr jerr;
    uint8_t width;
    uint8_t *outBuffer;
    unsigned long outSize;
}

-(NSData * _Nonnull)finishCompress;

-(void* _Nullable) addEncoderImage:(UIImage*_Nonnull)sourceImage quality:(int)quality error:(NSError *_Nullable*_Nullable)error;
-(void* _Nullable) createCompress:(UIImage*_Nonnull)sourceImage quality:(int)quality error:(NSError *_Nullable*_Nullable)error;
@end

NSData * _Nullable compressJPEGData(UIImage * _Nonnull sourceImage, int quality) NS_SWIFT_NAME(compressMozjpeg(image:quality:));

#endif /* MozjpegBinding_h */
