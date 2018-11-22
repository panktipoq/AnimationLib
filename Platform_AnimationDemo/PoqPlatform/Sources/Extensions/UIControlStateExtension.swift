//
//  UIControlStateExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/13/16.
//
//

import Foundation

extension UIControlState: Hashable {

    @nonobjc
    public var hashValue: Int {
        return Int(rawValue)
    }
}
