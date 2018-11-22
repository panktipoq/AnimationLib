//
//  CheckoutPanelView.swift
//  PoqCart
//
//  Created by Balaji Reddy on 21/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import UIKit
import PassKit

/**
 
    This protocol represents a type that can present the Checkout panel information
 */
public protocol CheckoutPanelViewPresentable {
    var delegate: CartPresenter? { get set }
    func setup(numOfItems: Int, totalPrice: String)
    var isCheckoutEnabled: Bool { get set }
    var isUserLoggedIn: Bool { get set }
    func setEditMode(to editing: Bool, animate: Bool)
    func toggleInternalHeightConstraints(collapse: Bool)
}

/**
    This is the concrete platform implementation of the CheckoutPanelViewRepresentable protocol.
 
    It displays a checkout button, the number of items and the cart total
 */
public class CheckoutPanelView: UIView, CheckoutPanelViewPresentable {

    public static let accessibilityId = "CheckoutPanelView"
    public static let numOfItemsLabelAccessibilityId = "CheckoutPanelViewNumOfItemsLabelAccessibilityId"
    public static let totalPriceLabelAccessibilityId = "CheckoutPanelviewTotalPriceLabelAccessibilityId"
    public static let checkoutButtonAccessibilityId = "CheckoutPanelViewCheckoutButtonAccessibilityId"
    public static let payWithCardButtonAccessibilityId = "CheckoutPanelViewPayWithCardButtonAccessibilityId"
    public static let applePayButtonAccessibilityId = "CheckoutPanelViewApplePayButtonAccessibilityId"
    
    var checkoutButton: UIButton!
    
    var payWithCardButton: UIButton!
    // TODO: Integrate with Apple Pay
    var applePayButton: UIButton?
    
    var numberOfItemsLabel: UILabel!
    var totalPriceLabel: UILabel!
    var separator: UIView!
    
    var decorator: CheckoutPanelDecoratable?
    
    public var delegate: CartPresenter?
    
    public var isCheckoutEnabled: Bool = true {
        didSet {
            checkoutButton.isEnabled = isCheckoutEnabled
        }
    }
    
    public var isUserLoggedIn: Bool = false {
        
        didSet {
            
            updateCheckoutButtons()
        }
    }
    
    init(frame: CGRect, decorator: CheckoutPanelDecoratable) {
          
        checkoutButton = UIButton(type: .custom)
        checkoutButton.setTitle("Checkout Securely", for: .normal)
        checkoutButton.accessibilityIdentifier = CheckoutPanelView.checkoutButtonAccessibilityId

        payWithCardButton = UIButton(type: .custom)
        payWithCardButton.setTitle("Pay With Card", for: .normal)
        payWithCardButton.accessibilityIdentifier = CheckoutPanelView.payWithCardButtonAccessibilityId
        
        applePayButton = PKPaymentButton()
        applePayButton?.accessibilityIdentifier = CheckoutPanelView.applePayButtonAccessibilityId
        
        numberOfItemsLabel = UILabel(frame: CGRect.zero)
        numberOfItemsLabel?.accessibilityIdentifier = CheckoutPanelView.numOfItemsLabelAccessibilityId
        
        totalPriceLabel = UILabel(frame: CGRect.zero)
        totalPriceLabel?.accessibilityIdentifier = CheckoutPanelView.totalPriceLabelAccessibilityId
        
        separator = UIView(frame: CGRect.zero)
        
        self.decorator = decorator
        super.init(frame: frame)
        accessibilityIdentifier = CheckoutPanelView.accessibilityId
        
        checkoutButton.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)
        payWithCardButton.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        setStyles()
        addSubview(separator)
        addSubview(checkoutButton)
        addSubview(payWithCardButton)
        if let applePayButton = applePayButton {
            addSubview(applePayButton)
        }
        addSubview(numberOfItemsLabel)
        addSubview(totalPriceLabel)
        
        self.decorator?.layout(checkoutPanelView: self)
    }
    
    func setStyles() {
        checkoutButton.titleLabel?.textColor = UIColor.white
        checkoutButton.backgroundColor = UIColor(displayP3Red: 0.89, green: 0.28, blue: 0.36, alpha: 1.0)
        checkoutButton.layer.cornerRadius = 5
        
        payWithCardButton.titleLabel?.textColor = UIColor.white
        payWithCardButton.backgroundColor = UIColor(displayP3Red: 0.89, green: 0.28, blue: 0.36, alpha: 1.0)
        payWithCardButton.layer.cornerRadius = 5
        
        separator.backgroundColor = UIColor(red: 0.48, green: 0.48, blue: 0.48, alpha: 1.0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setup(numOfItems: Int, totalPrice: String) {
   
        numberOfItemsLabel.text = String(numOfItems) + (numOfItems > 1 ? " Items" : " Item")
        totalPriceLabel.text = "Total: " + totalPrice
    }
    
    @objc func checkoutButtonTapped(sender: UIButton) {
        
        delegate?.checkoutButtonTapped()
    }
    
    open func updateCheckoutButtons() {

        checkoutButton.isHidden = isUserLoggedIn
        payWithCardButton?.isHidden = !isUserLoggedIn
        applePayButton?.isHidden = !isUserLoggedIn
    }
    
    open func setEditMode(to editing: Bool, animate: Bool) {
        
        totalPriceLabel.textColor = editing ? UIColor.hexColor("#D6D6D6") : UIColor.black
    }
    
    open func toggleInternalHeightConstraints(collapse: Bool) {
        
        decorator?.toggleInternalHeightConstraints(checkoutPanelView: self, collapse: collapse)
    }
}
