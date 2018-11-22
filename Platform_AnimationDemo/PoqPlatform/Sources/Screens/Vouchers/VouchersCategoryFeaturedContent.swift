//
//  VouchersCategoryFeaturedContent.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 1/5/17.
//
//

import PoqNetworking
import UIKit

public protocol VouchersCategoryFeaturedResuableView: PoqReusableView {
    
    var presenter: VouchersCategoryPresenter? { get set }
    func setup(using content: VouchersCategoryFeaturedContent, with voucher: PoqVoucherV2?)
}

public enum VouchersCategoryFeaturedContentType {
    
    case logo
    case element
    
    var cellIdentifier: String {
        
        switch self {
        
        case .logo:
            return VouchersCategoryFeaturedLogoCell.poqReuseIdentifier
        case .element:
            return VouchersCategoryFeaturedCell.poqReuseIdentifier
        }
    }
}

public struct VouchersCategoryFeaturedContent {
    
    public let type: VouchersCategoryFeaturedContentType
}
