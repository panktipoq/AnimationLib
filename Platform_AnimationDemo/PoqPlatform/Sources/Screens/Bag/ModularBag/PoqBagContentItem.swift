//
//  PoqBagContentItem.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 12/01/2017.
//
//

import Foundation
import PoqNetworking

public protocol PoqBagCell: PoqReusableView {
    
    /// This should be weak.
    var presenter: PoqBagPresenter? { get set }
    
    func setup(using content: PoqBagContentItem)
}

public protocol PoqBagCellTypeProvider {
    var cellClass: UICollectionViewCell.Type { get }
}

public enum PoqBagContentItemType: PoqBagCellTypeProvider {
    case message(message: String)
    case bagItemCard(bagItem: PoqBag)
    case link(linkTitle: String, linkUrl: String)
    case voucherCard(vouchers: [PoqVoucherV2])
    case orderSummaryCard
    
    public var cellClass: UICollectionViewCell.Type {
        switch self {
        default:
            return UICollectionViewCell.self
        }
    }
}

public struct PoqBagContentItem {
   public var cellType: PoqBagCellTypeProvider
    
   public init (cellType: PoqBagCellTypeProvider) {
        self.cellType = cellType
    }
}
