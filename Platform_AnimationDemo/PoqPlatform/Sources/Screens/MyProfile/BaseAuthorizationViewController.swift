//
//  BaseAuthorizationViewController.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/26/16.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

/**
 We have common functionality on all auth screens: cell with UIWebView, SubmitButton and scrol to current editing cell, when keyboard appears 
 Since we are using the same model, we can also make cells registration and some common functionality related to it
 */
open class BaseAuthorizationViewController: PoqBaseViewController, SignButtonDelegate, SwitchCellDelegate, UITableViewDataSource {

    @IBOutlet open weak var tableView: UITableView?
    
    /// Should help us identify navigation flow, since login options ws modal screen
    public var isFromLoginOptions: Bool = false
    
    open var webviewCell: WebviewTableViewCell?
    open var keyboardSize: CGSize = CGSize.zero
    
    public weak var signInButton: SignButton?

    // in same cases we will have multiple height with minor time diff - looks awfull, so resize one by one
    fileprivate var tableViewResizeInProgress: Bool = false
    fileprivate var completion: TableViewAnimationCompletion?
    
    // MARK: Subclass override
    /// Subclasses must override and return their view model
    open var baseViewModel: BaseAuthorizationViewModel {
        fatalError("Subclass MUST override this var and return their view model")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // setup table view
        tableView?.registerPoqCells(cellClasses: [LoginHeaderTableViewCell.self, TwoTextfieldsTableViewCell.self, 
                                                  GenderTableViewCell.self, SwitchTableViewCell.self,
                                                  ImageTableViewCell.self, ButtonTableViewCell.self,
                                                  WebviewTableViewCell.self, FullwidthTextFieldCellTableViewCell.self,
                                                  DatePickerTableViewCell.self, MyProfileAddressBookTitleTableViewCell.self,
                                                  EditMyProfieDateCell.self, DateTableViewCell.self])
        tableView?.estimatedRowHeight = 44
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.separatorColor = UIColor.clear

        KeyboardHelper.addKeyboardNotification(self, iPhoneOnly:  false)
        
    }
    
    // MARK: UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baseViewModel.content.count 
    }
    
    func fetchAuthorizationCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> (MyProfileContentItem, UITableViewCell) {
        let resCell: UITableViewCell
        let contentItem = baseViewModel.content[indexPath.row]
        
        // If we have a webView use that not a new one
        if let existedWebViewCell: WebviewTableViewCell = webviewCell, contentItem.type == .webView {
            resCell = existedWebViewCell
        } else {
            resCell = tableView.dequeueReusableCell(withIdentifier: contentItem.type.cellIdentifier, for: indexPath)
        }
        return (contentItem, resCell)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellData = fetchAuthorizationCell(tableView, cellForRowAt: indexPath)
        
        let contentItem = cellData.0
        let resCell = cellData.1
        
        switch contentItem.type {
        case .webView:
            webviewCell = resCell as? WebviewTableViewCell
            
        case .dateField:
            guard let validCell = resCell as? DateTableViewCell else {
                return resCell
            }
            validCell.updateUI(contentItem, delegate: self)
            
        case .submitButton:
            if let buttonCell = resCell as? ButtonTableViewCell {
                signInButton = buttonCell.submitButton
                // We need keep update enable/disable state for button
                updateButtonEnableState()
            }
            
        default:
            break
        }
        
        // Exceptions for cells. We should clean this up a bit in future versions. 
        if let validCell = resCell as? MyProfileCell {
            validCell.updateUI(contentItem, delegate: self)
        }
        
        resCell.hideNativeSeparator()
        resCell.selectionStyle = .none
        
        return resCell
    }
    
    /*
     Override in subclasses to provide additional conditions
     for Submit button enabled/disabled state.
     */
    open func submitButtonValidations() -> Bool {
        return true
    }
    
    // MARK: SignButtonDelegate
    open func signButtonClicked(_ sender: Any?) {
        // override this function if you need take any actions on it
    }
    
    // MARK: - SwitchCellDelegate
    public func switchOn(_ cellTag: Int, isOn: Bool) {
        
        guard let myProfileControlTag = MyProfileControlTag(rawValue: cellTag) else {
            Log.error("We met incorrect tag in SwitchCellDelegate. cellTag = \(cellTag)")
            return
        }
        
        guard let contentType = myProfileControlTag.contentItemType, let index: Int = baseViewModel.indexOf(itemWithType: contentType) else {
            Log.error("We can't find content item for \(myProfileControlTag)")
            return
        }
        
        baseViewModel.content[index].firstInputItem.value = isOn.toString()
        
        // additional actions
        switch myProfileControlTag {
        case .dataSharingSwitch:
            LoginHelper.isMasterCard = isOn
            break
        default:
            break
        }
        
        // Changing Switch state might require Submit button state update
        updateButtonEnableState()
    }
    
    /// Only Clients are supposed to provide styling
    open func switchCell(_ cell: SwitchTableViewCell, requiresStylingForTermsAndPolicy: String?) -> NSAttributedString? {
        return nil
    }
    
    /// By default it opens a `PoqWebViewController` with the specified URL
    open func switchCell(_ cell: SwitchTableViewCell, didInteractWith URL: URL) {
        
        let webController = PoqWebViewController(url: URL)
        let navController = PoqNavigationViewController(rootViewController: webController)
        present(navController, animated: true, completion: nil)
    }
    
    open func updateState(_ textField: FloatLabelTextFieldWithState, text: String) {
        switch textField.myProfileControlTag {
        case .emailTextField:
            let skipError: Bool = !AppSettings.sharedInstance.showErrorOnInvalidEmailWhileTyping
            let isValidEmail: Bool = text.isValidEmail()
            textField.isValid = isValidEmail || skipError
            
        case .passwordTextField:
            textField.isValid = text.isValidPassword()
        case .phoneField:
            textField.isValid = text.isValidPhoneNumber()
        case .firstNameTextField, .lastNameTextField:
            textField.isValid = true
        default:
            Log.error("we met incorrect text field tag - \(textField.myProfileControlTag), tag = \(textField.tag)")
        }
        
        if let existedItemType = textField.myProfileControlTag.contentItemType,
            let index: Int = baseViewModel.indexOf(itemWithType: existedItemType) {
            
            if textField.myProfileControlTag == .lastNameTextField {
                baseViewModel.content[index].secondInputItem?.value = text
            } else {
                baseViewModel.content[index].firstInputItem.value = text
            }
        }
        
        textField.updateMessageTextAndStyling(forText: text)
        
        updateButtonEnableState()
    }
    
    /** 
     Check textfield for valid or existed info and enable/disable button according to it
     */
    @nonobjc
    open func updateButtonEnableState() {
        
        guard 
            let usernameIndex: Int = baseViewModel.indexOf(itemWithType: .email),
            let passwordIndex: Int = baseViewModel.indexOf(itemWithType: .password) else {
                return
        }
        
        // we make here direct comparation with == false, to pass 2 checks not nil and false at one operator
        var isEnabled: Bool = baseViewModel.content[usernameIndex].firstInputItem.value?.isEmpty == false &&
            baseViewModel.content[passwordIndex].firstInputItem.value?.isEmpty == false
        
        if let nameItem = baseViewModel.contentItem(typeOf: .name) {
            if nameItem.firstInputItem.value == nil || nameItem.secondInputItem?.value == nil {
                isEnabled = false
            }
        }
        
        // additional check for cases when we have more required fields
        isEnabled = isEnabled && submitButtonValidations()
        
        signInButton?.isEnabled = isEnabled
    }
}

// MARK: Convenient API
extension BaseAuthorizationViewController {
    
    @nonobjc
    public final func updateTableViewCellsHeight() {
        
        if tableViewResizeInProgress {
            completion = {
                self.updateTableViewCellsHeight()
            }
            return
        }
        
        tableViewResizeInProgress = true
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            () -> Void in
            self.tableViewResizeInProgress = false
            
            if let existedCompletion: TableViewAnimationCompletion = self.completion {
                existedCompletion()
            }
            self.completion = nil
        })
        
        tableView?.beginUpdates()
        if let webviewIndex: Int = baseViewModel.indexOf(itemWithType: .webView) {
            let webviewItem = baseViewModel.content[webviewIndex]
            webviewCell?.updateUI(webviewItem, delegate: self)
        }
        
        tableView?.endUpdates()
        
        CATransaction.commit()
    }
}

// MARK: UIWebViewDelegate
extension BaseAuthorizationViewController: UIWebViewDelegate {
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        guard let url = request.url?.absoluteString, navigationType == .linkClicked else {
            
            return true
        }
        
        if isFromLoginOptions && url.contains("http") {
            
            // Login options is a modal shown on top of bag view modal
            // External link browser opens itself on root view controller
            // To avoid any navigation issues we have to open external browser on top of this modal
            
            if let loadURL = URL(string: url) {
                
                let webviewController = PoqWebViewController(url: loadURL)
                let navigationController = PoqNavigationViewController(rootViewController: webviewController)
                present(navigationController, animated: true, completion: { () -> Void in
                    webviewController.startProcess()
                })
            }
            
        } else {
            
            NavigationHelper.sharedInstance.loadExternalLink(url, topViewController: self)
        }
        
        PoqTrackerHelper.trackSignUpLinkClicked(["URL": url])
        
        return false
    }
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        webviewCell?.loading = true
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        
        webviewCell?.loading = false
        webviewCell?.alreadyLoaded = true
        // update constraints for all cell with UIWebView
        if let existedWebViewCell: WebviewTableViewCell = webviewCell {
            existedWebViewCell.setNeedsUpdateConstraints()
        }
        
        // force UI table view reload height
        updateTableViewCellsHeight()
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        webviewCell?.loading = false
    }
}

extension BaseAuthorizationViewController: UITextFieldDelegate {
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // get text after user finished typing the last letter
        let nsText: NSString = textField.obligatoryText() as NSString
        let textAfterUpdate = nsText.replacingCharacters(in: range, with: string)
        guard let floatLabelTextField = textField as? FloatLabelTextFieldWithState else {
            Log.error("The textfield is not a FloatLabelTextFieldWithState instance")
            return true
        }
        updateState(floatLabelTextField, text: textAfterUpdate)
        return true
    }
    
    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        if let existedItemType = textField.myProfileControlTag.contentItemType, let index = baseViewModel.indexOf(itemWithType: existedItemType) {
            
            if textField.myProfileControlTag == .lastNameTextField {
                baseViewModel.content[index].secondInputItem?.value = ""
            } else {
                baseViewModel.content[index].firstInputItem.value = ""
            }
        }
        
        let floatLabelTextField = textField as? FloatLabelTextFieldWithState
        floatLabelTextField?.updateMessageTextAndStyling(forText: "")
        
        updateButtonEnableState()
        
        return true
    }
}

extension BaseAuthorizationViewController: GenderCellDelegate {
    public func genderSelected(_ isFemale: Bool) {
        guard let index: Int = baseViewModel.indexOf(itemWithType: .gender) else {
            return
        }
        
        baseViewModel.content[index].firstInputItem.value = isFemale.toString()
    }
}

extension BaseAuthorizationViewController: DatePickerCellDelegate {
    public func dateWasChanged(_ date: Date) {
        guard let index: Int = baseViewModel.indexOf(itemWithType: .date) else {
            return
        }
        
        baseViewModel.content[index].firstInputItem.value = DateHelper().birthdayDateFormat(date)
        let indexPath = IndexPath(row: index, section: 0)
        tableView?.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
}

// MARK: MyProfileCellsDelegate
extension BaseAuthorizationViewController: MyProfileCellsDelegate {
    
}

// MARK: KeyboardEventsListener
extension BaseAuthorizationViewController: KeyboardEventsListener {
    // MARK: Keyboard will show/hide
    @objc public func keyboardWillShow(_ notification: Notification) {
        
        if DeviceType.IS_IPAD {
            if let userInfo = notification.userInfo, let rectValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                keyboardSize = rectValue.cgRectValue.size
                updateTableViewCellsHeight()
            }
        } else {
            
            resizeTableViewForKeyboardWillShow(notification)
        }
        
    }
    
    @objc public func keyboardWillHide(_ notification: Notification) {
        
        if DeviceType.IS_IPAD {
            keyboardSize = CGSize.zero
            updateTableViewCellsHeight()
            
        } else {
            resizeTableViewForKeyboardWillHide(notification)
        }
    }
}

// MARK: TableViewControllerWithTextFields
extension BaseAuthorizationViewController: TableViewControllerWithTextFields {
}
