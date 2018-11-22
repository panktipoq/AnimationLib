//
//  PoqFilterRefinement.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 05/02/2016.
//
//

import Foundation
import ObjectMapper

/// The mapped object that contains a refinement. Refinements are used to narrow down products by for example brand
open class PoqFilterRefinement : Mappable {
    
    /// The in app visible text of the refinement (ex. brand)
    open var label: String?
    
    /// The identifier of the refinement
    open var id: String?
    
    /// The values of this particular refinement (ex. a brand name)
    open var values:[PoqFilterRefinementValue]?
   
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map server response to the object
    ///
    /// - Parameter map: The mapped object containing the response from the server
    open func mapping(map: Map) {
        
        label <- map["label"]
        id <- map["id"]
        values <- map["values"]
    }
}
