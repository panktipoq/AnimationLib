//
//  PoqCarousselPresenter.swift
//  Poq.iOS.Platform
//
//  Created by Mohamed Arradi on 15/05/2017.
//
//

import Foundation
import UIKit

public protocol PoqProductsCarouselPresenter: PoqPresenter {
    
    var collectionView: UICollectionView? { get }
    
    var rightDetailButton: UIButton? { get }
    
    var titleLabel: UILabel? { get }
    
    var viewModel: PoqProductsCarouselService? { get }
    
    func updateProductCarousel()
}

extension PoqProductsCarouselPresenter {
    
    weak public var rightDetailButton: UIButton? {
        return nil
    }
    
    weak public var titleLabel: UILabel? {
        return nil
    }
    
    public func updateProductCarousel() {
        collectionView?.reloadData()
    }
}
