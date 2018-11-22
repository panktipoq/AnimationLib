//
//  MyProfileLoginViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 17/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqUtilities
import UIKit

/// The type of authentication used in the login screen
///
/// - loginPassword: Standard authentication username/password
/// - facebook: Facebook authentication
public enum AuthetificationType {
    case loginPassword
    case facebook
}

/// Protocol handling authentication operations
public protocol MyProfileLoginViewCellDelegate: AnyObject {
    func dismissLogin()
    func logIn(withType type: AuthetificationType)
    func signUp() //It is possible only with AuthetificationType.LoginPassword
}

/// Intermediate screen showing two states. Logged in user displays basic account summary. Logged out user prompts the user to choose wether he want to create a new account or login with his/hers current one. The cell is also rendered in two screens: As a cell in the MyProfile screen and as a first time info cell in Home
open class MyProfileLoginViewCell: FullWidthAutoresizedCollectionCell, BlackButtonDelegate, SignButtonDelegate, PoqMyProfileListReusableView, HomeBannerCell {
    
    /// The banner image rendered on the background
    @IBOutlet open weak var bannerImage: PoqAsyncImageView! {
        didSet {
            bannerImage.contentMode = ImageHelper.returnImageScalingMode(fromString: AppSettings.sharedInstance.myProfileLoginContentMode)
        }
    }
    
    /// Image depicting a loyalty card banner
    @IBOutlet open weak var loyaltyCardBannerImage: PoqAsyncImageView!
    
    /// The signup button
    @IBOutlet open weak var signupButton: BlackButton?
    
    /// The sign in button
    @IBOutlet open weak var signinButton: BlackButton?
    
    /// The welcome label
    @IBOutlet open weak var welcomeLabel: UILabel? {
        didSet {
            welcomeLabel?.font = AppTheme.sharedInstance.welcomeLabelFont
        }
    }
    
    /// The company label
    @IBOutlet open weak var companyLabel: UILabel? {
        didSet {
            if let companylabel = companyLabel {
                companylabel.font = AppTheme.sharedInstance.companyLabelFont
                companylabel.text = AppLocalization.sharedInstance.myProfileCompanyTitle
                companylabel.textColor = UIColor.white
            }
        }
    }
    
    /// The label rendering 
    @IBOutlet open weak var loyaltyPointsLabel: UILabel? {
        didSet {
            if let loyaltylabel = loyaltyPointsLabel {
                loyaltylabel.font = AppTheme.sharedInstance.loyaltyPointsLabelFont
                loyaltylabel.text = AppLocalization.sharedInstance.myProfileLoyaltyCardTitle
                loyaltylabel.textColor = UIColor.white
            }
        }
    }
    
    /// Legal information label
    @IBOutlet open weak var optOutLabel: UILabel? {
        didSet {
            if let optoutlabel = optOutLabel {
                optoutlabel.font = AppTheme.sharedInstance.optOutFont
                optoutlabel.text = AppLocalization.sharedInstance.optOutTitle
                optoutlabel.textColor = UIColor.white
                optoutlabel.textAlignment = NSTextAlignment.center
                optoutlabel.adjustsFontSizeToFitWidth = true
            }
        }
    }
    
    /// An additional information label
    @IBOutlet open weak var otherFeaturesLabel: UILabel? {
        didSet {
            if let otherfeaturesLabel = otherFeaturesLabel {
                otherfeaturesLabel.font = AppTheme.sharedInstance.otherFeaturesFont
                otherfeaturesLabel.text = AppLocalization.sharedInstance.otherFeaturesTitle
                otherfeaturesLabel.textColor = UIColor.white
                otherfeaturesLabel.textAlignment = NSTextAlignment.center
                otherfeaturesLabel.adjustsFontSizeToFitWidth = true
            }
        }
    }
    
    /// Button that dismisses the banner
    @IBOutlet open weak var dismissButton: UIButton! {
        didSet {
            dismissButton.titleLabel?.font = AppTheme.sharedInstance.dismissButtonFont
            dismissButton.setTitleColor(AppTheme.sharedInstance.dismissButtonTextColor, for: UIControlState())
            dismissButton.setTitle(AppLocalization.sharedInstance.dismissButtonText, for: UIControlState())
            
            dismissButton.accessibilityIdentifier = AccessibilityLabels.loginCellDismissButton
        }
    }
    
    /// Imageview prompting the user to continue scrolling the content
    @IBOutlet weak var downArrow: UIImageView?

    /// Constraint handling signup button leading
    @IBOutlet weak var signupButtonLeadingSpace: NSLayoutConstraint?
    
    /// Constraint handling signuo button trailing
    @IBOutlet weak var signupButtonTrailingSpace: NSLayoutConstraint?

    /// The presenter for the actions in this cell. TODO: Given that the actions are data oriented, is the presenter approach a good idea as the service would be a better option?
    open weak var presenter: PoqMyProfileListPresenter?
    
    /// Legacy delegate for cell actions TODO: Need to clean this up or find out why we are doing this
    open weak var loginDelegate: MyProfileLoginViewCellDelegate?
    
    /// Info view containing loyalty card information
    open var loyaltyCardInfoView: MyProfileRewardCardInfoViewCell?
    
    // Called when the cell is on Screen
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Triggered when the view is generated from the xib
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        self.accessibilityIdentifier = AccessibilityLabels.customLoginCell
    }
    
    /// Updates the content in the cell
    open func updateView() {
        self.drawWelcomeLabel()
        self.drawLoyaltyCardBanner()
        self.drawSignupButton()
        self.drawSignInButton()
    }
    
    /// Shows the dismiss button in the case the cell is rendered as a welcome text
    open func showDismiss() {
        //first time loading on home
        dismissButton.isHidden = false
        otherFeaturesLabel?.isHidden = true
        downArrow?.isHidden = true
        //update text:
        
        welcomeLabel?.text = AppLocalization.sharedInstance.welcometoText
        
        if let welcomeMessageLabel = welcomeLabel {
            LabelStyleHelper.enableLetterSpacing(label: welcomeMessageLabel)
        }
        
        companyLabel?.text = AppLocalization.sharedInstance.companyNameText
    }
    
    /// Closes the current delegate viewcontroller
    @IBAction open func dismiss() {
        if let validPresenter = presenter as? MyProfileLoginViewCellDelegate {
            validPresenter.dismissLogin()
        } else {
            loginDelegate?.dismissLogin()
        }
    }
    
    /// Renders the cell as disabled. Currently stub for this cell
    open func disableView() {
        
    }
    
    // MARK: - Labels
    
    /// Sets up the visuals to the welcome label
    open func drawWelcomeLabel() {
        if let welcomelabel = welcomeLabel {
            welcomelabel.text = AppLocalization.sharedInstance.signIntoTextWithNewline
            welcomelabel.font = AppTheme.sharedInstance.welcomeLabelFont
            welcomelabel.textColor = UIColor.white
            welcomelabel.textAlignment = NSTextAlignment.left
        }
    }
    
    /// Sets up the visuals for the loyalty card banner
    open func drawLoyaltyCardBanner() {
        
        let bannerURL = AppSettings.sharedInstance.myProfileBannerBackgroundURL
        if let bannerNSURL = URL(string: bannerURL) {
            bannerImage?.getImageFromURL(bannerNSURL, isAnimated: true)
        }
        loyaltyCardBannerImage?.getImageFromURL(URL(string: AppSettings.sharedInstance.myProfileRewardCardInfoImage)!, isAnimated: false)
    }
    
    /// Sets up the visuals for the signup button
    open func drawSignupButton() {

        signupButton?.setTitle(AppLocalization.sharedInstance.signupTitle, for: .normal)
        signupButton?.buttonTag = 0
        signupButton?.borderWidth = 2.0
        
        if DeviceType.IS_IPAD {
            
            signupButtonLeadingSpace?.constant = CGFloat(AppSettings.sharedInstance.iPadSignupButtonLeadingSpace)
            signupButtonTrailingSpace?.constant = CGFloat(AppSettings.sharedInstance.iPadSignupButtonTrailingSpace)
            signupButton?.fontSize = CGFloat(AppTheme.sharedInstance.iPadSignUpButtonFontSize)
        }
    }
    
    /// Sets up the visuals for the sign in button
    open func drawSignInButton() {
        
        signinButton?.setTitle(AppLocalization.sharedInstance.signinTitle, for: .normal)
        signinButton?.buttonTag = 1

    }

    /// Triggered when the signup or the sign in button is clicked. Opens the specific screen
    ///
    /// - Parameter sender: The object that generated the action
    @IBAction public func blackButtonClicked(_ sender: Any?) {
        
        guard let button = sender as? BlackButton else {
            return
        }
        if button.buttonTag == 0 {
            loadSignUp()
        } else if button.buttonTag == 1 {
            if let validPresenter = presenter as? MyProfileLoginViewCellDelegate {
                validPresenter.logIn(withType: .loginPassword)
            } else {
                loginDelegate?.logIn(withType: .loginPassword)
            }
        }
    }
    
    /// Opens the register or the login screen based on the buttons tags. TODO: We are duplicating the functionality of blackButtonClicked
    ///
    /// - Parameter sender: The object that generated the action
    @objc open func buttonClicked(_ sender: UIButton) {
        if sender.tag == 0 {
            loadSignUp()
        } else if sender.tag == 1 {
            if let validPresenter = presenter as? MyProfileLoginViewCellDelegate {
                validPresenter.logIn(withType: .loginPassword)
            } else {
                loginDelegate?.logIn(withType: .loginPassword)
            }
        }
    }
  
    /// Loads the signup screen
    open func loadSignUp() {
        Log.verbose("Sign up")
        if let validPresenter = presenter as? MyProfileLoginViewCellDelegate {
            validPresenter.signUp()
        } else {
            loginDelegate?.signUp()
        }
    }
    
    /// Prepares the cell for reuse
    open override func prepareForReuse() {
        super.prepareForReuse()
        bannerImage?.prepareForReuse()
    }
    
    /// Triggered when the sign button clicked
    ///
    /// - Parameter sender: The object that sent the action
    public func signButtonClicked(_ sender: Any?) {
        loadSignUp()
    }
    
    // MARK: MyProfileLoginViewCell and HomeBannerCell delegate
    
    /// Sets up the cell content
    ///
    /// - Parameters:
    ///   - content: Content item holding cell information
    ///   - cellPresenter: The presenter that receives the actions from this cell
    open func setup(using content: PoqMyProfileListContentItem, cellPresenter: PoqMyProfileListPresenter) {
        updateView()
        showDismiss()
        presenter = cellPresenter
    }
    
    /// Updates the ui with the specific banner item
    ///
    /// - Parameters:
    ///   - bannerItem: The banner item that will populate the cell
    ///   - delegate: The delegate that will receive the cell's actions
    public func updateUI(_ bannerItem: HomeBannerItem, delegate: HomeViewController) {
        updateView()
        showDismiss()
        presenter = delegate as? PoqMyProfileListPresenter
        loginDelegate = delegate
    }
    
}
