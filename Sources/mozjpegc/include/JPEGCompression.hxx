//
//  MozjpegBinding.h
//  PDFScanner
//
//  Created by Radzivon Bartoshyk on 3.09.21.
//

#ifndef MozjpegBinding_h
#define MozjpegBinding_h

#import <Foundation/Foundation.h>
#import "MozjpegImage.hxx"

@interface JPEGCompression : NSObject
-(NSData * _Nonnull)finishCompress;
-(void* _Nullable) addEncoderImage:(MozjpegImage* _Nonnull)sourceImage error:(NSError *_Nullable*_Nullable)error;
-(void) createCompress:(int)quality width:(int)width height:(int)height;
@end

#endif /* MozjpegBinding_h */
