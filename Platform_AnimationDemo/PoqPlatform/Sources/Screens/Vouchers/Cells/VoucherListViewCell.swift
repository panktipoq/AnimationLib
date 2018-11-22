//
//  VoucherListViewCell.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 28/12/2016.
//
//

import Foundation
import PoqNetworking
import UIKit

open class VoucherListViewCell: UICollectionViewCell, PoqVoucherListReusableView {
    
    @IBOutlet var discountLabel: UILabel?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var endDateLabel: UILabel?
    @IBOutlet var isExpiringSoon: UILabel?
    @IBOutlet var applyButton1: UIButton?
    @IBOutlet var applyButton2: UIButton?
    @IBOutlet var transparentButton: UIButton?
    
    weak var presenter: PoqVoucherListPresenter?
    
    var applyToBagButton: UIButton?
    
    var voucher: PoqVoucherV2? {
        didSet {
            
           if voucher == nil {
                discountLabel?.text = nil
                nameLabel?.text = nil
                endDateLabel?.text = nil
                isExpiringSoon?.isHidden = true
                applyButton1?.isHidden = true
                applyButton2?.isHidden = true
            }
            
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        voucher = nil
    }
    override open func prepareForReuse() {
        super.prepareForReuse()
        voucher = nil
    }
    
    func setup(using content: PoqVoucherListContentItem) {
      
        voucher = content.voucher
        discountLabel?.text = content.voucher.discountValue
        nameLabel?.text = content.voucher.name
        
        if let endDate = content.voucher.endDate {
           setupEndDate(endDate)
        }
        
        isExpiringSoon?.isHidden = !(content.voucher.isExpiringSoon ?? false)
        
        transparentButton?.addTarget(self, action: #selector(openVoucherDetails), for: .touchUpInside)
        
        setupApplyButtons()
        
    }
    
    func setupEndDate(_ endDate: String) {
        let dateFormatter = DateFormatter()
        let endDateFormat = AppSettings.sharedInstance.voucherEndDateFormat
        let endDateDisplayFormat = AppSettings.sharedInstance.voucherEndDateDisplayFormat
        
        var dateToDisplay = endDate
        if let formattedDate = dateFormatter.formatFromUTCToLocal(endDate, fromFormat: endDateFormat, toFormat: endDateDisplayFormat) {
            dateToDisplay = formattedDate
        }
        
        endDateLabel?.text = String(format: AppSettings.sharedInstance.voucherListEndDateFormatString, dateToDisplay)
    }
    
    func setupApplyButtons() {

        let useInStoreButtonTitle = AppLocalization.sharedInstance.voucherListUseInStoreButtonTitle
        
        let isInStore = voucher?.isInStore ?? false
        let isOnline = voucher?.isOnline ?? false
        
        if isInStore {
            
            if let useInStoreButtonStyle = ResourceProvider.sharedInstance.clientStyle?.useInStoreButtonStyle {
                applyButton1?.configurePoqButton(withTitle: useInStoreButtonTitle, using: useInStoreButtonStyle)
            }
            applyButton1?.addTarget(self, action: #selector(openVoucherDetails), for: .touchUpInside)
            applyButton1?.isHidden = false
            
        }
        
        if isInStore && isOnline {
            
            setupApplyToBagButton(applyButton2)
            
        } else if isOnline {
            
            setupApplyToBagButton(applyButton1)
            
        }

    }
    
    func setupApplyToBagButton(_ button: UIButton?) {
       
        let applyToBagButtonTitle = AppLocalization.sharedInstance.voucherListApplyToBagButtonTitle
        
        let style: PoqButtonStyle? = button?.isEnabled == true ? ResourceProvider.sharedInstance.clientStyle?.applyToBagButtonStyle : ResourceProvider.sharedInstance.clientStyle?.useInStoreButtonStyle
        
        if let applyToBagButtonStyle = style {
            button?.configurePoqButton(withTitle: applyToBagButtonTitle, using: applyToBagButtonStyle)
        }
        
        button?.addTarget(self, action: #selector(applyToBagButtonClicked), for: .touchUpInside)
        button?.isExclusiveTouch = true
        button?.adjustsImageWhenDisabled = true
        applyToBagButton = button
        button?.isHidden = false
        
    }
    
    @objc func applyToBagButtonClicked(_ button: UIButton) {
        guard let voucher = voucher else {
            return
        }
        
        presenter?.applyVoucherToBag(voucher)
    }
    
    @objc func openVoucherDetails(_ sender: AnyObject, forEvent event: UIEvent) {
        
        guard let voucherId = voucher?.id, let button = sender as? UIButton else {
            return
        }
        
        //This check is to ensure that a touch on a disabled applyToBagButton passed to the underlying transparent button does not open detail view
        //Currently there's no way to prevent the touches on a disabled button from being sent up the responder chain
        if let applyToBagButton = applyToBagButton {
            let touches = event.touches(for: button)
            let touch = touches?.first
            if let pointOfTouch = touch?.location(in: applyToBagButton), applyToBagButton.bounds.contains(pointOfTouch) {
                return
            }
        }
        
        presenter?.openVoucherDetail(voucherId)

    }
    
}
