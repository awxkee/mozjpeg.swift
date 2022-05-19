//
//  Mozjpeg+Errors.swift
//  
//
//  Created by Radzivon Bartoshyk on 19/05/2022.
//

import Foundation

public struct CannotCompressError: Error, Equatable { }
public struct InvalidJPEGDimensionsError: LocalizedError, Equatable {
    public var errorDescription: String? {
        "Image dimensions must be less than 65000"
    }
}
