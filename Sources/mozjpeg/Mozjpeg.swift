//
//  File.swift
//  
//
//  Created by Radzivon Bartoshyk on 27/04/2022.
//

import Foundation
import UIKit
#if SWIFT_PACKAGE
import mozjpegc
#endif

public struct CannotCompressError: Error, Equatable { }

public extension UIImage {
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