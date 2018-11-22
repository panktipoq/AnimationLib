//
//  KeyValueCardTableViewCell.swift
//  PoqDemoApp
//
//  Created by Balaji Reddy on 09/07/2018.
//

import UIKit
import Cartography
import PoqUtilities
import PoqPlatform

// MARK: - Presenter Protocol

/// This protocol represents a type that can act as the presenter delegate for KeyValueCardTableViewCell
public protocol KeyValueCardCellPresenter: AnyObject {
    func remove(key: String, cardId: Int)
}

// MARK: - KeyValueCard Equatable
extension KeyValueCardTableViewCell.KeyValueCard: Equatable {
    
    public static func == (lhs: KeyValueCardTableViewCell.KeyValueCard, rhs: KeyValueCardTableViewCell.KeyValueCard) -> Bool {
        
        guard lhs.id == rhs.id else {
            return false
        }
        
        guard lhs.title == rhs.title else {
            return false
        }
        
        guard lhs.subtitle == rhs.subtitle else {
            return false
        }
        
        guard rhs.keyValueArray.count == lhs.keyValueArray.count else {
            return false
        }
        
        return rhs.keyValueArray.enumerated().reduce(true, { previousResult, enumerator in
            
            return previousResult && enumerator.element.key == lhs.keyValueArray[enumerator.offset].key && enumerator.element.value == lhs.keyValueArray[enumerator.offset].value
        })
    }
}

// MARK: - KeyValueCard Hashable
extension KeyValueCardTableViewCell.KeyValueCard: Hashable {
    
    public var hashValue: Int {
        return id
    }
}

// MARK: - KeyValueCardTableViewCell

/**
 
 This class a UITableViewCell subclass that can be used to present rows of key-value pairs in addition to title and an optional subtitle.
 It conforms to the ViewEditable protocol and the rows of key-value pairs can be deleted in edit mode.
 
 It relies on an instance of KeyValueCardCellPresenter to update convey any information regarding key-value pairs being deleted.
 
 - Note: This cell can be used to present information such as Order Summary or a list of Vouchers in the Bag screen.
 
 */
public class KeyValueCardTableViewCell: UITableViewCell, ViewEditable {
    
    // MARK: - KeyValueCard
    
    /// This struct encapsulates the view-data that can be presented by the KeyValueCardTableViewCell
    public struct KeyValueCard {
        
        var id: Int
        var title: String
        var subtitle: String?
        
        /// An array of key-value pair tuples
        /// - Note: An array of tuples is used instead of a dictionary to maintain the order of the key-value pairs
        var keyValueArray: [(key: String, value: String)]
    }
    
    // MARK: - KeyValueCardTableViewCell Properties
    
    private var cardStackView: UIStackView
    private var cardTitleLabel: UILabel
    private var cardSubtitleLabel: UILabel
    
    private var keyValueCard: KeyValueCard?
    
    private var keysToDeleteButtonTags: [String: Int]?
    private var deleteButtons: [UIButton]?
    
    /// This boolean decides if the KeyValueCardTableViewCell rows are editable
    public var isEditable: Bool = true
    
    private var delegate: KeyValueCardCellPresenter?
    
    // MARK: - UITableViewCell Overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        cardStackView = UIStackView(frame: CGRect.zero)
        cardStackView.spacing = 4
        cardStackView.axis = .vertical
        cardStackView.alignment = .fill
        cardStackView.distribution = .fill
        
        cardTitleLabel = UILabel(frame: CGRect.zero)
        cardSubtitleLabel = UILabel(frame: CGRect.zero)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.shouldIndentWhileEditing = false
        
        contentView.addSubview(cardStackView)
        contentView.addSubview(cardTitleLabel)
        contentView.addSubview(cardSubtitleLabel)
        
        layout()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        clearCardStack()
    }
    
    /// This method lays out the auto-layout constraints for the subviews of the KeyValueCardTableViewCell
    open func layout() {
        
        translatesAutoresizingMaskIntoConstraints = false
        cardStackView.translatesAutoresizingMaskIntoConstraints = false
        cardTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        cardSubtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        cardStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        cardTitleLabel.setContentHuggingPriority(.required, for: .vertical)
        cardSubtitleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        constrain(contentView, cardStackView, cardTitleLabel, cardSubtitleLabel) { contentView, cardStackView, cardTitleLabel, cardSubtitleLabel in

            cardStackView.leading == contentView.leading + 8
            cardStackView.trailing == contentView.trailing - 8
            cardStackView.bottom <= contentView.bottom - 8
            
            cardStackView.top == cardSubtitleLabel.bottom + 8

            align(leading: cardStackView, cardSubtitleLabel, cardTitleLabel)
            align(trailing: cardStackView, cardSubtitleLabel, cardTitleLabel)
            
            cardTitleLabel.top == contentView.top + 8
            cardTitleLabel.bottom == cardSubtitleLabel.top - 4
        }
    }
    
    /// This method sets up the KeyValueCardTableViewCell with its view-data
    /// Override this method for custom set up
    /// - Parameters:
    ///   - keyValueCard: The view-data that the KeyValueCardCell is to present
    ///   - delegate: The presenter that the KeyValueCardCell is to use to convey information regarding any interactions
    open func setup(with keyValueCard: KeyValueCard, delegate: KeyValueCardCellPresenter?) {
        
        self.keyValueCard = keyValueCard
        self.delegate = delegate
        
        cardTitleLabel.text = keyValueCard.title
        
        if let subtitleUnwrapped = keyValueCard.subtitle, !subtitleUnwrapped.isEmpty {
            cardSubtitleLabel.text = subtitleUnwrapped
            cardSubtitleLabel.isHidden = false
        } else {
            cardSubtitleLabel.isHidden = true
        }

        setupCardStack()
    }
    
    /// This method toggles the edit mode on the KeyValueCardTableViewCell
    /// Override this method to provide custom actions and animations
    /// - Parameters:
    ///   - editing: A boolean indicating whether the cell is to be in edit mode
    ///   - animate: A boolean indicating whether the transition to edit mode is to be animated
    open func setEditMode(to editing: Bool, animate: Bool) {
        
        if editing {
            
            if animate {
                UIView.animate(withDuration: 0.5, animations: {
                    self.deleteButtons?.forEach { deleteButton in
                        deleteButton.isHidden = false
                    }
                })
            } else {
                self.deleteButtons?.forEach { deleteButton in
                    deleteButton.isHidden = false
                }
            }
        } else {
            deleteButtons?.forEach { deleteButton in
                
                deleteButton.isHidden = true
                
            }
        }
    }
    
    // MARK: - Key Value Stack Setup/Teardown
    
    private var keyValueRowStackView: UIStackView {

        let stackView = UIStackView()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 5.0
        stackView.setContentHuggingPriority(.required, for: .vertical)
        return stackView
    }
    
    private var deleteButton: UIButton {
        
        let deleteButton = UIButton(type: .custom)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.setImage(ImageInjectionResolver.loadImage(named: "delete"), for: .normal)
        
        let deleteImageWidthConstraint = deleteButton.widthAnchor.constraint(equalToConstant: 22.0)
        deleteImageWidthConstraint.isActive = true
        deleteImageWidthConstraint.priority = .required
        
        deleteButton.addTarget(self, action: #selector(deleteRow), for: .touchUpInside)
        deleteButton.tag = deleteButtons?.count ?? 0
        
        //Hide the delete buttons until edit mode is enabled
        deleteButton.isHidden = true
        
        return deleteButton
    }
    
    private var keyLabel: UILabel {
        
        let keyLabel = UILabel()
        keyLabel.font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
        keyLabel.textAlignment = .left

        keyLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        return keyLabel
    }
    
    private var valueLabel: UILabel {
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
        valueLabel.textAlignment = .right
        
        valueLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        return valueLabel
    }
    
    private func setupCardStack() {
        
        guard let keyValueArrayUnwrapped = keyValueCard?.keyValueArray else {
            Log.warning("No key values provided to setup stack")
            return
        }
        
        deleteButtons = [UIButton]()
        keysToDeleteButtonTags = [String: Int]()
        
        // setup stackview with deleteButton, keyLabel and valueLabel and add to cardStackView
        for keyAndValue in keyValueArrayUnwrapped {
            
            let stackView = keyValueRowStackView
            
            // Add delete buttons if keyValueCard stack is to be editable
            if isEditable {

                let deleteButton = self.deleteButton
                
                // Associate the deleteButton to the Key so we know which key to remove when a particular delete button is tapped
                deleteButtons?.append(deleteButton)
                keysToDeleteButtonTags?[keyAndValue.key] = deleteButton.tag
                
                stackView.addArrangedSubview(deleteButton)
            }

            let keyLabel = self.keyLabel
            keyLabel.text = keyAndValue.key
            stackView.addArrangedSubview(keyLabel)
            
            let valueLabel = self.valueLabel
            valueLabel.text = keyAndValue.value
            stackView.addArrangedSubview(valueLabel)
            
            cardStackView.addArrangedSubview(stackView)
            
            stackView.widthAnchor.constraint(equalTo: cardStackView.widthAnchor).isActive = true
        }
    }
    
    private func clearCardStack() {
        
        for arrangedSubview in cardStackView.arrangedSubviews {
            cardStackView.constraints.forEach { constraint in
                if constraint.secondItem as? NSObject == arrangedSubview || constraint.firstItem as? NSObject == arrangedSubview {
                    constraint.isActive = false
                    cardStackView.removeConstraint(constraint)
                }
            }
            cardStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
        
    }
    
    // MARK: - KeyValueCard Editing
    
    /// This method is the selector for the delete buttons in each key-value row
    /// Override this method for actions to perform on row deletion
    /// - Parameter sender: The UIButton instance that triggered this action
    @objc open func deleteRow(_ sender: UIButton) {
        
        var keyOfDeletedRow: String?
        
        guard let keyValueCard = keyValueCard else {
            Log.error("Content item properties not provided cannot delete row.")
            return
        }
        
        guard let keysToDeleteButtonTags = keysToDeleteButtonTags else {
            Log.error("Keys are not mapped to delete button tags. Unable to ascertain key of deleted row.")
            return
        }
        
        for key in keysToDeleteButtonTags.keys where keysToDeleteButtonTags[key] == sender.tag {
            
            keyOfDeletedRow = key
            break
        }
        
        guard let keyOfDeletedRowUnwrapped = keyOfDeletedRow else {
            Log.error("Unable to ascertain key of deleted row")
            return
        }
        
        self.keyValueCard?.keyValueArray = keyValueCard.keyValueArray.filter { $0.key != keyOfDeletedRowUnwrapped }
        
        removeRowFromCardStack(containing: sender)
        
        delegate?.remove(key: keyOfDeletedRowUnwrapped, cardId: keyValueCard.id)
    }
    
    func removeRowFromCardStack(containing subview: UIView) {
        
        for arrangedSubview in cardStackView.arrangedSubviews {
            
            if let arrangedStackView = arrangedSubview as? UIStackView, arrangedStackView.arrangedSubviews.contains(subview) {
                
                cardStackView.removeArrangedSubview(arrangedStackView)
                arrangedStackView.removeFromSuperview()
            }
        }
    }
}
