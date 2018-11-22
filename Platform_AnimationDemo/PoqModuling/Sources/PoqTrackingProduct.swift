//
//  PoqTrackingProduct.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 6/5/17.
//
//

import Foundation

public enum PoqTrackingSource {
    case search(String)
    case category(String)
    case scan(String)

    public var sourceDictionary: [String: String] {
        
        switch self {
            
            case .scan( let source ):
                return ["Scan": source]
            case .search( let source ):
                return ["Search": source]
            case .category( let source ):
                return ["Category": source]
            
        }
    }
    
}

public protocol PoqTrackingProduct {
    
    var title: String? { get }
    var externalID: String? { get }
    
    var price: Double? { get }
    var specialPrice: Double? { get }

    var isClearance: Bool? { get }

}

public protocol PoqTrackingProductSize {

    var sku: String? { get }

    var price: Double? { get }
    var specialPrice: Double? { get }
    
    var isClearance: Bool? { get }

}
