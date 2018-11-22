//
//  MyProfilePlatformLoginViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 29/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit

/// The platform intermediate cell that prompts the user to register or login for an account TODO: Why do we keep two of these should it not be better to use only one?
open class MyProfilePlatformLoginViewCell: MyProfileLoginViewCell {
    
    /// The min height of the cell
    public static let MinHeight = CGFloat(AppSettings.sharedInstance.myProfilePlatformLoginViewCellMinHeight)
    
    /// The signup with facebook button
    @IBOutlet weak var signupFBButton: UIButton?
    
    /// The sign in button
    @IBOutlet weak var signInButton: UIButton?
    
    /// The sign up button
    @IBOutlet weak var signUpButton: UIButton?
    
    /// The height constraint of the cell
    weak open var hConstraint: NSLayoutConstraint?

    /// Constraint handling the distance between the login and the signup buttons
    @IBOutlet weak var verticalDistanceBetweenSignInAndSignUpButtons: NSLayoutConstraint! {
        didSet {
            verticalDistanceBetweenSignInAndSignUpButtons.constant = AppSettings.sharedInstance.platformLoginLengthBetweenSigninAndRegisterButton
        }
    }
    
    /// Constraint handling the distance at the bottom of the signup screen
    @IBOutlet weak var bottomDistanceFromSignUpButton: NSLayoutConstraint! {
        didSet {
            bottomDistanceFromSignUpButton.constant = CGFloat(AppSettings.sharedInstance.bottomDistanceFromSignUpButton)
        }
    }

    /// Called when the cell is on Screen
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Called when the cell is created from the xib file
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        accessibilityIdentifier = AccessibilityLabels.platforLoginCell
        signupFBButton?.addTarget(self, action: #selector(MyProfilePlatformLoginViewCell.signInWithFacebook(_:)), for: .touchUpInside)
        signupFBButton?.setBackgroundImage(ImageInjectionResolver.loadImage(named: "FacebookLoginButton"), for: .normal)
    }
    
    /// Sign the user with facebook
    ///
    /// - Parameter sender: The object that triggers the action
    @objc func signInWithFacebook(_ sender: UIButton) {
      
        guard let validPresenter = presenter as? MyProfileLoginViewCellDelegate else {
            return
        }
        validPresenter.logIn(withType: .facebook)
    }

    /// Updates the view's visuals
    override open func updateView() {
        
        drawLoyaltyCardBanner()
        drawWelcomeLabel()
        drawSignupButton()
        drawSignInButton()
        drawSignInFBButton()
        checkConstraints()
    }
    
    /// Checks the constraints to render specific layout for logged in logged out states
    open func checkConstraints() {

        let screenBounds = UIScreen.main.bounds
        var height = screenBounds.size.height
        
        if !LoginHelper.isLoggedIn() {
            
            // Not very good this is still old implementation
            if let validPresenter = presenter, !AppSettings.sharedInstance.shouldShowImageonTheWholeScreen {
                height -= CGFloat( validPresenter.service.loggedOutContent.count - 1 ) * MyProfileLinkViewCell.Height
            }
            
            if let presenterController = presenter as? PoqBaseViewController {
                height -= presenterController.tabBarController?.tabBar.frame.height ?? 0.0
                height -= presenterController.navigationController?.navigationBar.frame.maxY ?? 0.0
            }

            if height < MyProfilePlatformLoginViewCell.MinHeight {
                height = MyProfilePlatformLoginViewCell.MinHeight
            }
        }
        
        if let validHeightConstraint = hConstraint {
            
            validHeightConstraint.isActive = false
            validHeightConstraint.constant = height
            validHeightConstraint.isActive = true
            
        } else {
            
            hConstraint = contentView.heightAnchor.constraint(equalToConstant: height)
            hConstraint?.priority = UILayoutPriority(rawValue: 999.0)
            hConstraint?.isActive = true
        }
    }
    
    /// Draws the sign in facebook button
    func drawSignInFBButton() {
        
        signupFBButton?.tag = 2
        signupFBButton?.layoutIfNeeded()
    }

    /// Draws the sign in button
    override open func drawSignInButton() {
        
        signInButton?.configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.primaryButtonStyle)
        signInButton?.setTitle(AppLocalization.sharedInstance.signinLandingPageSignInButtonTitle, for: UIControlState())
        signInButton?.accessibilityIdentifier = AccessibilityLabels.signInButton
        signInButton?.tag = 1
        signInButton?.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
    }
    
    /// Draws the signup button
    override open func drawSignupButton() {
        
        signUpButton?.configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.secondaryButtonStyle)
        signUpButton?.setTitle(AppLocalization.sharedInstance.signinLandingPageRegisterButtonTitle, for: UIControlState())
        signInButton?.accessibilityIdentifier = AccessibilityLabels.signUpButton
        signUpButton?.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
    }
    
    /// Draws the welcome label
    override open func drawWelcomeLabel() {
        
        if let welcomelabel = welcomeLabel {
            
            welcomelabel.text = AppLocalization.sharedInstance.signinLandingPageTitle
            welcomelabel.font = AppTheme.sharedInstance.welcomeLabelFont
            welcomelabel.textColor = UIColor.white
        }
    }
    
    /// Updates the view and sets the presenter accordingly
    ///
    /// - Parameters:
    ///   - content: The content item that is used to generate the cell
    ///   - cellPresenter: The presenter which renders the cell
    open override func setup(using content: PoqMyProfileListContentItem, cellPresenter: PoqMyProfileListPresenter) {
        presenter = cellPresenter
        updateView()
    }
}
