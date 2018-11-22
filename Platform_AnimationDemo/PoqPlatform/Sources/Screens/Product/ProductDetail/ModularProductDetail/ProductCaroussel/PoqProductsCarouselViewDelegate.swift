//
//  CarousselProductDelegate.swift
//  Poq.iOS.Platform
//
//  Created by Mohamed Arradi-Alaoui on 19/05/2017.
//
//

import Foundation

public protocol PoqProductsCarouselViewDelegate: AnyObject {
    
    /// Will be called in 2 cases: 
    /// - app clear all recently viewed
    /// - after db/api loading we find no produts to be shown
    func productsCarouselViewDidClearItems(_ view: PoqProductsCarouselView)
}
