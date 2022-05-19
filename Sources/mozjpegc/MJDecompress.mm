//
//  MozjpegDecompress.m
//  
//
//  Created by Radzivon Bartoshyk on 18/05/2022.
//

#import "MJDecompress.hxx"
#import "turbojpeg.h"

@implementation MJDecompress {
    tjhandle decompressPtr;
}

-(id)init {
    decompressPtr = tjInitDecompress();
    return self;
}

-(void)dealloc {
    if (decompressPtr) {
        tjDestroy(decompressPtr);
    }
    decompressPtr = NULL;
}

+(BOOL)isJpeg:(nonnull NSData*)chunk {
    auto decompressPtr = tjInitDecompress();
    int width = 0;
    int height = 0;
    int jpegSubsample = 0;
    int jpegColorspace = 0;
    int result = tjDecompressHeader3(decompressPtr, (unsigned char *)chunk.bytes, chunk.length, &width, &height, &jpegSubsample, &jpegColorspace);
    tjDestroy(decompressPtr);
    if (result) {
        //some error
        return false;
    }
    return true;;
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
    
    auto tjTransformHandle = tjInitTransform();
    tjtransform xform;
    memset(&xform, 0, sizeof(tjtransform));
    xform.options |= TJXOPT_PROGRESSIVE;
    xform.options |= TJXOPT_TRIM;
    
    unsigned char *dstBuf = NULL;  /* Dynamically allocate the JPEG buffer */
    unsigned long dstSize = 0;
    
    if (tjTransform(tjTransformHandle, static_cast<const unsigned char *>(chunk.bytes), chunk.length, 1, &dstBuf, &dstSize,
                    &xform, 0) < 0) {
        if (tjGetErrorCode(tjTransformHandle) == TJERR_FATAL) {
            if (dstBuf) {
                tjFree(dstBuf);
            }
            return nil;
        }
    }
    
    tjDestroy(tjTransformHandle);
    
    unsigned char* outputBuffer = reinterpret_cast<unsigned char*>(malloc(width * height * 4));
    result = tjDecompress2(decompressPtr, static_cast<const unsigned char *>(dstBuf), dstSize, outputBuffer, width, 0, height, TJPF_RGBA, TJFLAG_PROGRESSIVE);
    tjFree(dstBuf);
    if (result) {
        if (tjGetErrorCode(decompressPtr) == TJERR_FATAL) {
            //some error
            free(outputBuffer);
            return nil;
        }
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
