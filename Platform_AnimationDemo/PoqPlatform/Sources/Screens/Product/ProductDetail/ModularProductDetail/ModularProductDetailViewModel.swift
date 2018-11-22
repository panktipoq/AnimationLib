//
//  ModularProductDetailViewModel.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Mahmut Canga on 21/12/2016.
//
//

import Foundation
import PoqNetworking

/**
 
 ModularProductDetailViewModel is the viewmodel that handles data flow for the ModularProductDetailViewController. 
 It has a weak reffrence to the presenter
 ## Usage Example: ##
 ````
 open func getService() -> PoqProductDetailService {

     let service = ModularProductDetailViewModel()
         service.presenter = self
         return service
 }
 ````
 */

open class ModularProductDetailViewModel: PoqProductDetailService {
    
    /// The presenter that handles the rendering of the product details.
    weak public var presenter: PoqProductDetailPresenter?
    /// The product who's details are to be rendered.
    public var product: PoqProduct?
    /// The array of content items from which the modular pdp is generated.
    public var content = [PoqProductDetailContentItem]()
    
}
