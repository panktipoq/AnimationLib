//
//  VouchersCategorySectionHeaderCell.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 12/27/16.
//
//

import PoqNetworking
import UIKit

open class VouchersCategorySectionHeaderCell: UICollectionViewCell, VouchersCategoryResuableView {

    @IBOutlet open weak var titleLabel: UILabel?
    weak open var presenter: VouchersCategoryPresenter?
    
    open func setup(using content: VouchersCategoryContent, with category: PoqVoucherCategory?) {
        backgroundColor = AppTheme.sharedInstance.vouchersCategorySectionHeaderCellBackgroundColor
        
        titleLabel?.text = category?.title ?? ""
    }

}
