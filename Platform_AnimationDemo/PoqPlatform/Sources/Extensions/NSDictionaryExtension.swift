//
//  NSDictionaryExtension.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 28/01/2017.
//
//

import Foundation

extension NSDictionary {
    
    @nonobjc
    public func swiftDictionary() -> [AnyHashable: Any] {
        var res = [AnyHashable: Any]()
        
        for item in self {
            if let key = item.key as? AnyHashable {
                res[key] = item.value
            }
        }
        
        return res
    }
    
}
