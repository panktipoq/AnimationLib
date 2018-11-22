//
//  LookbookHotspotDetailViewModel.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 29/03/2016.
//
//

import PoqNetworking
import UIKit

class LookbookHotspotDetailViewModel: BaseViewModel {
    
    var product: PoqProduct?
    
    let productId: Int
    
    init(productId: Int, viewControllerDelegate: PoqBaseViewController) {
        
        self.productId = productId;
        super.init(viewControllerDelegate: viewControllerDelegate)
    }

}
