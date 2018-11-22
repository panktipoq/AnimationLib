//
//  VouchersCategoryElementCell.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 12/27/16.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

open class VouchersCategoryElementCell: UICollectionViewCell, VouchersCategoryResuableView {

    @IBOutlet open weak var titleLabel: UILabel?
    @IBOutlet open weak var countLabel: UILabel?
    weak open var presenter: VouchersCategoryPresenter?
    
    open func setup(using content: VouchersCategoryContent, with category: PoqVoucherCategory?) {
        
        guard let category = category else {
            
            Log.error("Product data is not found. Cell setup is skipped")
            return
        }
        
        isUserInteractionEnabled = true
        
        titleLabel?.textColor = AppTheme.sharedInstance.vouchersCategoryElementCellTitleColor
        countLabel?.textColor = AppTheme.sharedInstance.vouchersCategoryElementCellCountLabelColor
        
        titleLabel?.text = category.title
        if let voucherCount = category.voucherCount {
            countLabel?.text = String(voucherCount)
            
            if voucherCount == 0 {
                isUserInteractionEnabled = false
                
                titleLabel?.textColor = titleLabel?.textColor.withAlphaComponent(0.7)
                countLabel?.textColor = countLabel?.textColor.withAlphaComponent(0.7)
            }
        } else {
            countLabel?.text = ""
        }
    }

}
