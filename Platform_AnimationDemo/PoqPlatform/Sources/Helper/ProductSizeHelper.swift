//
//  ProductSizeHelper.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 14/09/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking

public class ProductSizeHelper {
    
    public func findSelectedSize(withId sizeId: Int?, inProduct product: PoqProduct?) -> PoqProductSize? {
        guard let sizeId = sizeId, let product = product else {
            return nil
        }
        
        return product.productSizes?.first(where: { $0.id == sizeId })
    }

    public init() {}
}
