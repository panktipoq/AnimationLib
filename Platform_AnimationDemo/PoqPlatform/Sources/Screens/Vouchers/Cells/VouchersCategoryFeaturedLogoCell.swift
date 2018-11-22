//
//  VouchersCategoryFeaturedLogoCell.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 1/23/17.
//
//

import PoqNetworking
import UIKit

open class VouchersCategoryFeaturedLogoCell: UICollectionViewCell, VouchersCategoryFeaturedResuableView {
    
    @IBOutlet open weak var logoView: UIImageView?
    
    open weak var presenter: VouchersCategoryPresenter?
    
    open func setup(using content: VouchersCategoryFeaturedContent, with voucher: PoqVoucherV2?) { }
    
}
