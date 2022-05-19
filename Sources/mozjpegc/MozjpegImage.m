//
//  MozjpegImage.m
//  
//
//  Created by Radzivon Bartoshyk on 19/05/2022.
//

#import <MozjpegImage.h>

@implementation MozjpegImage (MJImage)

- (unsigned char *)mjRgbaPixels {
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    return rawData;
}


@end

uint8_t * createRGB8Buffer(MozjpegImage * _Nonnull sourceImage) {
    int width = (int)(sourceImage.size.width * sourceImage.scale);
    int height = (int)(sourceImage.size.height * sourceImage.scale);
    int targetBytesPerRow = ((4 * (int)width) + 31) & (~31);
    uint8_t *targetMemory = malloc((int)(targetBytesPerRow * height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, width, height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    
    UIGraphicsPushContext(targetContext);
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(targetContext, CGRectMake(0, 0, width, height), sourceImage.CGImage);
    
    UIGraphicsPopContext();
    
    int bufferBytesPerRow = ((3 * (int)width) + 31) & (~31);
    uint8_t *buffer = malloc(bufferBytesPerRow * height);
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            uint32_t *color = ((uint32_t *)&targetMemory[y * targetBytesPerRow + x * 4]);
            
            uint32_t r = ((*color >> 16) & 0xff);
            uint32_t g = ((*color >> 8) & 0xff);
            uint32_t b = (*color & 0xff);
            
            buffer[y * bufferBytesPerRow + x * 3 + 0] = r;
            buffer[y * bufferBytesPerRow + x * 3 + 1] = g;
            buffer[y * bufferBytesPerRow + x * 3 + 2] = b;
        }
    }
    
    CGContextRelease(targetContext);
    
    free(targetMemory);
    
    return buffer;
}
