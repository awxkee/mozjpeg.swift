//
//  MJDecompress.h
//  
//
//  Created by Radzivon Bartoshyk on 19/05/2022.
//

#import <Foundation/Foundation.h>
#import "MozjpegImage.hxx"

@interface MJDecompress : NSObject
-(nonnull id)init;
-(nullable MozjpegImage*)decompress:(nonnull NSData*)chunk;
+(BOOL)isJpeg:(nonnull NSData*)chunk;
@end
