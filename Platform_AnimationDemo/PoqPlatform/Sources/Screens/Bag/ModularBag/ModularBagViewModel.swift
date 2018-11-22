//
//  ModularBagViewModel.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 11/01/2017.
//
//

import Foundation
import PoqNetworking

class ModularBagViewModel: PoqBagService {
    
    weak var presenter: PoqBagPresenter?
    var bag: PoqBag?
    lazy var content: [PoqBagContentItem] = [PoqBagContentItem]()
    
    func bagCheckout() {
        // Empty for the time being in platform. This should be implemented in the future.
    }
}
