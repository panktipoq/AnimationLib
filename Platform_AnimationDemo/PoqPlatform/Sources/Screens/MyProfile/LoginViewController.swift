//
//  LoginViewController.swift
//  Poq.iOS
//
//  Created by Øyvind Henriksen on 18/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

typealias TableViewAnimationCompletion = () -> Void

private let OptionCellHeight: CGFloat = 60
private let SignInButtonCellHeight: CGFloat = 60

open class LoginViewController: BaseAuthorizationViewController, UITableViewDelegate {

    override open class var XibName: String { return "LoginViewController" }

    lazy open var viewModel: LoginViewModel = {
        [unowned self] in
        return LoginViewModel(viewControllerDelegate: self)
    }()
    
    override open var baseViewModel: BaseAuthorizationViewModel {
        return viewModel
    }

    public var isModalView = false
    
    // TODO: looks like readonly and never used outside, so probably remove it
    fileprivate var appearsInTabBarView: Bool = false
    
    deinit {
        KeyboardHelper.removeKeyboardNotification(self)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.getLoginPageDetails(true)
        
        setUpNavigationBar()
    }
    
    open func setUpNavigationBar() {
        
        if !AppSettings.sharedInstance.signUpViewForPlatform {
            self.navigationItem.title = AppLocalization.sharedInstance.loginNavigationTitle
            self.navigationItem.titleView = nil
        }
        
        //set up close button
        if !appearsInTabBarView {
            setUpLeftNavigationBarButton()
        }
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    open func setUpLeftNavigationBarButton() {
        self.navigationItem.leftBarButtonItem = isModalView ? NavigationBarHelper.setupCloseButton(self) : NavigationBarHelper.setupBackButton(self)
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let height: CGFloat

        let conttenItem = viewModel.content[indexPath.row]
        switch conttenItem.type {
        case .headerImage:
            let webViewCellheignt: CGFloat = webviewCell?.termsWebview?.scrollView.contentSize.height ?? 50
            
            let navigationAndStatusBarHeight = UIApplication.shared.statusBarFrame.height + CGFloat(navigationController?.navigationBar.frame.size.height ?? 0)
            var headerCellHeightForHoF: CGFloat = UIScreen.main.bounds.height - MyProfileInputCellHeight * 2 - SignInButtonCellHeight - OptionCellHeight - navigationAndStatusBarHeight - webViewCellheignt - keyboardSize.height
            
            // we still should have this header. In case if in some case we got too smal number, just set headerCellHeightForPlatform
            if headerCellHeightForHoF < AppSettings.sharedInstance.headerCellHeightForPlatform {
                headerCellHeightForHoF = AppSettings.sharedInstance.headerCellHeightForPlatform
            }
            
            height = AppSettings.sharedInstance.signUpViewForPlatform ? AppSettings.sharedInstance.headerCellHeightForPlatform : headerCellHeightForHoF
        case .submitButton:
            height = SignInButtonCellHeight
        case .dataSharing:
            height = OptionCellHeight
        default:
            height = conttenItem.cellHeight
        }
        
        return height
    }
    
    // MARK: - NETWORKING
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if networkTaskType == PoqNetworkTaskType.postAccount {
            
            // Check if bag is merged
            let account = LoginHelper.getAccounDetails()
            
            if AppSettings.sharedInstance.enableRecognitionTracking {
                
                let extraParams = ["RecognitionType": "SignIn"]
        
                PoqTrackerHelper.trackLoginRecognition(extraParams, label: account?.accountRef)
                
            }
            
            if let isBagMerged = account?.isBagMerged, isBagMerged {

                // Track merge event
                PoqTracker.sharedInstance.logAnalyticsEvent(
                    "Bag Merged",
                    action: "Bag Merged",
                    label: User.getUserId(),
                    extraParams: nil)
                
                let okText = "OK".localizedPoqString
                let validAlertController = UIAlertController(title: "", message: "BAG_MERGED".localizedPoqString, preferredStyle: .alert)
                
                validAlertController.addAction(UIAlertAction(title: okText, style: .default, handler: {
                    [unowned self] _ in
                    self.closeButtonClicked()
                }))
                
                present(validAlertController, animated: true)
                
            } else {
                closeButtonClicked()
            }

        } else if networkTaskType == PoqNetworkTaskType.pageDetails {

            updateTableViewCellsHeight()

            tableView?.reloadData()
            
        }
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        guard networkTaskType != .getCheckoutDetails else {
            closeButtonClicked()
            return
        }
        guard networkTaskType != .pageDetails else {
            //if we have error in pages we just ignore it
            Log.warning("pageDetails failed, http server status != OK")
            return
        }
        
        let validAlertController: UIAlertController = UIAlertController.init(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)

        guard let errorMessage = viewModel.errorMessage else {
            return
        }
        
        self.alertController = validAlertController
        
        if errorMessage != "" {
            
            validAlertController.title = "FAILED_TO_LOGIN".localizedPoqString
            validAlertController.message = errorMessage
            validAlertController.addAction(UIAlertAction.init(title: "OK".localizedPoqString, style: UIAlertActionStyle.default, handler: { (alertaction: UIAlertAction) in
                
            }))
            
        } else {
            // display error alert
            validAlertController.title = "CONNECTION_ERROR".localizedPoqString
            validAlertController.message = "TRY_AGAIN".localizedPoqString
            if NSClassFromString("XCTestCase") != nil {
                Log.info("Skipping the 'connection error' popup because we are testing.")
                return
            }
            validAlertController.addAction(UIAlertAction.init(title: "OK".localizedPoqString, style: UIAlertActionStyle.default, handler: { (alertaction: UIAlertAction) in
                
            }))
        }
        
        self.present(validAlertController, animated: true, completion: {
            // Completion handler once everything is dismissed
        })
    }
    
    override open func closeButtonClicked() {
        
        for cell in tableView?.visibleCells ?? [UITableViewCell]() {
            guard let fullWidthTextFieldCell = cell as? FullwidthTextFieldCellTableViewCell else {
                continue
            }
            
            fullWidthTextFieldCell.inputTextField?.resignFirstResponder()
        }

        if isModalView {
            
            super.closeButtonClicked()
            NavigationHelper.sharedInstance.clearTopMostViewController()
        } else {
            _ = navigationController?.popViewController(animated: false)
        }
    }
    
    // MARK: - SignButtonDelegate
    override open func signButtonClicked(_ sender: Any?) {
        
        loginIfPossible()       
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        imageTapped()
        self.view.endEditing(true)
    }
}

extension LoginViewController: LoginHeaderTableViewCellDelegate {
    // ImageTap to dimiss the keyboard
    @nonobjc
    public func imageTapped() {
        for cell in tableView?.visibleCells ?? [UITableViewCell]() {
            guard let fullwidthTextFieldCell = cell as? FullwidthTextFieldCellTableViewCell else {
                continue
            }
            
            fullwidthTextFieldCell.inputTextField?.resignFirstResponder()
        }
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        if textField.myProfileControlTag == .passwordTextField {
            loginIfPossible()
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.myProfileControlTag == .emailTextField {
            
            let isValidEmail: Bool = textField.obligatoryText().isValidEmail()
            
            let floatLabelTextField = textField as? FloatLabelTextFieldWithState
            floatLabelTextField?.isValid = isValidEmail
        }
    }
}

// MARK: - Private

extension LoginViewController {

    /**
     Try to login with existed information about login and password
     */
    @nonobjc
    fileprivate final func loginIfPossible() {
        guard let usernameIndex: Int = viewModel.indexOf(itemWithType: .email),
            let passwordIndex: Int = viewModel.indexOf(itemWithType: .password) else {       
                return
        }
        
        let username: String? = viewModel.content[usernameIndex].firstInputItem.value
        let password: String? = viewModel.content[passwordIndex].firstInputItem.value
        
        guard let validUsername: String = username, validUsername.isValidEmail() else {
            let indexPath = IndexPath(row: usernameIndex, section: 0)
            let textFieldCell = tableView?.cellForRow(at: indexPath) as? FullwidthTextFieldCellTableViewCell
            textFieldCell?.shake()
            textFieldCell?.becomeFirstResponder()
            return
        }
        
        guard let validPassword: String = password, validPassword.isValidPassword() else {
            let indexPath = IndexPath(row: passwordIndex, section: 0)
            let textFieldCell = tableView?.cellForRow(at: indexPath) as? FullwidthTextFieldCellTableViewCell
            textFieldCell?.shake()
            textFieldCell?.becomeFirstResponder()
            return
        }
        
        // Save username
        LoginHelper.saveEmail(username)
        
        viewModel.login(validUsername, password: validPassword) 
    }
}
