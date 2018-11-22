//
//  EmptyCartView.swift
//  PoqCart
//
//  Created by Balaji Reddy on 13/08/2018.
//

import UIKit
import PoqPlatform

public protocol EmptyCartViewPresentable {
    
    var delegate: CartPresenter? { get set }
    var state: EmptyCartState { get set }
}

public enum EmptyCartState {
    
    case error
    case empty
}

/// This class presents an empty cart view and is presented when the cart has no items in it
public class EmptyCartView: UIView, EmptyCartViewPresentable {
    
    var emptyCartMessageLabel: UILabel
    var emptyCartMessageSubtextLabel: UILabel
    var emptyCartIconImageView: UIImageView
    var actionButton: UIButton
    
    public var state: EmptyCartState  = .empty {
        
        didSet {
            
            setup()
        }
    }
    
    public static let accessibilityID = "EmptyCartView"
    public static let actionButtonAccessibilityID = "EmptyCartViewActionButton"
    public static let messageLabelAccessibilityID = "EmptyCartViewMessageLabel"
    
    public var delegate: CartPresenter?
    
    override public init(frame: CGRect) {
        
        emptyCartMessageLabel = UILabel(frame: CGRect.zero)
        emptyCartMessageSubtextLabel = UILabel(frame: CGRect.zero)
        actionButton = UIButton(frame: CGRect.zero).roundedStyle()
        emptyCartIconImageView = UIImageView(frame: CGRect.zero)
        
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        accessibilityIdentifier = EmptyCartView.accessibilityID
        actionButton.accessibilityIdentifier = EmptyCartView.actionButtonAccessibilityID
        emptyCartMessageLabel.accessibilityIdentifier = EmptyCartView.messageLabelAccessibilityID
        
        addSubview(emptyCartMessageLabel)
        addSubview(emptyCartMessageSubtextLabel)
        addSubview(actionButton)
        addSubview(emptyCartIconImageView)
        
        layout()
        
        setStyles()
        
        setup()
    }
    
    /// This method sets up the EmptyCartView - titles, labels and button actions
    open func setup() {
    
        let showError = state == .error
        
        emptyCartMessageLabel.text = showError ? "CART_ERROR_TITLE".localizedPoqString : "BAG_NO_ITEMS".localizedPoqString
        emptyCartMessageLabel.textAlignment = .left
            
        emptyCartIconImageView.image = showError ? nil : ImageInjectionResolver.loadImage(named: "Pink-Bag")
            
        emptyCartMessageSubtextLabel.text = showError ? nil : "BAG_NO_ITEMS_INSTRUCTIONS".localizedPoqString
        emptyCartMessageSubtextLabel.textAlignment = .center
            
        actionButton.setTitle(showError ? "RETRY".localizedPoqString : "START SHOPPING".localizedPoqString, for: .normal)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    /// This method sets up the constraints of the EmptyCartView
    open func layout() {
        
        emptyCartMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        emptyCartIconImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyCartMessageSubtextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptyCartMessageLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
                emptyCartMessageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                emptyCartIconImageView.trailingAnchor.constraint(equalTo: emptyCartMessageLabel.leadingAnchor, constant: -10.0),
                emptyCartIconImageView.widthAnchor.constraint(equalTo: emptyCartIconImageView.heightAnchor),
                emptyCartIconImageView.widthAnchor.constraint(equalToConstant: 22.0),
                emptyCartIconImageView.centerYAnchor.constraint(equalTo: emptyCartMessageLabel.centerYAnchor),
                actionButton.heightAnchor.constraint(equalToConstant: 40.0),
                emptyCartMessageSubtextLabel.topAnchor.constraint(equalTo: emptyCartMessageLabel.bottomAnchor, constant: 15.0),
                emptyCartMessageSubtextLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                emptyCartMessageSubtextLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                emptyCartMessageSubtextLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                emptyCartMessageSubtextLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -31.0),
                actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
                actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0)
            ])
    }
    
    /// This method sets up the styles of the EmptyCartView
    open func setStyles() {
        
        backgroundColor = .white
        
        emptyCartMessageLabel.font = UIFont(name: "Heebo-Regular", size: 17.0)
        emptyCartMessageLabel.textColor = UIColor.hexColor("#E25D71")
        
        emptyCartMessageSubtextLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
        
        actionButton.backgroundColor = UIColor(red: 227/255, green: 72/255, blue: 92/255, alpha: 1.0)
        actionButton.titleLabel?.font = UIFont(name: "Heebo-Bold", size: 18.0)
    }
    
    /// This method is the action of the start shopping button
    @objc open func actionButtonTapped() {
        
        state == .error ? delegate?.refresh() : delegate?.startShoppingButtonTapped()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
