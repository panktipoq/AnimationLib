//
//  BoolExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/26/16.
//
//

import Foundation

public extension Bool {
    func toString() -> String {
        return self ? "true" : "false"
    }
}
