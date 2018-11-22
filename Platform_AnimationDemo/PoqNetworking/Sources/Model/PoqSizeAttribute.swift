//
//  PoqProductSizeAttribute.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 08/09/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import ObjectMapper

// Used for Magento Enterprise TODO: We need to check on backend what this does and if it's still in use. Platform doesn't use it
open class PoqProductSizeAttribute : Mappable {
    
    /// The id of the size attribute
    open var attributeId:String?
    
    /// The option id for the selected size attribute
    open var optionId:String?
    
    /// The related attribute id to this attribute id
    open var relatedAttributeId:String?
    
    /// The retlated option id of the size attribute
    open var relatedOptionId:String?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    open func mapping(map: Map) {
        
        attributeId <- map["attributeId"]
        optionId <- map["optionId"]
        relatedAttributeId <- map["relatedAttributeId"]
        relatedOptionId <- map["relatedOptionId"]
    }
    
}
