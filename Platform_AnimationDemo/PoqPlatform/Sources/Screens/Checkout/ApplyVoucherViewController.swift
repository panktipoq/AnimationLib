//
//  ApplyVoucherViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 20/08/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit

enum VoucherType {
    case `default`
    case studentDiscount
}

public protocol ApplyVoucherDelegate: AnyObject {
    
    func voucherAdded()
}

open class ApplyVoucherViewController: PoqBaseViewController {
    
    // MARK: - Attributes
    // _________________________
        
    lazy open var viewModel = ApplyVoucherViewModel()
    final public var orderId: Int?

    final var originalFrameYForWhiteBox: CGFloat = 0

    open weak var voucherDelegate: ApplyVoucherDelegate?
    var voucherType: VoucherType = .default
    
    // MARK: - IBOutlets
    // _________________________
    
    @IBOutlet open weak var whiteBoxView: UIView!
    
    @IBOutlet weak var closeButton: CloseButton?
    
    @IBOutlet weak var titleLabel: UILabel! {
        
        didSet {
            
            titleLabel.text = AppLocalization.sharedInstance.applyVoucherTitle
            titleLabel.font = AppTheme.sharedInstance.applyVoucherTitleLabelFont
        }
    }
    
    @IBOutlet open weak var voucherCodeTextField: FloatLabelTextFieldWithState! {
        
        didSet {
            voucherCodeTextField.titleFont = AppTheme.sharedInstance.textFieldActiveTitleFont
            voucherCodeTextField.titleActiveTextColour = AppTheme.sharedInstance.mainColor
            voucherCodeTextField.placeholder = AppLocalization.sharedInstance.voucherCodeDefaultText
            voucherCodeTextField.font = AppTheme.sharedInstance.applyVoucherTextFieldFont
            if let clearButtonImage = UIImage(named: "serchTextFieldClearButton") {
                voucherCodeTextField.customClearButtonImage = clearButtonImage
            }
            
            voucherCodeTextField.autocorrectionType = UITextAutocorrectionType.no
            voucherCodeTextField.spellCheckingType = UITextSpellCheckingType.no
        }
    }
    
    @IBOutlet open weak var applyButton: UIButton? {
        didSet {
            let buttonTitle = AppLocalization.sharedInstance.applyVoucherButtonLabel
            let buttonColor = ResourceProvider.sharedInstance.clientStyle?.applyToBagButtonStyle
            applyButton?.addTarget(self, action: #selector(blackButtonClicked), for: .touchUpInside)
            applyButton?.configurePoqButton(withTitle: buttonTitle, using: buttonColor)
        }
    }
    
    @IBOutlet weak var voucherTypeControl: ADVSegmentedControl! {
        didSet {
            voucherTypeControl.items = [AppLocalization.sharedInstance.voucherViewText, AppLocalization.sharedInstance.studentDiscountViewText]
            voucherTypeControl.font = AppTheme.sharedInstance.voucherTypeTextFieldFont
            voucherTypeControl.selectedLabelFont = AppTheme.sharedInstance.voucherTypeTextFieldFont
            voucherTypeControl.selectedBackgroundColor = AppTheme.sharedInstance.voucherTypeSecelectionBackgroundColor
            voucherTypeControl.borderColor = AppTheme.sharedInstance.voucherTypeSecelectionBackgroundColor
            voucherTypeControl.borderWidht = 1
            voucherTypeControl.addTarget(self, action: #selector(ApplyVoucherViewController.changeVoucherTypeEvent(_:)), for: .valueChanged)
        }
    }
    
    deinit {
        KeyboardHelper.removeKeyboardNotification(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIViewController Delegates
    // _________________________
    
    override open func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        ViewAnimationHelper.backgroundBlur(view)
    }
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        originalFrameYForWhiteBox = self.view.frame.origin.y
        viewModel.viewControllerDelegate = self
        KeyboardHelper.addKeyboardNotification(self)
        NotificationCenter.default.addObserver(self, selector: #selector(ApplyVoucherViewController.enterBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        initializeVoucherCodeTextField()
    }
    
    @objc func enterBackground() {
        voucherCodeTextField.resignFirstResponder()
    }
  
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.startEditingVoucherTextField(voucherCodeTextField)
    }
    
    @objc func changeVoucherTypeEvent(_ control: UIControl) {
        changeVoucherType()
    }

    @IBAction func closeButtonClicked(_ sender: Any?) {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - NetworkTask Delegates
    
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        voucherCodeTextField.isEnabled = false
    }

    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        whiteBoxView.shake()
        voucherCodeTextField.isEnabled = true
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        voucherCodeTextField.isEnabled = true
        _ = voucherCodeTextField.becomeFirstResponder()
        voucherDelegate?.voucherAdded()
    }

    open func changeVoucherType() {
        
        if voucherType == .default {
            
            voucherType = .studentDiscount
            voucherCodeTextField.placeholder = AppLocalization.sharedInstance.studentDiscountDefaultText
            
        } else {
            
            voucherType = .default
            voucherCodeTextField.placeholder = AppLocalization.sharedInstance.voucherCodeDefaultText
        }
        
        applyButton?.setNeedsDisplay()
    }
    
    func initializeVoucherCodeTextField() {
        voucherCodeTextField.autocorrectionType = .no
        voucherCodeTextField.autocapitalizationType = .allCharacters
    }
    
    // MARK: - TextField Delegates
    // _________________________
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        viewModel.resetTextField(voucherCodeTextField, voucherType: voucherType)
        return true
    }
    
    // Called when 'return' key pressed. return NO to ignore.
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        viewModel.endEditingVoucherTextFieldAndApplyCode(voucherCodeTextField, orderId: orderId, voucherType: voucherType)
        return true
    }
    
    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        voucherCodeTextField.text = ""
        return true
    }
}

extension ApplyVoucherViewController {
    
    @objc open func blackButtonClicked(_ sender: UIButton) {
        
        if !viewModel.isTextFieldEmpty(voucherCodeTextField) {
            
            viewModel.endEditingVoucherTextFieldAndApplyCode(voucherCodeTextField, orderId: orderId, voucherType: voucherType)
        }
    }
}

// MARK: - Keyboard will show/hide
extension ApplyVoucherViewController: KeyboardEventsListener {
    
    public func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
        let keyboardOffset = frameValue.cgRectValue.size.height / 2
        
        UIView.animate(withDuration: animationDuration) {
            self.view.frame.origin.y = self.originalFrameYForWhiteBox - keyboardOffset
        }
    }
    
    public func keyboardWillHide(_ notification: Notification) {
        let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
        
        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = self.originalFrameYForWhiteBox
        }
    }
}
