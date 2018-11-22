//
//  PoqVoucherListContentItem.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 31/12/2016.
//
//

import Foundation
import PoqNetworking

protocol PoqVoucherListReusableView: PoqReusableView {
    var presenter: PoqVoucherListPresenter? { get set }
    func setup(using content: PoqVoucherListContentItem)
}

public enum PoqVoucherListContentItemType {
    case info
    
    public var cellIdentifier: String {
        
        switch self {
            
        case .info:
            return VoucherListViewCell.poqReuseIdentifier
            
        }
    }
}

public struct PoqVoucherListContentItem {
    
    public var type: PoqVoucherListContentItemType
    public var voucher: PoqVoucherV2
}
