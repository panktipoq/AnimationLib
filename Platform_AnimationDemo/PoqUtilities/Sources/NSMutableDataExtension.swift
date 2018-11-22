//
//  NSMutableDataExtension.swift
//  PoqUtilities
//
//  Created by Manuel Marcos Regalado on 03/04/2018.
//

import Foundation

extension NSMutableData {
    
    public func append(utf8Encoded string: String) {
        guard let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            Log.error("Couldn't encode string")
            return
        }
        append(data)
    }
}
