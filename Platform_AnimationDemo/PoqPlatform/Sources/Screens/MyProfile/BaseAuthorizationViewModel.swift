//
//  BaseAuthorizationViewModel.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/26/16.
//
//

import Foundation

/// Declaration of desired API of view model
public protocol BaseAuthorizationViewModel: AnyObject {
    
    /// content which will be presented in UITableView
    var content: [MyProfileContentItem] { get set }

    /**
     Search for a specific type in contents
     */
    func indexOf(itemWithType type: MyProfileContentItemType) -> Int?
}

extension BaseAuthorizationViewModel {

    /**
     Find element with type 'type' in 'content' array.
     - parameter itemWithType: type of queried content
     - returns: Index if element found. If there is more that 1 element - index of first of them will be returned. returns nil if no such content item
     */

    public func indexOf(itemWithType type: MyProfileContentItemType) -> Int? {
        return content.index(where: {
            return $0.type == type
        })
    }
    
    /**
     Find element with type 'type' in 'content' array.
     - parameter typeOf: type of queried content
     - returns: 'MyProfileContentItem' if it was found in array
     */
    public func contentItem(typeOf type: MyProfileContentItemType) -> MyProfileContentItem? {
        let indexOrNil: Int? = content.index(where: {
            return $0.type == type
        })
        
        guard let index = indexOrNil else {
            return nil
        }
        
        return content[index]
    }
}
