//
//  ActionableMessageTableViewCell.swift
//  PoqCart
//
//  Created by Balaji Reddy on 15/07/2018.
//

import UIKit
import ReSwift
import PoqPlatform
import PoqUtilities

// MARK: - Presenter Protocol

/// This protocol represents a type that can act as the presenter delegate for ActionableMessageTableViewCell
public protocol ActionableMessagePresenter {
    
    func performActionForCell(with message: String)
}

// MARK: - ActionableMessageTableViewCell

/**
 
 This class a UITableViewCell subclass that can be used to present a row of text that can optionally be tappable
 
 
 It relies on an instance of ActionableMessagePresenter to update convey the tap action.
 
 - Note: This cell can be used to present information such as promotion banners or an action to add coupons.
 
 */
public class ActionableMessageTableViewCell: UITableViewCell {
    
    // MARK: - ActionableMessageTableViewCell AccessibilityIdentifiers
    public static let accessibilityIdTag = "ActionableMessageTableViewCell_"
    public static let messageLabelAccessibilityIdTag = "ActionableMessageTableViewCellMessageLabel_"
    public static let actionIndicatorAccessibilityTag = "ActionableMessageTableViewCellActionIndicator_"
    
    // MARK: - ActionableMessageTableViewCell Properties
    var messageLabel: UILabel
    var presenter: ActionableMessagePresenter?
    var message: String?
    
    // MARK: - UITableViewCell Overrides
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
     
        messageLabel = UILabel(frame: CGRect.zero)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(messageLabel)
        
        layout()
        
        styleViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// This method lays out the auto-layout constraints for the subviews of the ActionableMessageTableViewCell
    open func layout() {
        translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
                messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0),
                messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0),
                messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5.0)
            ])
    }
    
    ///    This method sets up the ActionableMessageTableViewCell.
    ///
    ///  - Note: Override this method for custom setup
    ///
    /// - Parameters:
    ///   - message: The message that is to be presented by the cell
    ///   - isActionable: A boolean to indicate if the cell is tappable
    ///   - presenter: The presenter delegate instance to convey any actions to
    open func setup(with message: String, isActionable: Bool = false, presenter: ActionableMessagePresenter? = nil) {
        
        accessibilityIdentifier = ActionableMessageTableViewCell.accessibilityIdTag + String(message.hashValue)
        
        self.message = message
        messageLabel.text = message
        messageLabel.accessibilityIdentifier = ActionableMessageTableViewCell.messageLabelAccessibilityIdTag + String(message.hashValue)
        
        if isActionable {
            accessoryView = UIImageView(image: ImageInjectionResolver.loadImage(named: "Next"))
            accessoryView?.accessibilityIdentifier = ActionableMessageTableViewCell.actionIndicatorAccessibilityTag + String(message.hashValue)
            self.presenter = presenter
            isUserInteractionEnabled = true
            
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performAction)))
        }
    }
    
    /// This method sets up the styles of the subview
    /// - Note: Override this method to provide custom styling
    open func styleViews() {
        
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 14.0)
    }
    
    /// This is the target action for the tap gesture on the cell
    @objc open func performAction() {
        
        guard let message = message else {
            assertionFailure("Message cell does not have message set. Cannot perform action")
            return
        }
        
        presenter?.performActionForCell(with: message)
    }
}
