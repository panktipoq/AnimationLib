//
//  MockCartDataService.swift
//  PoqDemoApp-EGTests
//
//  Created by Balaji Reddy on 14/07/2018.
//

import Foundation
import ReSwift

@testable import PoqCart

public class MockCartDataService: CartDataServiceable {
    
    var testDataJsonFileName: String
    var dispatchErrors = false
    var errorToDispatch = NetworkError.urlError(code: 400, description: "Test Error")
    
    public init(testDataJsonFileName: String) {
        
        self.testDataJsonFileName = testDataJsonFileName
    }
  
    public func postCart(state: CartState, store: Store<CartState>) -> Action? {
        
        mockCart = state.dataState.editedCart
        
        guard !dispatchErrors else {
            
            return CartDataAction.error(errorToDispatch)
        }
    
        guard let editedCart = state.dataState.editedCart else {
            return nil
        }
        
        return DataAction.edit(data: editedCart)
    }
    
    // Mock Store
    private var mockCart: CartDomainModel?
    
    public func getCart(state: CartState, store: Store<CartState>) -> Action? {
        
        guard !dispatchErrors else {
            
            return CartDataAction.error(errorToDispatch)
        }
        
        if let mockCart = mockCart {
            
            return DataAction.set(data: mockCart)
        }
        
        guard
            let bundle = Bundle(for: MockCartDataService.self).path(forResource: "PoqCartTests", ofType: "bundle").flatMap({ Bundle(path: $0) }),
            let cartItemsFilePath = bundle.path(forResource: testDataJsonFileName, ofType: "json"),
            let cartItemsFile = FileManager.default.contents(atPath: cartItemsFilePath)
            else {
                assertionFailure("Failed to read \(testDataJsonFileName)")
                return nil
        }
        
        guard let cartNetworkModel = try? JSONDecoder().decode(Cart.self, from: cartItemsFile) else {
            
            fatalError("Could not decode Cart from Test Data")
        }
        
        let cart = CartDomainModelMapper().map(from: cartNetworkModel)
        return DataAction.set(data: cart)
    }
}
