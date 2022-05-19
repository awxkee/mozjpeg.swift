//
//  Mozjpeg+Image.swift
//  
//
//  Created by Radzivon Bartoshyk on 19/05/2022.
//

import Foundation
#if os(macOS)
import AppKit
public typealias MozjpegImage = NSImage
#else
import UIKit
public typealias MozjpegImage = UIImage
#endif
#if SWIFT_PACKAGE
import mozjpegc
#endif

public extension MozjpegImage {
    
    /**
     Compress **UIImage** with mozjpeg to file at *url*
     - Throws **CannotCompressError**: if error occured while compressing
     */
    func mozjpegRepresentation(at url: URL, quality: Float) throws {
        try mozjpegRepresentation(atPath: url.path, quality: quality)
    }
    
    /**
     Compress **UIImage** with mozjpeg to file at *path*
     - Throws **CannotCompressError**: if error occured while compressing
     */
    func mozjpegRepresentation(atPath path: String, quality: Float) throws {
        if let error = compressJPEGData(path: path, image: self, quality: max(1, Int32(quality * 100))) {
            throw error
        }
    }
    
    /**
     Compressed Image to Mozjpeg data
     - Returns **Data**: final JPEG data
     - Throws **CannotCompressError**: if error occured while compressing
     */
    func mozjpegRepresentation(quality: Float) throws -> Data {
        let encoder = MJEncoder()
        guard let data = encoder.compress(self, quality: max(1, Int32(quality * 100)), progressive: true, useFastest: false) else {
            throw CannotCompressError()
        }
        
        return data
//        guard let data = compressMozjpeg(image: self, quality: max(1, Int32(quality * 100))) else {
//            throw CannotCompressError()
//        }
//        return data
    }
}
