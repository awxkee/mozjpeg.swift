//
//  Header.h
//  
//
//  Created by Radzivon Bartoshyk on 18/05/2022.
//

#import "TargetConditionals.h"

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#define MozjpegImage   NSImage
#else
#import <UIKit/UIKit.h>
#define MozjpegImage   UIImage
#endif

@interface MozjpegImage (MJImage)
- (nonnull unsigned char *)mjRgbaPixels;
- (nonnull uint8_t *) createRGB8Buffer;
-(int)mjIntrinsicWidth;
-(int)mjIntrinsicHeight;
-(nullable CGImageRef)makeCGImage;
@end

uint8_t * _Nonnull createRGB8Buffer(MozjpegImage * _Nonnull sourceImage);
