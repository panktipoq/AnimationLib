//
//  STPCardBrandExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 12/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation

import Stripe

extension STPCardBrand {
    
    func stringRepresentation() -> String {
        
        var res = ""
        
        switch self {
        case .visa:
            res = "VISA"
            break
        case .amex:
            res = "AMEX"
            break
        case .masterCard:
            res = "MasterCard"
            break
        case .discover:
            res = "Discover"
            break
        case .JCB:
            res = "JCB"
            break
        case .dinersClub:
            res = "DinersClub"
            break
            
        default:
            print ("unknown card brand - \(self.rawValue)")
        }
        
        return res
    }
    
}
