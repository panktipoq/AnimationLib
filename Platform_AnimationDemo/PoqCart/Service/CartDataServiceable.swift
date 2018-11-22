//
//  BagDataService.swift
//  PoqCart
//
//  Created by Balaji Reddy on 03/05/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import Foundation
import ReSwift

/**
  This interface represents a type that defines methods that provide the data required by the Bag screen and update the data
 based on any actions performed on the Bag screen.
 
  These methods are ActionCreators that can be dispatched to the store.
 
 Read more about ReSwift and ActionCreators here : [ReSwift - Getting Started](https://reswift.github.io/ReSwift/master/getting-started-guide.html)
 */
public protocol CartDataServiceable {
    
    func getCart(state: CartState, store: Store<CartState>) -> Action?
    func postCart(state: CartState, store: Store<CartState>) -> Action?
}
