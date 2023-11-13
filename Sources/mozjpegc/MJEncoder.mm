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
#import <vector>

using namespace std;

@implementation MJEncoder {
    tjhandle tjInstance;
}

-(nonnull id)init {
    tjInstance = tjInitCompress();
    return self;
}

-(void)dealloc {
    if (tjInstance) {
        tjDestroy(tjInstance);
    }
    tjInstance = nullptr;
}

-(nullable NSError*) compressTo:(nonnull NSURL*)url image:(nonnull MozjpegImage *)image quality:(int)quality progressive:(bool)progressive useFastest:(bool)useFastest {

    auto jpegData = [self compress:image quality:quality progressive:progressive useFastest:useFastest];
    if (!jpegData) {
        return [[NSError alloc] initWithDomain:@"MJEncoder" code:500 userInfo:@{ NSLocalizedDescriptionKey: @"Can't encode image" }];
    }

    if (![jpegData writeToURL:url atomically:true]) {
        return [[NSError alloc] initWithDomain:@"MJEncoder" code:500 userInfo:@{ NSLocalizedDescriptionKey: @"Can't write final data to URL" }];
    }

    return nil;
}

-(nullable NSData*)compress:(nonnull MozjpegImage*)image quality:(int)quality progressive:(bool)progressive useFastest:(bool)useFastest {
    try {
        CGImageRef imageRef = [image makeCGImage];
        if (!imageRef) {
            return nil;
        }

        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);

        vector<uint8_t> buffer;

        auto pResult = [image mjRgbaPixels:buffer];
        if (!pResult) {
            NSLog(@"%@", [NSString stringWithFormat:@"Getting an image buffer has failed"]);
            return nil;
        }

        const int pixelFormat = TJPF_RGBA;

        unsigned char* jpegBuf = nullptr;
        unsigned long jpegSize = 0;

        int flags = useFastest ? TJFLAG_FASTDCT : TJFLAG_ACCURATEDCT;
        if (progressive) {
            flags |= TJFLAG_PROGRESSIVE;
        }
        
        int result = tjCompress2(tjInstance,
                                 reinterpret_cast<const unsigned char *>(buffer.data()),
                                 static_cast<int>(width),
                                 0,
                                 static_cast<int>(height),
                                 pixelFormat,
                                 &jpegBuf, &jpegSize,
                                 TJSAMP_420, quality, flags);
        if (result < 0) {
            NSLog(@"%@", [NSString stringWithFormat:@"JPEG encoding error with : %s", tjGetErrorStr2(tjInstance)]);
            tjFree(jpegBuf);
            return nil;
        }

        auto resultData = [[NSMutableData alloc] initWithBytesNoCopy:jpegBuf
                                                              length:jpegSize
                                                         deallocator:^(void * _Nonnull bytes, NSUInteger length) {
            tjFree((unsigned char *)bytes);
        }];

        return resultData;
    } catch (std::bad_alloc& err) {
        NSLog(@"%@", [NSString stringWithFormat:@"%s", err.what()]);
        return nullptr;
    }
}

@end
