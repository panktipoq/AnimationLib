//
//  CheckoutSelectPaymentOptionCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 19/07/2016.
//
//

import Foundation
import PoqUtilities
import UIKit

public protocol PaymentOptionCellDelegate: AnyObject {
    func deleteButtonPressed(onItem item: PaymentOptionItem)
}

open class CheckoutSelectPaymentOptionCell: UITableViewCell, TableCheckoutFlowStepOverViewCell {
    
    weak var delegate: PaymentOptionCellDelegate?
    
    // Fist time add card
    @IBOutlet weak var firstTimeAddCardView: UIView?
    @IBOutlet weak var firstTimeAddCardLabel: UILabel?
    
    // CARD View
    @IBOutlet weak var cardView: UIView?
    @IBOutlet weak var cardNumberLabel: UILabel?
    @IBOutlet weak var cardTypeLabel: UILabel?
    @IBOutlet weak var cardImageView: PoqAsyncImageView?
    @IBOutlet weak var labelVerticalDistance: NSLayoutConstraint?
    
    // PAYPAL View
    @IBOutlet weak var payPalView: UIView?
    @IBOutlet weak var payPalTextLabel: UILabel?
    @IBOutlet weak var payPalLogoImage: UIImageView?
    
    public static let reuseIdentifier: String = "CheckoutSelectPaymentOptionCell"
    public static let nibName: String = "CheckoutSelectPaymentOptionCell"
    
    fileprivate var isPaymentSourceSelected: Bool = false
    fileprivate var item: PaymentOptionItem?

    override open func awakeFromNib() {

        super.awakeFromNib()

        firstTimeAddCardLabel?.text = "PAYMENT_SELECTION_FIRST_TIME_ADD_CARD".localizedPoqString
        firstTimeAddCardView?.isHidden = true
        
        let deleteButton = UIButton(type: UIButtonType.custom)
        deleteButton.setImage(ImageInjectionResolver.loadImage(named: "CheckoutDelete"), for: UIControlState())

        deleteButton.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 44, height: 44))
        deleteButton.addTarget(self, action: #selector(CheckoutSelectPaymentOptionCell.deleteButtonAction(_:)), for: .touchUpInside)
        deleteButton.contentHorizontalAlignment = .right
        
        editingAccessoryView = deleteButton
        
        shouldIndentWhileEditing = false
    }
    
    open func setPaymentOptionItem(_ item: PaymentOptionItem, selected: Bool = false) {
        
        self.item = item
        
        switch item.method {
        case .Card:
            
            if let validSource = item.paymentSource {
                setupCard(validSource.presentation, selected: selected)
            } else {
                // '+' cell
                if item.isOnlyAddItemForWholeMethodSection {
                    setupAsFirstTimeAddCard()
                } else {
                    setupAddCard()
                }
            }
        case .PayPal:
            setupPayPal(item.paymentSource != nil, selected: selected)
            
        case .Klarna:
            setupKlarna(selected)
            
        default:
            Log.error("Some unexpected method: \(item.method)")
            setupAddCard()
        }
        updateAccessoryView()
    }
    
    @objc open func deleteButtonAction(_ sender: UIButton) {
        guard let validItem = item else {
            return
        }
        delegate?.deleteButtonPressed(onItem: validItem)
    }
}

// MARK: - Private
extension CheckoutSelectPaymentOptionCell {
    
    fileprivate final func updateAccessoryView() {
        guard !isEditing else {
            return
        }
        accessoryType = isPaymentSourceSelected ? .checkmark : .none
    }

    fileprivate final func setupAsFirstTimeAddCard() {
        firstTimeAddCardView?.isHidden = false
        payPalView?.isHidden = true
        cardView?.isHidden = true
        
        isPaymentSourceSelected = false
    }
    
    fileprivate final func setupAddCard() {
        firstTimeAddCardView?.isHidden = true
        payPalView?.isHidden = true
        cardView?.isHidden = false
        // FIXME: localize
        cardNumberLabel?.text = "Add new card"
        cardTypeLabel?.text = nil
        labelVerticalDistance?.constant = 0
        
        cardImageView?.prepareForReuse()
        cardImageView?.image = ImageInjectionResolver.loadImage(named: "AddCardIcon")
        
        isPaymentSourceSelected = false
    }
    
    fileprivate final func setupCard(_ paymentSource: PoqPaymentSourcePresentation, selected: Bool = false) {
        
        firstTimeAddCardView?.isHidden = true
        payPalView?.isHidden = true
        cardView?.isHidden = false
        
        let twoLinePresentation: TwoLinePaymentSourcePresentation = paymentSource.twoLinePresentation
        
        cardNumberLabel?.text = twoLinePresentation.firstLine
        cardTypeLabel?.text = twoLinePresentation.secondLine
        
        labelVerticalDistance?.constant = 8
        
        if let imageUrlString = paymentSource.paymentMethodIconUrl, let imageURL = URL(string: imageUrlString) {
            cardImageView?.getImageFromURL(imageURL, isAnimated: false, showLoadingIndicator: true, resetConstraints: false, completion: { [weak self] (image: UIImage?) in
                if let cgImage: CGImage = image?.cgImage {
                    self?.cardImageView?.image = UIImage(cgImage: cgImage, scale: 2.0, orientation: UIImageOrientation.up)
                }
                })
        } else if let icon = paymentSource.cardIcon {
            cardImageView?.image = icon
        } else {
            cardImageView?.prepareForReuse()
        }
        isPaymentSourceSelected = selected
    }
    
    fileprivate final func setupPayPal(_ existedAccount: Bool, selected: Bool = false) {
        firstTimeAddCardView?.isHidden = true
        cardView?.isHidden = true
        payPalView?.isHidden = false
        payPalTextLabel?.text = existedAccount ? "" : "Sign In with "
        payPalLogoImage?.image = ImageInjectionResolver.loadImage(named: "PayPalLogo")
        isPaymentSourceSelected = selected
    }
    
    fileprivate final func setupKlarna(_ selected: Bool = false) {
        firstTimeAddCardView?.isHidden = true
        cardView?.isHidden = true
        payPalView?.isHidden = false
        payPalTextLabel?.text = "CHECKOUT_WITH_KLARNA".localizedPoqString
        payPalLogoImage?.image = ImageInjectionResolver.loadImage(named: "KlarnaLogo")
        isPaymentSourceSelected = selected
    }
}
