//
//  MozjpegBinding.h
//  PDFScanner
//
//  Created by Radzivon Bartoshyk on 3.09.21.
//

#ifndef MozjpegBinding_h
#define MozjpegBinding_h

#import "MozjpegImage.h"
#import "MozjpegDecompress.hxx"

@interface JPEGCompression : NSObject
-(NSData * _Nonnull)finishCompress;
-(void* _Nullable) addEncoderImage:(MozjpegImage* _Nonnull)sourceImage error:(NSError *_Nullable*_Nullable)error;
-(void) createCompress:(int)quality width:(int)width height:(int)height;
@end

NSError* _Nullable compressJPEGDataTo(NSString* _Nonnull path, MozjpegImage * _Nonnull sourceImage, int quality) NS_SWIFT_NAME(compressJPEGData(path:image:quality:));
NSData * _Nullable compressJPEGData(MozjpegImage * _Nonnull sourceImage, int quality) NS_SWIFT_NAME(compressMozjpeg(image:quality:));

#endif /* MozjpegBinding_h */
