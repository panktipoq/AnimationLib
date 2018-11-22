//
//  QuantityView.swift
//  PoqCart
//
//  Created by Balaji Reddy on 25/06/2018.
//

import Foundation
import UIKit
import PoqUtilities
import PoqPlatform

/**
    This protocol represents a view that presents the quantity of a BagItem
*/
protocol QuantityViewPresentable: ViewEditable {
    
    var editQuantityAction: ((Int) -> Void)? { get set }
    
    func setup(with quantity: Int, price: String)
}

/**
 
    This is the concrete platform implementation of the QuantityViewPresentable protocol.
 
    It is a view that presents the quantity of a Bag item.
 
    It displays the quantity in the format "2 x £20.00" and displays a text field and buttons to increase/decrease the quantity in edit mode.
 
*/
class QuantityView: UIView, QuantityViewPresentable {
    
    public static let increaseButtonAccessibilityId = "IncreaseQuantityButton"
    public static let decreaseButtonAccessibilityId = "DecreaseQuantityButton"
    
    var quantityLabel: UILabel? = UILabel(frame: CGRect.zero)
    var quantityTextField: UITextField? = UITextField(frame: CGRect.zero)
    var increaseButton: UIButton? = UIButton(type: .custom)
    var decreaseButton: UIButton? = UIButton(type: .custom)
    var decorator: QuantityViewDecoratable
    
    var currentQuantity: Int?
    var price: String?
    
    var editQuantityAction: ((Int) -> Void)?
    
    /// Designated initialiser for the class
    ///
    /// - Parameters:
    ///   - frame: The frame of the class
    ///   - decorator: The decorator that will add the constraints for the class. Defaults to QuantityViewDecorator()
    init(frame: CGRect, decorator: QuantityViewDecoratable = QuantityViewDecorator()) {
        
        self.decorator = decorator
        
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        guard
            let quantityLabel = quantityLabel,
            let quantityTextField = quantityTextField,
            let increaseButton = increaseButton,
            let decreaseButton = decreaseButton
            else {
                Log.error("quantityLabel or quantityTextField not initialised")
                return
        }
        
        setQuantityLabelStyle(quantityLabel)
        addSubview(quantityLabel)
        
        setQuantityTextFieldStyle(quantityTextField)
        addSubview(quantityTextField)
        
        setIncreaseButtonStyle(increaseButton)
        addSubview(increaseButton)
        
        setDecreaseButtonStyle(decreaseButton)
        addSubview(decreaseButton)
        
        decorator.layout(quantityView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Setup the style of the quantity label
    ///
    /// - Parameter quantityLabel: The quantity label
    open func setQuantityLabelStyle(_ quantityLabel: UILabel) {
        
        quantityLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        quantityLabel.textColor = UIColor.gray
    }
    
    /// Setup the style of the quantity text field
    ///
    /// - Parameter quantityTextField: The quantity text field
    open func setQuantityTextFieldStyle(_ quantityTextField: UITextField) {
        
        quantityTextField.textAlignment = .center
        quantityTextField.alpha = 0
        quantityTextField.isHidden = true
    }
    
    /// Setup the style of the increase quantity button
    ///
    /// - Parameter increaseButton: The increase quantity button
    open func setIncreaseButtonStyle(_ increaseButton: UIButton) {
        
        increaseButton.setBackgroundImage(ImageInjectionResolver.loadImage(named: "PlusButtonDefault"), for: .normal)
        increaseButton.addTarget(self, action: #selector(quantityEdited), for: .touchUpInside)
        increaseButton.isHidden = true
        increaseButton.alpha = 0
        increaseButton.accessibilityIdentifier = QuantityView.increaseButtonAccessibilityId
    }
    
    /// Setup the style of the decrease quantity button
    ///
    /// - Parameter decreaseButton: The decrease quantity button
    open func setDecreaseButtonStyle(_ decreaseButton: UIButton) {
        
        decreaseButton.setBackgroundImage(ImageInjectionResolver.loadImage(named: "MinusButtonDefault"), for: .normal)
        decreaseButton.addTarget(self, action: #selector(quantityEdited), for: .touchUpInside)
        decreaseButton.isHidden = true
        decreaseButton.alpha = 0
        decreaseButton.accessibilityIdentifier = QuantityView.decreaseButtonAccessibilityId
    }
    
    /// A QuantityViewPresentable protocol method used to setup the QuantityView
    ///
    /// - Parameters:
    ///   - quantity: The quantity to be displayed
    ///   - price: The price to be displayed
    open func setup(with quantity: Int, price: String) {
        
        decreaseButton?.isEnabled = quantity > 1
        
        currentQuantity = quantity
        self.price = price
        
        updateQuantityLabels()
    }
    
    @objc func quantityEdited(sender: UIButton) {
        
        guard var currentQuantity = currentQuantity else {
            
            Log.error("CurrentQuantity is nil")
            return
        }
        
        switch sender {
        case increaseButton:
            
            currentQuantity += 1
            decreaseButton?.isEnabled = true
            
        case decreaseButton:
            
            guard currentQuantity >= 1 else {
                return
            }
            
            currentQuantity -= 1
            
            decreaseButton?.isEnabled = currentQuantity > 1
            
        default:
            
            break
        }
        
        self.currentQuantity = currentQuantity
        
        updateQuantityLabels()
        
        setNeedsLayout()
        
        // Dispatch in next run loop after the quantity has been updated.
        DispatchQueue.main.async {
            self.editQuantityAction?(currentQuantity)
        }
    }
    
    func updateViews(editing: Bool) {
        
        quantityLabel?.isHidden = editing
        quantityLabel?.alpha = editing ? 0 : 1
        
        quantityTextField?.isHidden = !editing
        quantityTextField?.alpha = editing ? 1 : 0
        
        increaseButton?.isHidden = !editing
        increaseButton?.alpha = editing ? 1 : 0
        
        decreaseButton?.isHidden = !editing
        decreaseButton?.alpha = editing ? 1 : 0
    }
    
    private func updateQuantityLabels() {
        
        guard let currentQuantity = currentQuantity else {
            Log.error("CurrentQuantity is nil. Cannot update labels")
            return
        }
        
        if let priceString = price {
            quantityLabel?.text = "\(currentQuantity) X \(priceString)"
        }
        
        quantityTextField?.text = String(currentQuantity)
    }
    
    /// The ViewEditable method to set the QuantityView in edit mode
    ///
    /// - Parameters:
    ///   - editing: A boolean indicating if the screen is in edit mode
    ///   - animate: A boolean indicating if the change to edit mode is animated
    open func setEditMode(to editing: Bool, animate: Bool) {
        
        if animate {
            
            UIView.animate(withDuration: 0.5, animations: {
                self.updateViews(editing: editing)
            })
        } else {
            
            updateViews(editing: editing)
        }
    }
}
