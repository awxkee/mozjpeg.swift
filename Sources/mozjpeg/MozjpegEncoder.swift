//
//  MozjpegEncoder.swift
//  
//
//  Created by Radzivon Bartoshyk on 19/05/2022.
//

import Foundation
#if SWIFT_PACKAGE
import mozjpegc
#endif

public class MozjpegEncoder {
    
    private let compression = JPEGCompression()
    
    public init() {
        
    }
    
    public func createCompress(quality: Float, width: Int32, height: Int32) throws {
        if width >= 65000 || height >= 65000 {
            throw InvalidJPEGDimensionsError()
        }
        compression.createCompress(max(1, Int32(quality * 100)), width: width, height: height)
    }
    
    public func addImage(image: MozjpegImage, quality: Float) throws {
        try compression.addEncoderImage(image)
    }
    
    public func finish() -> Data {
        return compression.finishCompress()
    }
}
