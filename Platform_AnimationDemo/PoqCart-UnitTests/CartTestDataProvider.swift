//
//  CartTestDataProvider.swift
//  PoqDemoApp
//
//  Created by Balaji Reddy on 09/07/2018.
//

import Foundation
import XCTest

@testable import PoqCart

final class CartTestDataProvider {
    
    static var cart: CartDomainModel? = {
    
        guard
            let bundle = Bundle(for: CartTestDataProvider.self).path(forResource: "PoqCartTests", ofType: "bundle").flatMap({ Bundle(path: $0) }),
            let cartItemsFilePath = bundle.path(forResource: "CartItems", ofType: "json"),
            let cartItemsFile = FileManager.default.contents(atPath: cartItemsFilePath)
        else {
                XCTFail("Failed to read CartItems.json")
                return nil
        }
    
        let cartNetworkModel = try? JSONDecoder().decode(Cart.self, from: cartItemsFile)
        
        return cartNetworkModel.flatMap { CartDomainModelMapper().map(from: $0) }
        
    }()
}
