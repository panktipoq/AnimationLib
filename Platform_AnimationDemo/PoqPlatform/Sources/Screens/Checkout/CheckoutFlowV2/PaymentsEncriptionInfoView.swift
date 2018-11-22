//
//  PaymentsEncriptionInfoView.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 20/07/2016.
//
//

import Foundation
import UIKit

public class PaymentsEncriptionInfoView: UIView {
    
    static let Height: CGFloat = 50.0
    
    @IBOutlet var contentView: UIView?
    
    @IBOutlet weak var infoTextLabel: UILabel?
    @IBOutlet weak var iconImageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }

}

extension PaymentsEncriptionInfoView {
    fileprivate final func setupView() {
      
        guard contentView == nil else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NibInjectionResolver.findNib("PaymentsEncriptionInfoView")?.instantiate(withOwner: self, options: nil)
        
        if let loadedContent = contentView {
            loadedContent.translatesAutoresizingMaskIntoConstraints = false
            addSubview(loadedContent)
            addConstraints(NSLayoutConstraint.constraintsForView(loadedContent, withInsetsInContainer: UIEdgeInsets.zero))
        }
        
        infoTextLabel?.textColor = AppTheme.sharedInstance.securePaymentInfoLabelColor
        infoTextLabel?.font = AppTheme.sharedInstance.securePaymentInfoLabelFont
        infoTextLabel?.text = AppLocalization.sharedInstance.securePaymentHintInfoText
        
        iconImageView?.image = ImageInjectionResolver.loadImage(named: "PaymentMethodsLockIcon")
        
        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: PaymentsEncriptionInfoView.Height)
        addConstraint(height)
    }
}
