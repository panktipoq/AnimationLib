//
//  MyProfileViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 12/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

open class MyProfileViewModel: PoqMyProfileListService {
    
    public typealias CheckoutItemType = PoqCheckoutItem
    
    weak public var presenter: PoqMyProfileListPresenter?
    open var favoriteStoreId: Int?
    open var loggedOutContent: [PoqMyProfileListContentItem] = []
    open var loggedInContent: [PoqMyProfileListContentItem] = []
    
    required public init() {
        // expose initializer
    }
    
    open func processContent(_ result: [Any]?) {
        
        guard let networkResults = result as? [PoqBlock], networkResults.count > 0 else {
            
            return
        }
        parseBlocksToContentItems(networkResults)
        
    }
    
}
