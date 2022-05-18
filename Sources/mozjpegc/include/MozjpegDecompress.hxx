//
//  Header.h
//  
//
//  Created by Radzivon Bartoshyk on 18/05/2022.
//

#import "MozjpegImage.h"
#import <Foundation/Foundation.h>

@interface MozjpegDecompress: NSObject
-(nonnull id)init;
-(nullable MozjpegImage*)decompress:(nonnull NSData*)chunk;
@end
