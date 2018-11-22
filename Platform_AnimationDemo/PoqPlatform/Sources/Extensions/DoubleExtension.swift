//
//  DoubleExtension.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 1/5/16.
//  Copyright © 2016 Poq. All rights reserved.
//

import Foundation

public extension Double {
    func toPriceString() -> String {
        
        return String(format: "%@%.2f", CurrencyProvider.shared.currency.symbol, self)
    }
}

public extension CGFloat {
    func isPositive() -> Bool {
        return self > 1e-3
    }
}
