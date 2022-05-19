//
//  Mozjpeg.swift
//  
//
//  Created by Radzivon Bartoshyk on 27/04/2022.
//

import Foundation
#if SWIFT_PACKAGE
import mozjpegc
#endif

public class Mozjpeg {
    
    public init() {
        
    }
    
    private let _decompress = MJDecompress()
    
    public func decompress(chunk: Data) -> MozjpegImage? {
        return _decompress.decompress(chunk)
    }
    
    public static func isJpeg(data: Data) -> Bool {
        return MJDecompress.isJpeg(data)
    }
    
}
