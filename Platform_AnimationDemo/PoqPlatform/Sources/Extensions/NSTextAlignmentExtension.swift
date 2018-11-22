//
//  NSTextAlignmentExtension.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 9/28/15.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import UIKit

public extension NSTextAlignment {

    static func valueFromString(_ stringValue: String) -> NSTextAlignment {
        switch(stringValue){
        case "Left":
            return .left
        case "Right":
            return .right
        case "Center":
            return .center
        default:
            return .center
        }
    }
}
