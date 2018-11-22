//
//  PoqFilterRefinementValue.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 05/02/2016.
//
//

import Foundation
import ObjectMapper

/// Object containing the 
open class PoqFilterRefinementValue : Mappable {
    
    /// The visible name of the value of the refinement (ex. Gucci)
    open var label: String?
    
    /// The identifier of the refinement value
    open var id: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map json server response to the object
    ///
    /// - Parameter map: The map that contains the json server response
    open func mapping(map: Map) {
        
        label <- map["label"]
        id <- map["id"]
    }
}
