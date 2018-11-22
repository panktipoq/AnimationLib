//
//  VouchersCategoryContent.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 1/5/17.
//
//

import PoqNetworking
import UIKit

public protocol VouchersCategoryResuableView: PoqReusableView {
    
    var presenter: VouchersCategoryPresenter? { get set }
    func setup(using content: VouchersCategoryContent, with category: PoqVoucherCategory?)
    
}

public enum VouchersCategoryContentType {
    
    case header
    case section
    case element
    
    var cellIdentifier: String {
        
        switch self {
            
        case .header:
            return VouchersCategoryHeaderCell.poqReuseIdentifier
            
        case .section:
            return VouchersCategorySectionHeaderCell.poqReuseIdentifier
            
        case .element:
            return VouchersCategoryElementCell.poqReuseIdentifier
            
        }
    }
    
    var height: CGFloat {
        
        switch self {
            
        case .header:
            return 140.0
            
        case .section:
            return 36.0
            
        default:
            return 62.0
        }
        
    }
    
}

public struct VouchersCategoryContent {
    
    public let type: VouchersCategoryContentType
    
}
