//
//  VouchersCategoryFeaturedCell.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 12/27/16.
//
//

import PoqNetworking
import UIKit

open class VouchersCategoryFeaturedCell: UICollectionViewCell, VouchersCategoryFeaturedResuableView {

    @IBOutlet open weak var discountValueLabel: UILabel?
    @IBOutlet open weak var nameLabel: UILabel?
    @IBOutlet open weak var endDateExpirationLabel: UILabel?
    
    open weak var presenter: VouchersCategoryPresenter?
    
    open func setup(using content: VouchersCategoryFeaturedContent, with voucher: PoqVoucherV2?) {
        guard let featuredVoucher = voucher else {
            return
        }
        
        updateDiscountValueLabel(featuredVoucher)
        updateNameLabel(featuredVoucher)
        updateExpirationLabel(featuredVoucher)
    }
    
    func updateDiscountValueLabel(_ voucher: PoqVoucherV2) {
        discountValueLabel?.text = voucher.discountValue
    }
    
    func updateNameLabel(_ voucher: PoqVoucherV2) {
        nameLabel?.text = voucher.name
    }
    
    func updateExpirationLabel(_ voucher: PoqVoucherV2) {
        endDateExpirationLabel?.attributedText = expirationString(voucher)
    }
    
    func expirationString(_ voucher: PoqVoucherV2) -> NSAttributedString {
        guard let endDateStringValue = voucher.endDate else {
            return NSAttributedString(string: "")
        }
        
        let endDateString = getFormattedEndDate(endDateStringValue)
        
        let attributedEndDateString = NSMutableAttributedString(string: endDateString)
        
        if voucher.isExpiringSoon == true {
            
            attributedEndDateString.mutableString.append("   \("Expires soon".localizedPoqString)")
            let fontSize = endDateExpirationLabel?.font.pointSize ?? 0
            let attributes = [
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize),
                NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.vouchersCategoryExpiresSoonTextColor
            ] 
            
            let range = (attributedEndDateString.mutableString as NSString).range(of: "Expires soon".localizedPoqString)
            
            attributedEndDateString.addAttributes(attributes, range: range)
        }
        
        return attributedEndDateString
    }
    
    struct Static {
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            
            return formatter
        }()
    }
    
    func getFormattedEndDate(_ endDate: String) -> String {
        var dateToDisplay = endDate
        
        let endDateFormat = AppSettings.sharedInstance.voucherEndDateFormat
        let endDateDisplayFormat = AppSettings.sharedInstance.voucherEndDateDisplayFormat
        
        if let formattedDate = Static.dateFormatter.formatFromUTCToLocal(endDate, fromFormat: endDateFormat, toFormat: endDateDisplayFormat) {
            dateToDisplay = formattedDate
        }
        
        return String(format: AppSettings.sharedInstance.voucherListEndDateFormatString, dateToDisplay)
    }
}
