//
//  Header.h
//  
//
//  Created by Radzivon Bartoshyk on 19/05/2022.
//

#import <Foundation/Foundation.h>
#import "MozjpegImage.h"

@interface MJEncoder : NSObject
-(nonnull id)init;
-(nullable NSData*)compress:(nonnull MozjpegImage*)image quality:(int)quality progressive:(bool)progressive useFastest:(bool)useFastest;
@end

