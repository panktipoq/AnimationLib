//
//  DefaultAppModule.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 11/3/16.
//
//

import Foundation

open class DefaultAppModule {
    public init() {
    }
}

extension DefaultAppModule: PoqModule {
    
    public var bundle: Bundle {
        return Bundle.main
    }
    
}
