//
//  SearchBar.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 3/21/17.
//
//

import Foundation
import PoqUtilities
import UIKit

let visualSearchButtonAccessibilityIdentifier = "VisualSearchButtonAccessibilityIdentifier"
let barcodeScannerAccessibilityIdentifier = "BarcodeScannerAccessibilityIdentifier"

protocol SearchBarDelegate: class {
    
    /// Can be called multiple times, before cancel button pressed
    func serchBarDidStartEditing()
    
    /// Will be called when user change input
    func searchBarDidUpdateText(query: String?)

    func cancelButtonPressed()
    
    func searchButtonPressed()
}

enum SearchBarState {
    case idle
    case editing
}

/// This bar will help us mimic native UISearchbar behaviour.
/// We will detouch container view, when it become active, to move to top

open class SearchBar: UIView, UITextFieldDelegate {
    
    public static let height: CGFloat = 44
    
    weak var delegate: SearchBarDelegate?

    @IBOutlet open weak var containerView: UIView?
    @IBOutlet open weak var textFieldBackground: UIImageView?
    
    // We need container, which will contain search icon and text field, to mimi animation of search bar
    // In .idle state textField will be in middle, in editing state will occupy max space
    @IBOutlet weak var textFieldContainer: UIView?
    @IBOutlet var textFieldContainerTrailingConstraint: NSLayoutConstraint?

    @IBOutlet weak var textField: UITextField?
    @IBOutlet var textFieldLeadingConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var searchIconImageView: UIImageView?
    @IBOutlet weak var searchBarTapGesture: UITapGestureRecognizer?
    
    @IBOutlet weak var cancelButton: UIButton?
    
    @IBOutlet var searchBarButtonsContainer: UIView?
    
    @IBOutlet weak open var scannerButton: UIButton? {
        didSet {
            scannerButton?.accessibilityIdentifier = barcodeScannerAccessibilityIdentifier
        }
    }
    @IBOutlet var scannerButtonBackground: UIImageView?
    
    @IBOutlet weak open var visualSearchButton: UIButton? {
        didSet {
            visualSearchButton?.accessibilityIdentifier = visualSearchButtonAccessibilityIdentifier
        }
    }
    @IBOutlet var visualSearchButtonBackground: UIImageView?
    
    fileprivate var searchBarButtonsEnabled = {
        return  AppSettings.sharedInstance.enableScanOnSearchBar || AppSettings.sharedInstance.enableVisualSearch
    }()

    fileprivate var _state: SearchBarState = .idle
    
    var state: SearchBarState {
        get {
            return _state
        }
        set(value) {
            setState(value, animated: false)
        }
    }
    
    // MARK: - API
    
    /// Update state used to animatively update UI: text field, scanner & visual search buttons
    func setState(_ state: SearchBarState, animated: Bool) {
        guard state != _state else {
            // Lets just avoid mess with animations
            return
        }
        _state = state
        updateStateContraints()
        if animated {
            UIView.animate(withDuration: 0.3, animations: { 
                self.containerView?.layoutIfNeeded()
            })
        }
    }
    
    public func removeScanButton() {
        self.scannerButton?.removeFromSuperview()
    }
    
    // MARK: - Override UIView
    override open func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        applyStyling()
        updateStateContraints()
        
        searchIconImageView?.image = ImageInjectionResolver.loadImage(named: "SearchBarIcon")
        textField?.isAccessibilityElement = true
        textField?.accessibilityIdentifier = AccessibilityLabels.search
    }
    
    // MARK: - Actions
    
    @IBAction public func cancelButtonAction(_ sender: UIButton?) {
        textField?.resignFirstResponder()
        delegate?.cancelButtonPressed()
        textField?.text = nil
        textField?.attributedPlaceholder = attributedPlaceholder
    }
    
    @IBAction public func textChanged(_ sender: UITextField?) {
        delegate?.searchBarDidUpdateText(query: textField?.text)
        let empty: Bool
        if let existedText = textField?.text, !existedText.isEmpty {
            empty = false
        } else {
            empty = true
        }
        
        textField?.attributedPlaceholder = empty ? attributedPlaceholder : NSAttributedString(string: "")
    }

    @IBAction public func tapGestureAction(_ sender: UITapGestureRecognizer) {
        textField?.becomeFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = .search
        delegate?.serchBarDidStartEditing()
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.invalidateIntrinsicContentSize()
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.searchButtonPressed()
        return true
    }
    
    // MARK: - UIControl override
    
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        return textField?.becomeFirstResponder() ?? false
    }

    // MARK: - Private
    
    fileprivate var attributedPlaceholder: NSAttributedString {
        // Placehoder color and font
        let placehoderAttributes = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.searchBarPlaceholderColor,
                                                   NSAttributedStringKey.font: AppTheme.sharedInstance.searchBarPlaceholderFont]
        return NSAttributedString(string: AppLocalization.sharedInstance.searchPlaceholderText, attributes: placehoderAttributes)
    }
    
    fileprivate func updateStateContraints() {
        
        textFieldContainerTrailingConstraint?.isActive = false

        switch _state {
        case .idle:
            cancelButton?.alpha = 0
            searchBarButtonsContainer?.alpha = 1
            // The anchor for the textfield view will depend on whether the search bar has buttons or not
            if let layoutXAxisAnchor = searchBarButtonsEnabled ? searchBarButtonsContainer?.leadingAnchor : cancelButton?.trailingAnchor {
                textFieldContainerTrailingConstraint = textFieldContainer?.trailingAnchor.constraint(equalTo: layoutXAxisAnchor)
            }
            textFieldLeadingConstraint?.isActive = searchBarButtonsEnabled ? false : true
            
        case .editing:
            cancelButton?.alpha = 1
            searchBarButtonsContainer?.alpha = 0
            if let cancelButtonLeadingConstraint = cancelButton?.leadingAnchor {
            textFieldContainerTrailingConstraint = textFieldContainer?.trailingAnchor.constraint(equalTo: cancelButtonLeadingConstraint)
            }
            textFieldLeadingConstraint?.isActive = false
        }
        
        textFieldContainerTrailingConstraint?.isActive = true
    }
    
    func resetState() {
        textField?.text = nil
        textField?.attributedPlaceholder = attributedPlaceholder
    }
    
    fileprivate func applyStyling() {
        
        let searchFieldBackgroundImage = ImageInjectionResolver.loadImage(named: "PredictiveSearchBarBackground")
        
        textFieldBackground?.image = searchFieldBackgroundImage
        scannerButtonBackground?.image = searchFieldBackgroundImage
        visualSearchButtonBackground?.image = searchFieldBackgroundImage
        
        containerView?.backgroundColor = AppTheme.sharedInstance.searchBarBackground
        
        textField?.attributedPlaceholder = attributedPlaceholder 

        cancelButton?.setTitleColor(AppTheme.sharedInstance.searchBarCancelButtonColor, for: .normal)
        cancelButton?.titleLabel?.font = AppTheme.sharedInstance.searchBarCancelButtonFont

        // Text field color and font
        let textFieldAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.black,
                                   NSAttributedStringKey.font.rawValue: AppTheme.sharedInstance.searchBarPlaceholderFont]
        textField?.defaultTextAttributes = textFieldAttributes
        
        configureSearchBarButtons()
    }
    
    func configureSearchBarButtons() {
        if AppSettings.sharedInstance.enableScanOnSearchBar {
            scannerButton?.configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.scannerButtonStyle)
        } else {
            scannerButton?.removeFromSuperview()
            scannerButtonBackground?.removeFromSuperview()
            if let searchBarButtonsContainerLeadingConstraint = searchBarButtonsContainer?.leadingAnchor,
                AppSettings.sharedInstance.enableVisualSearch {
                visualSearchButton?.leadingAnchor.constraint(equalTo: searchBarButtonsContainerLeadingConstraint).isActive = true
            }
        }
        
        if AppSettings.sharedInstance.enableVisualSearch {
            visualSearchButton?.configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.visualSearchButtonStyle)
        } else {
            visualSearchButton?.removeFromSuperview()
            visualSearchButtonBackground?.removeFromSuperview()
            if let searchBarButtonsContainerTrailingConstraint = searchBarButtonsContainer?.trailingAnchor,
                AppSettings.sharedInstance.enableScanOnSearchBar {
                scannerButton?.trailingAnchor.constraint(equalTo: searchBarButtonsContainerTrailingConstraint).isActive = true
            }
        }
    }
}
