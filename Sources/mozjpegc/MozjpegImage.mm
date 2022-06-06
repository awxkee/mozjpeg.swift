//
//  MozjpegImage.m
//  
//
//  Created by Radzivon Bartoshyk on 19/05/2022.
//

#import <MozjpegImage.hxx>
#import <Accelerate/Accelerate.h>>

@implementation MozjpegImage (MJImage)
#if TARGET_OS_OSX
- (unsigned char *)mjRgbaPixels {
    auto rect = NSMakeRect(0, 0, self.size.width, self.size.height);
    CGImageRef imageRef = [self CGImageForProposedRect: &rect context:nil hints:nil];
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
    CGContextSetFillColorWithColor(context, [[NSColor whiteColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    auto unpremultiplied = [MozjpegImage mjUnpremultiplyRGBA:imageRef];
    if (unpremultiplied) {
        free(rawData);
        rawData = unpremultiplied;
    }
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return rawData;
}

-(nullable CGImageRef)makeCGImage {
    auto rect = NSMakeRect(0, 0, self.size.width, self.size.height);
    CGImageRef imageRef = [self CGImageForProposedRect: &rect context:nil hints:nil];
    return imageRef;
}

-(nonnull uint8_t *) createRGB8Buffer {
    int width = self.mjIntrinsicWidth;
    int height = self.mjIntrinsicHeight;
    int targetBytesPerRow = ((4 * (int)width) + 31) & (~31);
    uint8_t *targetMemory = static_cast<uint8_t*>(malloc((int)(targetBytesPerRow * height)));

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;

    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, width, height, 8, targetBytesPerRow, colorSpace, bitmapInfo);

    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext: [NSGraphicsContext graphicsContextWithCGContext:targetContext flipped:FALSE]];
    CGColorSpaceRelease(colorSpace);
    
    [self drawInRect:NSMakeRect(0, 0, self.mjIntrinsicWidth, self.mjIntrinsicHeight) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    
    [NSGraphicsContext restoreGraphicsState];

    int bufferBytesPerRow = ((3 * (int)width) + 31) & (~31);
    uint8_t *buffer = static_cast<uint8_t*>(malloc(bufferBytesPerRow * height));

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

-(int)mjIntrinsicWidth {
    return self.size.width;
}

-(int)mjIntrinsicHeight {
    return self.size.height;
}

#else

-(nullable CGImageRef)makeCGImage {
    return [self CGImage];
}

- (unsigned char *)mjRgbaPixels {
    CGImageRef imageRef = [self makeCGImage];
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
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    auto unpremultiplied = [MozjpegImage mjUnpremultiplyRGBA:imageRef];
    if (unpremultiplied) {
        free(rawData);
        rawData = unpremultiplied;
    }
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return rawData;
}

-(nonnull uint8_t *) createRGB8Buffer {
    int width = self.mjIntrinsicWidth;
    int height = self.mjIntrinsicHeight;
    int targetBytesPerRow = ((4 * (int)width) + 31) & (~31);
    uint8_t *targetMemory = static_cast<uint8_t*>(malloc((int)(targetBytesPerRow * height)));

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;

    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, width, height, 8, targetBytesPerRow, colorSpace, bitmapInfo);

    UIGraphicsPushContext(targetContext);

    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(targetContext, CGRectMake(0, 0, width, height), self.CGImage);

    UIGraphicsPopContext();

    int bufferBytesPerRow = ((3 * (int)width) + 31) & (~31);
    uint8_t *buffer = static_cast<uint8_t*>(malloc(bufferBytesPerRow * height));

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

-(int)mjIntrinsicWidth {
    return self.size.width * self.scale;
}
-(int)mjIntrinsicHeight {
    return self.size.height * self.scale;
}

#endif

+(unsigned char*)mjUnpremultiplyRGBA:(CGImageRef)cgNewImageRef {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    vImage_Buffer src;
    void* result = nullptr;
    vImage_CGImageFormat srcFormat = {
          .bitsPerComponent = (uint32_t)CGImageGetBitsPerComponent(cgNewImageRef),
          .bitsPerPixel = (uint32_t)CGImageGetBitsPerPixel(cgNewImageRef),
          .colorSpace = colorSpace,
          .bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big,
          .renderingIntent = kCGRenderingIntentDefault
      };
    auto vEerror = vImageBuffer_InitWithCGImage(&src, &srcFormat, NULL, cgNewImageRef, kvImageNoFlags);
    if (vEerror != kvImageNoError) {
        free(src.data);
        CGColorSpaceRelease(colorSpace);
        return nullptr;
    }
    
    vImage_Buffer dest = {
        .data = malloc(CGImageGetWidth(cgNewImageRef) * CGImageGetHeight(cgNewImageRef) * 4),
        .width = CGImageGetWidth(cgNewImageRef),
        .height = CGImageGetHeight(cgNewImageRef),
        .rowBytes = CGImageGetWidth(cgNewImageRef) * 4
    };
    vEerror = vImageUnpremultiplyData_RGBA8888(&src, &dest, kvImageNoFlags);
    if (vEerror != kvImageNoError) {
        free(src.data);
        free(dest.data);
        CGColorSpaceRelease(colorSpace);
        return nullptr;
    }
    result = dest.data;
    
    free(src.data);
    CGColorSpaceRelease(colorSpace);
    return reinterpret_cast<unsigned char*>(result);
}


@end
