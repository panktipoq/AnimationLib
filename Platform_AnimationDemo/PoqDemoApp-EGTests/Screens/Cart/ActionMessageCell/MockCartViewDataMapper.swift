//
//  MockCartViewDataMapper.swift
//  PoqCart
//
//  Created by Balaji Reddy on 15/07/2018.
//

import Foundation

@testable import PoqCart

struct MockCartViewDataMapper: CartViewDataMappable {
    
    func mapToViewData(_ model: CartDomainModel) -> CartViewDataRepresentable {
        
        var defaultCartViewData = CartViewDataMapper().mapToViewData(model)
        
        if
            let customData = model.customData,
            let encodedJsonData = try? JSONEncoder().encode(customData),
            let decodedJsonData = try? JSONDecoder().decode([String: String].self, from: encodedJsonData),
            let promotionalBanner = decodedJsonData["promotionalBanner"] {
            
            defaultCartViewData.contentBlocks.insert(CartContentBlocks.custom(payload: AnyHashable(promotionalBanner)), at: 0)
        }
        
        return defaultCartViewData
    }
}
