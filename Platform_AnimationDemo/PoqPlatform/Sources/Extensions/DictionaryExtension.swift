//
//  DictionaryExtension.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 4/20/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//
import Foundation

public extension Dictionary {
    public mutating func update(_ other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
