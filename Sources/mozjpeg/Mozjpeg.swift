//
//  Mozjpeg.swift
//  
//
//  Created by Radzivon Bartoshyk on 27/04/2022.
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

public struct CannotCompressError: Error, Equatable { }
public struct InvalidJPEGDimensionsError: LocalizedError, Equatable {
    public var errorDescription: String? {
        "Image dimensions must be less than 65000"
    }
}

public class Mozjpeg {
    
    private let _decompress = MozjpegDecompress()
    
    public func decompress(chunk: Data) -> MozjpegImage? {
        return _decompress.decompress(chunk)
    }
    
}

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
        guard let data = compressMozjpeg(image: self, quality: max(1, Int32(quality * 100))) else {
            throw CannotCompressError()
        }
        return data
    }
}
