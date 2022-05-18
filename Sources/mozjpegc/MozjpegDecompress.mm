//
//  MozjpegDecompress.m
//  
//
//  Created by Radzivon Bartoshyk on 18/05/2022.
//

#import "MozjpegBinding.h"
#import "turbojpeg.h"

@implementation MozjpegDecompress {
    tjhandle decompressPtr;
}

-(id)init {
    decompressPtr = tjInitDecompress();
}

-(void)dealloc {
    if (decompressPtr) {
        tjDestroy(decompressPtr);
    }
    decompressPtr = nullptr;
}

-(nullable MozjpegImage*)decompress:(nonnull NSData*)chunk {
    int width = 0;
    int height = 0;
    int jpegSubsample = 0;
    int jpegColorspace = 0;
    int result = tjDecompressHeader3(decompressPtr, (unsigned char *)chunk.bytes, chunk.length, &width, &height, &jpegSubsample, &jpegColorspace);
    if (result) {
        //some error
        return nil;
    }
    unsigned char* outputBuffer = reinterpret_cast<unsigned char*>(malloc(width * height * 4));
    result = tjDecompress2(decompressPtr, (unsigned char *)chunk.bytes, chunk.length, outputBuffer, width, 0, height, TJPF_RGBA, 0);
    if (result) {
        //some error
        free(outputBuffer);
        return nil;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int flags = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    CGContextRef gtx = CGBitmapContextCreate(outputBuffer, width, height, 8, width * 4, colorSpace, flags);
    if (gtx == NULL) {
        free(outputBuffer);
        return nil;
    }
    CGImageRef imageRef = CGBitmapContextCreateImage(gtx);
    MozjpegImage *image = nil;
#if TARGET_OS_OSX
    image = [[NSImage alloc] initWithCGImage:imageRef size:CGSizeZero];
#else
    image = [UIImage imageWithCGImage:imageRef scale:1 orientation: UIImageOrientationUp];
#endif

    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    
    free(outputBuffer);
    return image;
}

@end
