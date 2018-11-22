//
//  NSErrorExtension.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 4/25/17.
//
//

import Foundation

extension NSError {
    
    @nonobjc
    var isTimeOutError: Bool {
        return code == NSURLErrorTimedOut
    }
}
