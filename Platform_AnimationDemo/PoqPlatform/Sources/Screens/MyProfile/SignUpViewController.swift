//
//  SignUpViewController.swift
//  Poq.iOS
//
//  Created by Jun Seki on 24/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

protocol SignUpDelegate: AnyObject {
    
    func didSignUp()
}

open class SignUpViewController: BaseAuthorizationViewController, NavigationBarTitle {
    
    override open var screenName: String {
        return "Register Screen"
    }
    
    override open class var XibName: String {
        
        return "SignUpViewController"
    }

    weak var delegate: SignUpDelegate?

    open lazy var viewModel: SignUpViewModel = {
        
        SignUpViewModel(viewControllerDelegate: self) 
    }()
    
    // This variable is used to enable phone number field on signup form.
    public static var isPhoneNumberEnabled: Bool = false
    
    override open var baseViewModel: BaseAuthorizationViewModel {
        return viewModel
    }
  
    var isClosed: Bool?
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpNavigationBar(AppLocalization.sharedInstance.signUpNavigationTitle, leftBarButtonItem: NavigationBarHelper.setupCloseButton(self), isNavigationBarTitleEnabled: AppSettings.sharedInstance.signUpViewForPlatform)
        viewModel.isPhoneNumberEnabled = SignUpViewController.isPhoneNumberEnabled
        viewModel.setupContentForSignUp()
        KeyboardHelper.addKeyboardNotification(self)
    }

    override open func closeButtonClicked() {
        // Delegate back to my profile view controller for reloading.
        delegate?.didSignUp()
        
        isClosed = true
        view.endEditing(true)
        super.closeButtonClicked()
    }
    
    // MARK: - NETWORKING
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        if networkTaskType == PoqNetworkTaskType.pageDetails {
            tableView?.reloadData()
        }
        
        if networkTaskType == PoqNetworkTaskType.registerAccount {
            let account = LoginHelper.getAccounDetails()
            
            if account?.statusCode == HTTPResponseCode.OK {
                userDidRegister()
            } else {
                Log.error("Unable to recognize response for resiter user")
                presentErrorAlert(account?.message)
            }
        }
    }

    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {

        presentErrorAlert(viewModel.errorMessage)
    }

    // MARK: - SignButtonDelegate
    override open func signButtonClicked(_ sender: Any?) {
        
        signUpIfPossible()        
    }
    
    override open func updateState(_ textField: FloatLabelTextFieldWithState, text: String) {
        switch textField.myProfileControlTag {
        case .dateField:
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale.current
            viewModel.dobDate = dateFormatter.date(from: text)
            textField.isValid = viewModel.isDateValid()
        case .emailTextField:
            textField.accessibilityIdentifier = AccessibilityLabels.signUpEmail
        case .passwordTextField:
            textField.accessibilityIdentifier = AccessibilityLabels.signUpPassword
        default:
            break
        }
        super.updateState(textField, text: text)
    }
    
    open override func submitButtonValidations() -> Bool {
        for cellIndex in 0..<viewModel.content.count {
            let hasDOB = viewModel.content[cellIndex].type == MyProfileContentItemType.dateField
            if hasDOB {
                return viewModel.isDateValid()
            }
        }
        return true
    }
}

// MARK: - Convenience API 
extension SignUpViewController {
    /// Present alert view with error(usually from API). Also will do checks on known issues and present more detailed error
    /// Title - is failed to sign up
    /// TRY_AGAIN is default message
    @nonobjc
    public final func presentErrorAlert(_ message: String?) {

        let validAlertController = UIAlertController.init(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
        validAlertController.view.accessibilityIdentifier = AccessibilityLabels.signUpAlert

        if message?.contains(AppLocalization.sharedInstance.userNameAlreadyInUseText) == true {

            let cancelText = "CANCEL".localizedPoqString
            let okText = "SIGN_IN".localizedPoqString
            
            validAlertController.title = "EMAIL_IN_USE".localizedPoqString
            validAlertController.message = "PLEASE_SIGN_IN_TO_YOUR_ACCOUNT".localizedPoqString
            validAlertController.addAction(UIAlertAction.init(title: cancelText, style: UIAlertActionStyle.cancel, handler: { (_: UIAlertAction) in
                
            }))
            validAlertController.addAction(UIAlertAction.init(title: okText, style: UIAlertActionStyle.default, handler: { (_: UIAlertAction) in
                self.closeButtonClicked()
                NavigationHelper.sharedInstance.loadLogin(isModal: true, isViewAnimated: true)
            }))
            
        } else {
           
            validAlertController.title = "FAILED_TO_SIGN_UP".localizedPoqString
            validAlertController.message = message
            validAlertController.addAction( UIAlertAction.init(title: "OK".localizedPoqString, style: UIAlertActionStyle.default, handler: { (_: UIAlertAction) in
            }))
        }

        self.present(validAlertController, animated: true, completion: {
            // Completion handler once everything is dismissed
        })
    }
    
    @nonobjc
    public final func userDidRegister() {

        closeButtonClicked()
        if let validAccount: PoqAccount = LoginHelper.getAccounDetails() {
            PoqTrackerV2.shared.signUp(userId: User.getUserId(), marketingOptIn: validAccount.isPromotion ?? false, dataOptIn: validAccount.allowDataSharing ?? false)
        }
    }
}

// MARK: - UITableViewDelegate Implementation
// __________________________

extension SignUpViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.content[indexPath.row].cellHeight
    }
}

extension SignUpViewController {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let existedTableView: UITableView = tableView else {
            return false
        }

        return textFieldShouldReturn(textField, tableView: existedTableView)
    }
    
    func textFieldShouldReturn(_ textField: UITextField, tableView: UITableView?) -> Bool {
        textField.resignFirstResponder()
        
        // Handle password Done button action
        if textField.myProfileControlTag == .passwordTextField && signInButton?.isEnabled == true {
            signUpIfPossible()
        }

        FloatTableViewHelper().makeNextCellFirstResponder(textField.tag, tableView: tableView)
        return false
    }

    func isValidInputData(_ tableView: UITableView?) -> Bool {

        // TODO: migrate all for model usege not UITableViewCells
        for cellIndex in 0..<viewModel.content.count {
            if let currentCell = tableView?.cellForRow(at: IndexPath(row: cellIndex, section: 0)) as? TwoTextfieldsTableViewCell {
                if currentCell.firstNameTextField?.text?.isEmpty == true {
                    currentCell.firstNameTextField?.attributedPlaceholder = NSAttributedString(string: "ENTER_FIRSTNAME".localizedPoqString, attributes: [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.signInRegisterInputPlaceHolderColor])
                    return InvalidTextFieldHelper.shakeInvalidTextField(currentCell.firstNameTextField)
                } else if currentCell.lastNameTextField?.text?.isEmpty == true {
                    currentCell.lastNameTextField?.attributedPlaceholder = NSAttributedString(string: "ENTER_LASTNAME".localizedPoqString, attributes: [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.signInRegisterInputPlaceHolderColor])
                    return InvalidTextFieldHelper.shakeInvalidTextField(currentCell.lastNameTextField)
                }
            }
            
            if let currentCell = tableView?.cellForRow(at: IndexPath(row: cellIndex, section: 0)) as? FullwidthTextFieldCellTableViewCell {
                if viewModel.content[cellIndex].type == .email &&  currentCell.inputTextField?.text?.isValidEmail() == false {
                    currentCell.inputTextField?.attributedPlaceholder = NSAttributedString(string: "ENTER_VALID_EMAIL".localizedPoqString,
                                                                                           attributes: [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.signInRegisterInputPlaceHolderColor])
                    
                    return InvalidTextFieldHelper.shakeInvalidTextField(currentCell.inputTextField)
                }
                
                if viewModel.content[cellIndex].type == .password &&  currentCell.inputTextField?.text?.isValidPassword() == false {
                    currentCell.inputTextField?.attributedPlaceholder = NSAttributedString(string: AppLocalization.sharedInstance.invalidPasswordText, 
                                                                                           attributes: [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.signInRegisterInputPlaceHolderColor])
                    return InvalidTextFieldHelper.shakeInvalidTextField(currentCell.inputTextField)
                }
                
                if viewModel.dobDate != nil && viewModel.content[cellIndex].type == .dateField && !viewModel.isDateValid() {
                        currentCell.inputTextField?.attributedPlaceholder = NSAttributedString(string: "ENTER_VALID_DOB".localizedPoqString, 
                                                                                               attributes: [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.signInRegisterInputPlaceHolderColor])
                        return InvalidTextFieldHelper.shakeInvalidTextField(currentCell.inputTextField)
                }
                if viewModel.content[cellIndex].type == .phone,
                    (currentCell.inputTextField?.text?.isValidPhoneNumber() == false),
                    let phone = currentCell.inputTextField?.text,
                    phone.count > 0 {
                    currentCell.inputTextField?.attributedPlaceholder = NSAttributedString(string: "ENTER_VALID_PHONE".localizedPoqString,
                                                                                           attributes: [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.signInRegisterInputPlaceHolderColor])
                    return InvalidTextFieldHelper.shakeInvalidTextField(currentCell.inputTextField)
                }
            }
        }

        // Show alert if we should have gender, but we didn't set it
        if let index = viewModel.indexOf(itemWithType: .gender), viewModel.content[index].firstInputItem.value == nil && AppSettings.sharedInstance.isGenderCellEnabledOnSignup {
            
            let okText = "OK".localizedPoqString
            
            let validAlertViewController = UIAlertController.init(title: "GENDER_REQUIRED".localizedPoqString, message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            self.alertController = validAlertViewController
            
            validAlertViewController.addAction(UIAlertAction.init(title: okText, style: UIAlertActionStyle.default, handler: { (_: UIAlertAction) in
            }))
            
            self.present(validAlertViewController, animated: true, completion: { 
                // Completion handler once everything is dismissed
            })
            
            return false
        }
        return true
    }
}

// MARK: - Hiddden
extension SignUpViewController {
    
    /// Try to sign up user with existed information
    @nonobjc
    fileprivate final func signUpIfPossible() {
        guard let existedTableView: UITableView = tableView else {
            return
        }
        
        if isValidInputData(existedTableView) {
            viewModel.postUserAccount()
        }
    }
}
