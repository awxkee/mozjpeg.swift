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
