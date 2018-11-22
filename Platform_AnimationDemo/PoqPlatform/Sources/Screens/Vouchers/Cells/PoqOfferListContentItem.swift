//
//  PoqOfferListContentItem.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 05/01/2017.
//
//

import Foundation
import PoqNetworking

protocol PoqOfferListReusableView: PoqReusableView {
    var presenter: PoqOfferListPresenter? { get set }
    func setup(using content: PoqOfferListContentItem)
}

public enum PoqOfferListContentItemType {
    case info
    
    public var cellIdentifier: String {
        
        switch self {
            
        case .info:
            return OfferListViewCell.poqReuseIdentifier
        }
    }
}

public struct PoqOfferListContentItem {
    
    public var type: PoqOfferListContentItemType
    public var offer: PoqOffer
}
