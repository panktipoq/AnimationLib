//
//  OfferListViewModel.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 05/01/2017.
//
//

import Foundation
import PoqNetworking

class OfferListViewModel: PoqOfferListService {
    
    weak var presenter: PoqOfferListPresenter?
    var offers: [PoqOffer]?
    var content: [PoqOfferListContentItem]?
}
