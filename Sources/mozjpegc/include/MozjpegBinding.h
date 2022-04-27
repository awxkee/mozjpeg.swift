//
//  MozjpegBinding.h
//  PDFScanner
//
//  Created by Radzivon Bartoshyk on 3.09.21.
//

#ifndef MozjpegBinding_h
#define MozjpegBinding_h

#import <UIKit/UIKit.h>

NSData * _Nullable compressJPEGData(UIImage * _Nonnull sourceImage, int quality) NS_SWIFT_NAME(compressMozjpeg(image:quality:));

#endif /* MozjpegBinding_h */
