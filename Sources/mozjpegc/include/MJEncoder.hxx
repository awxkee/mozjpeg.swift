//
//  Header.h
//  
//
//  Created by Radzivon Bartoshyk on 19/05/2022.
//

#import <Foundation/Foundation.h>
#import "MozjpegImage.hxx"

@interface MJEncoder : NSObject
-(nonnull id)init;
-(nullable NSData*)compress:(nonnull MozjpegImage*)image quality:(int)quality progressive:(bool)progressive useFastest:(bool)useFastest;
-(nullable NSError*) compressTo:(nonnull NSURL*)url image:(nonnull MozjpegImage *)image quality:(int)quality progressive:(bool)progressive useFastest:(bool)useFastest;
@end

