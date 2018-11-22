//
//  ClientStyleProvider.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 23/11/2016.
//
//

import Foundation

/**
     ClientStyleProvider is a protocol that declares properties that define the style of various UI elements in the PoqPlatform.
     Any client requiring to provide custom styles to Platform UI elements must:
 
     - Create class/struct that implements `ClientStyleProvider`, eg:
 
 
         class ClientStyle: ClientStyleProvider {
 
             func getLogoView (forFrame frame: CGRect) -> UIView? {
                 let logoView = UIImageView(frame: frame)
                 logoView.contentMode = .scaleAspectFit
                 logoView.image = UIImage(named: "Client_Logo")
                 return logoView
             }
 
             var voucherDetailHeaderImage: UIImage? {
                 return UIImage(named: "Client_Logo")
             }
 
             var importButtonStyle: PoqButtonStyle? {
 
                 let fontSize = CGFloat(AppSettings.sharedInstance.importButtonFontSize)
                 let color = UIColor.black
 
                 var buttonStyle = PoqButtonStyle(backgroundColor: UIColor.white)
                 buttonStyle.shouldAddDropShadow = false
                 buttonStyle.titleColorForState = [.normal: color]
                 buttonStyle.font = UIFont(name: "HelveticaNeue-Light", size: fontSize)
                 buttonStyle.borderWidth = 0.5
                 buttonStyle.borderColor = color
                 buttonStyle.cornerRadius = 3.0
 
                 return buttonStyle
 
             }
         }
 
     - Set the `clientStyle` property of ResourceProvider to an instance of this class in your `AppDelegate`
 
       `ResourceProvider.sharedInstance.clientStyle = ClientStyle()`

 */
public protocol ClientStyleProvider {

    // MARK: - PoqButtonStyle
    
    /**
         This property provides the style for the `CheckoutButton` class.
         Instances of this class are used in Bag & `CheckoutBagViewController`
    */
    var pdpCheckoutButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property provides the style for the `Add To Bag` button in `PoqProductContentInfoBlockView`
     */
    var pdpAddToBagButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property provides the style for the Apply To Bag button in `ApplyVoucherViewController`, `VoucherListViewCell` and `VoucherDetailViewController`
     */
    var applyToBagButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property provides the style for the Use In Store button in `VoucherListViewCell`
    */
    var useInStoreButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property provides the style for the Primary Button - The button for the primary call to action, in many screens across the app. This style should be used across the app in all screens but currently it is not so.
    */
    var primaryButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property provides the style for the Seconday Button - The button for the secondary call to action, in many screens across the app. This style should be used across the app in all screens but currently it is not so.
     */
    var secondaryButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property provides the style for the BackButton class. An instance of the BackButton is used as the default "back" button in `NavigationBarHelper`.
     */
    var backButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the back button style on a leftBarButtonItem in PDP
         This Button Style exists only because we have transparent background while scrolling PDP View Controller.
     */
    var pdpBackButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `CloseButton` class.
     */
    var closeButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `CloseButton` class if it is setup to be white.
     */
    var closeButtonWhiteStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `RoundedCloseButton` class.
     */
    var closeButtonRoundedStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `MinusButton` class.
     */
    var minusButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `PlusButton` class.
     */
    var plusButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `PreviousButton` class.
     */
    var previousButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `NextButton` class.
     */
    var nextButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `FavoriteStoreButton` class.
     */
    var likeButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `ShareButton` class and the share button on PDP
     */
    var pdpShareButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `ImportButton` class.
     */
    var importButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `SearchScanButton` class.
     */
    var scannerButtonStyle: PoqButtonStyle? { get }
    
    /**
     This property is used to setup the style of the visual search searchbar icon
     */
    var visualSearchButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `LookbookButton` class.
     */
    var lookbookButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `ShowHideButton` class.
     */
    var showHideButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `RetryButton` class.
     */
    var retryButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `LeftSideMenu` class.
     */
    var leftSideMenuStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the updateButton in the `ForceUpdateViewController`
     */
    var forceUpdateButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `MySizeKidsButton` class
     */
    var mySizeKidsButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `MySizeKidsButton` class
     */
    var mySizeWomanButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `MySizeManButton` class
     */
    var mySizeManButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `DirectionButton` class
     */
    var directionButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `WishlistCloseButton` class
     */
    var wishListCloseButtonStyle: PoqButtonStyle? { get }
    
    /**
         This property is used to setup the style of the `WishlistCloseButton` class
     */
    var voucherDetailHeaderImage: UIImage? { get }
    
    /**
         This property provides the image for the `Add To Wishlist` button in the normal state on PDP
     */
    var pdpWishlistButtonImageDefault: UIImage? { get }
    
    /**
         This property provides the image for the `Add To Wishlist` button in the pressed state on PDP
     */
    var pdpWishlistButtonImagePressed: UIImage? { get }
    
    /**
     This property provides the unfilled color for the `Rating Stars` view on PDP. Defaults to light gray.
     */
    var pdpRatingStarsUnfilledColor: UIColor? { get }
    
    /**
     This property provides the default filled color for the `Rating Stars` view on PDP. Defaults to black.
     */
    var pdpRatingStarsFilledColor: UIColor? { get }
    
    /**
         This property provides the logo image that is used on the Navigation Bar
     */
    func getLogoView(forFrame frame: CGRect) -> UIView?
    
    /**
         This method is used to provide the right Navigation Bar button in `PoqBaseViewController`.
         It is set only if the sideMenuPosition AppSetting is set to a value other than left.
     - returns: An instance of a class/struct that adheres to `BadgedControl` and `BarButtonItemProvider`.
     */
    func createBagControl() -> BadgedControl & BarButtonItemProvider
    
    /**
     Update the Navigation Bordered Button Size to avoid small buttons based on small texts.
     
     - note: The minimum size for a button is set to 50.0, if the client needs a different size, it can be overrided though this method and a ClientStyle.

     - Parameter size: The actual size of the button.
     - returns: The calculated new size for the button.
     */
    func adjustBorderedNavigationBarButtonSize(basedOn size: CGSize) -> CGSize
    
    /**
     Property used to setup the navigation bar colour.
     */
    var rootVCNavBarColor: UIColor? { get }
    
    /**
     Property used to setup the status bar style.
     */
    var rootVCStatusBarStyle: UIStatusBarStyle? { get }
    
    /**
     Property used to setup is the the navigation bar should be translucent or not.
     */
    var rootVCIsTranslucent: Bool? { get }
}

extension ClientStyleProvider {
    
    public var rootVCNavBarColor: UIColor? {
        return .white
    }
    
    public var rootVCStatusBarStyle: UIStatusBarStyle? {
        let statusBarStyle: PoqStatusBarStyle? = PoqStatusBarStyle.dark
        return UIStatusBarStyle.statusBarStyle(statusBarStyle)
    }
    
    public var rootVCIsTranslucent: Bool? {
        return true
    }
    
    // MARK: - PoqButtonStyle
    public var pdpCheckoutButtonStyle: PoqButtonStyle? {
        var buttonStyle = PoqButtonStyle()
 
        let defaultImage = ImageInjectionResolver.loadImage(named: "SecureCheckoutDefault")
        let disabledImage = ImageInjectionResolver.loadImage(named: "SecureCheckoutDisabled")
        let highlightedImage = ImageInjectionResolver.loadImage(named: "SecureCheckoutPressed")
        
        if let defaultImg = defaultImage,
            let disabledImg = disabledImage,
            let highlightedImg = highlightedImage {
            buttonStyle.backgroundImageForState = [UIControlState.normal: defaultImg,
                                                   UIControlState.selected: highlightedImg,
                                                   UIControlState.disabled: disabledImg]
        }
        
        let titleColor = AppTheme.sharedInstance.checkoutButtonTextColor
        buttonStyle.titleColorForState = [UIControlState.normal: titleColor,
                                          UIControlState.selected: titleColor,
                                          UIControlState.disabled: titleColor]
        
        buttonStyle.backgroundColor = UIColor.clear
        buttonStyle.font = AppTheme.sharedInstance.bagSecureCheckoutButtonLabelFont
        return buttonStyle
    }
    
    public var pdpAddToBagButtonStyle: PoqButtonStyle? {
        
        var buttonStyle = PoqButtonStyle()
        buttonStyle.backgroundColor = AppTheme.sharedInstance.addToBagButtonBackgroundColor
        buttonStyle.font = AppTheme.sharedInstance.pdpAddToBagButtonFont
        buttonStyle.titleColorForState = [UIControlState() : UIColor.white]
        return buttonStyle
    }
    
    public var applyToBagButtonStyle: PoqButtonStyle? {
     
        var buttonStyle = PoqButtonStyle(tintColor: AppTheme.sharedInstance.vouchersApplyToBagButtonFontColor)
        buttonStyle.backgroundColor = AppTheme.sharedInstance.vouchersApplyToBagButtonBackgroundColor
        
        buttonStyle.font = AppTheme.sharedInstance.vouchersButtonFont
        buttonStyle.titleColorForState = [UIControlState() : AppTheme.sharedInstance.vouchersApplyToBagButtonFontColor, .disabled : UIColor.lightGray]
        buttonStyle.cornerRadius = CGFloat(AppSettings.sharedInstance.voucherListApplyToBagButtonCornerRadius)
        
        return buttonStyle
    }
    
    public var useInStoreButtonStyle: PoqButtonStyle? {
        
        let useInStoreColor = AppTheme.sharedInstance.voucherListUseInStoreButtonFontColor
        var buttonStyle = PoqButtonStyle(tintColor: useInStoreColor)
        buttonStyle.backgroundColor = AppTheme.sharedInstance.voucherListUseInStoreButtonBackgroundColor
        buttonStyle.titleColorForState = [UIControlState() : useInStoreColor]
        
        buttonStyle.font = AppTheme.sharedInstance.vouchersButtonFont
        
        buttonStyle.borderColor = AppTheme.sharedInstance.voucherListUseInStoreButtonBorderColor
        buttonStyle.borderWidth = CGFloat(AppSettings.sharedInstance.voucherListUseInStoreBorderWidth)
        buttonStyle.cornerRadius = CGFloat(AppSettings.sharedInstance.voucherListUseInStoreCornerRadius)
        
        return buttonStyle
    }
    
    /// This Style replaces the signInButtonStyle.
    public var primaryButtonStyle: PoqButtonStyle? {
        var buttonStyle = PoqButtonStyle()
        buttonStyle.backgroundColor = AppTheme.sharedInstance.primaryButtonBackgroundColor
        
        let cornerRadius = CGFloat(AppTheme.sharedInstance.primaryButtonCornerRadius)
        let colorsForControlStates: [UIControlState: UIColor] = [.normal: AppTheme.sharedInstance.primaryButtonBackgroundColor, .disabled: AppTheme.sharedInstance.primaryButtonBackgroundColorForDisabledState, .highlighted: AppTheme.sharedInstance.primaryButtonBackgroundColorForHighligtedState]
        
        buttonStyle.backgroundImageForState = getBackgroundImagesForColorsOfStates(colorForState: colorsForControlStates, cornerRadius: cornerRadius)
        buttonStyle.font = AppTheme.sharedInstance.primaryButtonFont
        buttonStyle.titleColorForState = [.normal: AppTheme.sharedInstance.primaryButtonFontColor, .disabled: AppTheme.sharedInstance.primaryButtonFontColorForDisabledState]
        buttonStyle.borderWidth = CGFloat(AppTheme.sharedInstance.primaryButtonBorderWidth)
        buttonStyle.borderColor = AppTheme.sharedInstance.primaryButtonBorderColor
        buttonStyle.cornerRadius = cornerRadius
        return buttonStyle
    }
    
    /// This Style replaces the signUpButtonStyle
    public var secondaryButtonStyle: PoqButtonStyle? {
        var buttonStyle = PoqButtonStyle()
        
        let cornerRadius = CGFloat(AppTheme.sharedInstance.secondaryButtonCornerRadius)
        let colorsForControlStates: [UIControlState: UIColor] = [.normal: AppTheme.sharedInstance.secondaryButtonBackgroundColor, .disabled: AppTheme.sharedInstance.secondaryButtonBackgroundColorForDisabledState, .highlighted: AppTheme.sharedInstance.secondaryButtonBackgroundColorForHighligtedState]
        
        buttonStyle.backgroundImageForState = getBackgroundImagesForColorsOfStates(colorForState: colorsForControlStates, cornerRadius: cornerRadius)
        buttonStyle.font = AppTheme.sharedInstance.secondaryButtonFont
        buttonStyle.titleColorForState = [.normal: AppTheme.sharedInstance.secondaryButtonFontColor, .disabled: AppTheme.sharedInstance.secondaryButtonFontColorForDisabledState]
        buttonStyle.borderWidth = CGFloat(AppTheme.sharedInstance.secondaryButtonBorderWidth)
        buttonStyle.borderColor = AppTheme.sharedInstance.secondaryButtonBorderColor
        buttonStyle.cornerRadius = cornerRadius
        return buttonStyle
    }
    
    public var pdpShareButtonStyle: PoqButtonStyle? {
        
        var pdpShareButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var shareButtonPDPDefault: UIImage? = ImageInjectionResolver.loadImage(named: "ShareButtonImageDefault")
        
        if shareButtonPDPDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawShareButton(frame: SquareBurButtonRect,
                                                                           pressed: false)
            shareButtonPDPDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // TODO: typo error with the name of the image button, update to "ShareButtonImagePressed"
        var shareButtonPDPPressed: UIImage? = ImageInjectionResolver.loadImage(named: "ShareButtonImageDefaultPressed")
        
        if shareButtonPDPPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawShareButton(frame: SquareBurButtonRect,
                                                                           pressed: true)
            shareButtonPDPPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = shareButtonPDPDefault,
            let pressedImage = shareButtonPDPPressed {
            
            pdpShareButtonStyle.backgroundImageForState = [.normal: defaultImage,
                                                       .highlighted: pressedImage]
        }
        return pdpShareButtonStyle
    }
    
    public var importButtonStyle: PoqButtonStyle? {
        
        let normalColor = UIColor(red: 0.18, green: 0.56, blue: 0.84, alpha: 1.000)
        let fontSize = CGFloat(AppSettings.sharedInstance.importButtonFontSize)
        
        var buttonStyle = PoqButtonStyle(backgroundColor: normalColor)
        buttonStyle.shouldAddDropShadow = false
        buttonStyle.titleColorForState = [.normal: UIColor.white, .disabled: UIColor.lightGray]
        
        buttonStyle.font = UIFont(name: "HelveticaNeue-Medium", size: fontSize)
        
        var importButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "ImportButtonDefault")

        if importButtonDefault == nil {
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawImportButton(frame: SquareBurButtonRect,
                                                                            pressed: false,
                                                                            buttonText: "",
                                                                            fontSize: fontSize,
                                                                            disabled: false)
            importButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        
        var importButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: "ImportButtonPressed")
        
        if importButtonPressed == nil {
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawImportButton(frame: SquareBurButtonRect,
                                                                            pressed: true,
                                                                            buttonText: "",
                                                                            fontSize: fontSize,
                                                                            disabled: false)
            importButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
        }
        
        // Set up Style with the images
        if let defaultImage = importButtonDefault,
            let pressedImage = importButtonPressed {
            
            buttonStyle.backgroundImageForState = [.normal : defaultImage,
                                                   .highlighted : pressedImage]
        }
        
        return buttonStyle
    }
    
    public var pdpBackButtonStyle: PoqButtonStyle? {
        
        var pdpBackButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var backButtonPDPDefault: UIImage? = ImageInjectionResolver.loadImage(named: "PDPBackButtonDefault")
        
        if backButtonPDPDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawBackButton(frame: SquareBurButtonRect,
                                                                          pressed: false)
            backButtonPDPDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        
        var backButtonPDPPressed: UIImage? = ImageInjectionResolver.loadImage(named: "PDPBackButtonPressed")
        
        if backButtonPDPPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawBackButton(frame: SquareBurButtonRect,
                                                                          pressed: true)
            backButtonPDPPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = backButtonPDPDefault,
            let pressedImage = backButtonPDPPressed {

            pdpBackButtonStyle.backgroundImageForState = [.normal : defaultImage,
                                                          .highlighted : pressedImage]

        }
        
        return pdpBackButtonStyle
    }
    
    public var closeButtonStyle: PoqButtonStyle? {
        
        var closeButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        let alphaValue = CGFloat(AppSettings.sharedInstance.lookbookCloseButtonAlpha)
        
        var closeButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "CloseButtonDefault")
        
        if closeButtonDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawCloseButton(frame: SquareBurButtonRect, pressed: false, isWhite: false, alpha: alphaValue, hasbackground: false, isCentered: true)
            closeButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        
        var closeButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: "CloseButtonPressed")
        
        if closeButtonPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawCloseButton(frame: SquareBurButtonRect, pressed: true, isWhite: false, alpha: alphaValue, hasbackground: false, isCentered: true)
            closeButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = closeButtonDefault,
            let pressedImage = closeButtonDefault {
            
            closeButtonStyle.backgroundImageForState = [.normal: defaultImage,
                                                          .highlighted: pressedImage]
        }
        
        return closeButtonStyle
    }
    
    public var closeButtonWhiteStyle: PoqButtonStyle? {
        var closeButtonWhiteStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        let alphaValue = CGFloat(AppSettings.sharedInstance.lookbookCloseButtonAlpha)
        
        var closeButtonWhiteDefault: UIImage? = ImageInjectionResolver.loadImage(named: "CloseButtonWhiteDefault")
        
        if closeButtonWhiteDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawCloseButton(frame: SquareBurButtonRect, pressed: false, isWhite: true, alpha: alphaValue, hasbackground: false, isCentered: true)
            closeButtonWhiteDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        
        var closeButtonWhitePressed: UIImage? = ImageInjectionResolver.loadImage(named: "CloseButtonWhitePressed")
        
        if closeButtonWhitePressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawCloseButton(frame: SquareBurButtonRect, pressed: true, isWhite: true, alpha: alphaValue, hasbackground: false, isCentered: true)
            closeButtonWhitePressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = closeButtonWhiteDefault,
            let pressedImage = closeButtonWhitePressed {
            
            closeButtonWhiteStyle.backgroundImageForState = [.normal: defaultImage,
                                                        .highlighted: pressedImage]
        }
        
        return closeButtonWhiteStyle
    }
    
    public var closeButtonRoundedStyle: PoqButtonStyle? {
        
        var closeButtonRoundedStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        let alphaValue = CGFloat(AppSettings.sharedInstance.lookbookCloseButtonAlpha)
        
        var closeButtonRoundedDefault: UIImage? = ImageInjectionResolver.loadImage(named: "CloseButtonRoundedDefault")
        
        if closeButtonRoundedDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawCloseButton(frame: SquareBurButtonRect, pressed: false, isWhite: false, alpha: alphaValue, hasbackground: true, isCentered: true)
            closeButtonRoundedDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        
        var closeButtonRoundedPressed: UIImage? = ImageInjectionResolver.loadImage(named: "CloseButtonRoundedPressed")
        
        if closeButtonRoundedPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawCloseButton(frame: SquareBurButtonRect, pressed: true, isWhite: false, alpha: alphaValue, hasbackground: true, isCentered: true)
            closeButtonRoundedPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = closeButtonRoundedDefault,
            let pressedImage = closeButtonRoundedPressed {
            
            closeButtonRoundedStyle.backgroundImageForState = [.normal: defaultImage,
                                                               .highlighted: pressedImage]
        }
        
        return closeButtonRoundedStyle
    }
    
    public var minusButtonStyle: PoqButtonStyle? {
        
        var minusButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var minusButtonPDPDefault: UIImage? = ImageInjectionResolver.loadImage(named: "MinusButtonDefault")
        
        if minusButtonPDPDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawMinusButton(frame: SquareBurButtonRect, pressed: false, disabled: false)
            minusButtonPDPDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        
        var minusButtonPDPPressed: UIImage? = ImageInjectionResolver.loadImage(named: "MinusButtonDefaultPressed")
        
        if minusButtonPDPPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawMinusButton(frame: SquareBurButtonRect, pressed: true, disabled: false)
            minusButtonPDPPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var minusButtonPDPDisabled: UIImage? = ImageInjectionResolver.loadImage(named: "MinusButtonDisabled")
        
        if minusButtonPDPDisabled == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawMinusButton(frame: SquareBurButtonRect, pressed: true, disabled: true)
            minusButtonPDPDisabled = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = minusButtonPDPDefault,
            let pressedImage = minusButtonPDPPressed,
            let disabledImage = minusButtonPDPDisabled {
            
            minusButtonStyle.backgroundImageForState = [.normal: defaultImage,
                                                          .highlighted: pressedImage,
                                                            .disabled: disabledImage]
        }
        return minusButtonStyle
    }
    
    public var plusButtonStyle: PoqButtonStyle? {
        
        var plusButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var plusButtonPDPDefault: UIImage? = ImageInjectionResolver.loadImage(named: "PlusButtonDefault")
        
        if plusButtonPDPDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
              ResourceProvider.sharedInstance.homePageStyle?.drawPlusButton(frame: SquareBurButtonRect, pressed: false)
            plusButtonPDPDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        
        var plusButtonPDPPressed: UIImage? = ImageInjectionResolver.loadImage(named: "PlusButtonDefaultPressed")
        
        if plusButtonPDPPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawPlusButton(frame: SquareBurButtonRect, pressed: true)
            plusButtonPDPPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = plusButtonPDPDefault,
            let pressedImage = plusButtonPDPPressed {
            
            plusButtonStyle.backgroundImageForState = [.normal: defaultImage,
                                                        .highlighted: pressedImage]
        }
        
        return plusButtonStyle
    }
    
    public var previousButtonStyle: PoqButtonStyle? {
        
        var previousButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var previousButtonPDPDefault: UIImage? = ImageInjectionResolver.loadImage(named: "PreviousButtonDefault")
        
        if previousButtonPDPDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawPreviousButton(frame: SquareBurButtonRect, pressed: false, alpha: CGFloat(AppSettings.sharedInstance.lookbookPreviousAndNextButtonAlpha))
            previousButtonPDPDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        
        var previousButtonPDPPressed: UIImage? = ImageInjectionResolver.loadImage(named: "PreviousButtonDefaultPressed")
        
        if previousButtonPDPPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawPreviousButton(frame: SquareBurButtonRect, pressed: true, alpha: CGFloat(AppSettings.sharedInstance.lookbookPreviousAndNextButtonAlpha))
            previousButtonPDPPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = previousButtonPDPDefault,
            let pressedImage = previousButtonPDPPressed {
            
            previousButtonStyle.backgroundImageForState = [.normal: defaultImage,
                                                       .highlighted: pressedImage]
        }
        
        return previousButtonStyle
    }

    public var nextButtonStyle: PoqButtonStyle? {
        
        var nextButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var nextButtonPDPDefault: UIImage? = ImageInjectionResolver.loadImage(named: "NextButtonDefault")
        
        if nextButtonPDPDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawNextButton(frame: SquareBurButtonRect, pressed: false, alpha: CGFloat(AppSettings.sharedInstance.lookbookPreviousAndNextButtonAlpha))
            nextButtonPDPDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        
        var nextButtonPDPPressed: UIImage? = ImageInjectionResolver.loadImage(named: "NextButtonDefaultPressed")
        
        if nextButtonPDPPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawNextButton(frame: SquareBurButtonRect, pressed: true, alpha: CGFloat(AppSettings.sharedInstance.lookbookPreviousAndNextButtonAlpha))
            nextButtonPDPPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = nextButtonPDPDefault,
            let pressedImage = nextButtonPDPPressed {
            
            nextButtonStyle.backgroundImageForState = [.normal: defaultImage,
                                                           .highlighted: pressedImage]
        }
        
        return nextButtonStyle
    }
    
    public var likeButtonStyle: PoqButtonStyle? {
        
        var likeButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var likeButtonPDPDefault: UIImage? = ImageInjectionResolver.loadImage(named: "LikeButtonPDPDefault")
        
        if likeButtonPDPDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawFavoriteStoreButton(frame: SquareBurButtonRect, pressed: false)
            likeButtonPDPDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        // TODO: typo error with the name of the image button, update to "LikeButtonPDPPressed"
        var likeButtonPDPDefaultPressed: UIImage? = ImageInjectionResolver.loadImage(named: "LikeButtonPDPDefaultPressed")
        
        if likeButtonPDPDefaultPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawFavoriteStoreButton(frame: SquareBurButtonRect, pressed: true)
            likeButtonPDPDefaultPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = likeButtonPDPDefault,
            let pressedImage = likeButtonPDPDefaultPressed {
            
            likeButtonStyle.backgroundImageForState = [.normal: defaultImage,
                                                               .highlighted: pressedImage,
                                                               .selected: pressedImage]
        }
        
        return likeButtonStyle
    }
    
    public var backButtonStyle: PoqButtonStyle? {
        
        var backButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var backButtonDefault = ImageInjectionResolver.loadImage(named: "BackButtonDefault")
        
        if backButtonDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawBackButton(frame: SquareBurButtonRect,
                                                                          pressed: false)
            backButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        
        var backButtonPressed = ImageInjectionResolver.loadImage(named: "BackButtonPressed")
        
        if backButtonPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawBackButton(frame: SquareBurButtonRect,
                                                                          pressed: true)
            backButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = backButtonDefault,
            let pressedImage = backButtonPressed {
            
            backButtonStyle.backgroundImageForState = [.normal: defaultImage,
                                                       .highlighted: pressedImage]
        }
        
        backButtonStyle.shouldAddDropShadow = false
        
        return backButtonStyle
    }
    
    public var scannerButtonStyle: PoqButtonStyle? {
        var scannerButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        let rect = CGRect(x: 0, y: 0, width: 60, height: 40)
        
        var scannerButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "ScannerButtonDefault")
        
        if scannerButtonDefault == nil {
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawSearchScanButton(frame: rect, pressed: false, enableScan: true)
            scannerButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var scannerButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: "ScannerButtonPressed")
        
        if scannerButtonPressed == nil {
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawSearchScanButton(frame: rect, pressed: true, enableScan: true)
            scannerButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var scannerButtonDisabled: UIImage? = ImageInjectionResolver.loadImage(named: "ScannerButtonDisabled")
        
        if scannerButtonDisabled == nil {
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawSearchScanButton(frame: rect, pressed: false, enableScan: false)
            scannerButtonDisabled = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        if let defaultImage = scannerButtonDefault, let pressedImage = scannerButtonPressed, let disabledImage = scannerButtonDisabled {
            
            scannerButtonStyle.backgroundImageForState = [.normal: defaultImage, .highlighted: pressedImage, .disabled: disabledImage]
        }
        
        return scannerButtonStyle
        
    }
    
    public var visualSearchButtonStyle: PoqButtonStyle? {
        
        var visualSearchButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        let visualSearchButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "VisualSearchButtonDefault")
        
        let visualSearchButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: "VisualSearchButtonPressed")
        
        if let defaultImage = visualSearchButtonDefault, let pressedImage = visualSearchButtonPressed {
            visualSearchButtonStyle.backgroundImageForState = [.normal: defaultImage, .highlighted: pressedImage]
        }
        
        return visualSearchButtonStyle
    }
    
    public var lookbookButtonStyle: PoqButtonStyle? {
        
        var lookbookButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        let fontSize = AppTheme.sharedInstance.shopTheLookButtonLabelFont.pointSize
        
        let frame = CGRect(x: 0, y: 0, width: AppSettings.sharedInstance.shopTheLookButtonWidth, height: 30)
        
        var lookbookButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "LookbookButtonDefault")
        
        if lookbookButtonDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawLookbookButton(frame: frame, pressed: false, buttonText: "", fontSize: fontSize)
            lookbookButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var lookbookButtonSelected: UIImage? = ImageInjectionResolver.loadImage(named: "LookbookButtonSelected")
        
        if lookbookButtonSelected == nil {
            // Draw Selected Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawLookbookButton(frame: frame, pressed: false, buttonText: "", fontSize: fontSize)
            lookbookButtonSelected = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        lookbookButtonStyle.font = AppTheme.sharedInstance.shopTheLookButtonLabelFont
        
        lookbookButtonStyle.titleColorForState = [.normal: UIColor.black]
        
        // Set up Style with the images
        if let defaultImage = lookbookButtonDefault,
            let selectedImage = lookbookButtonSelected {
            
            lookbookButtonStyle.backgroundImageForState = [.normal: defaultImage,
                                                           .highlighted: selectedImage,
                                                           .selected: selectedImage]
        }
        
        return lookbookButtonStyle
    }
    
    public var showHideButtonStyle: PoqButtonStyle? {
        
        var showHideButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        let frame = CGRect(x: 0, y: 0, width: 47, height: 50)
        
        var showHideButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "ShowHideButtonDefault")
        
        if showHideButtonDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawShowHideButton(frame: frame, pressed: false, buttonText: AppLocalization.sharedInstance.signUpShowText, pressedText: "")
            showHideButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var showHideButtonSelected: UIImage? = ImageInjectionResolver.loadImage(named: "ShowHideButtonSelected")
        
        if showHideButtonSelected == nil {
            // Draw Selected Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawShowHideButton(frame: frame, pressed: true, buttonText: "", pressedText: AppLocalization.sharedInstance.signUpHideText)
            showHideButtonSelected = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
                
        // Set up Style with the images
        if let defaultImage = showHideButtonDefault,
            let selectedImage = showHideButtonSelected {
            
            showHideButtonStyle.backgroundImageForState = [.normal: defaultImage,
                                                           .highlighted: selectedImage,
                                                           .selected: selectedImage]
        }
        
        return showHideButtonStyle
    }

    public var retryButtonStyle: PoqButtonStyle? {
        
        var retryButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        let frame = CGRect(x: 0, y: 0, width: 67, height: 106)
        
        var retryButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "RetryButtonDefault")
        
        if retryButtonDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawRetry(frame: frame, pressed: false, buttonText: AppLocalization.sharedInstance.retryText)
            retryButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var retryButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: "RetryButtonPressed")
        
        if retryButtonPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawRetry(frame: frame, pressed: true, buttonText: AppLocalization.sharedInstance.retryText)
            retryButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = retryButtonDefault,
            let pressedImage = retryButtonPressed {
            
            retryButtonStyle.backgroundImageForState = [.normal: defaultImage, .highlighted: pressedImage]
        }
        
        return retryButtonStyle
    }
    
    public var leftSideMenuStyle: PoqButtonStyle? {
        
        var leftSideMenuStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        let frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        
        var leftSideMenuDefault: UIImage? = ImageInjectionResolver.loadImage(named: "LeftSideMenuDefault")
        
        if leftSideMenuDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawLeftMenu(frame: frame, pressed: false)
            leftSideMenuDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var leftSideMenuPressed: UIImage? = ImageInjectionResolver.loadImage(named: "LeftSideMenuPressed")
        
        if leftSideMenuPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawLeftMenu(frame: frame, pressed: true)
            leftSideMenuPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = leftSideMenuDefault,
            let pressedImage = leftSideMenuPressed {
            
            leftSideMenuStyle.backgroundImageForState = [.normal: defaultImage, .highlighted: pressedImage]
        }
        
        return leftSideMenuStyle
    }
    
    public var forceUpdateButtonStyle: PoqButtonStyle? {
        var buttonStyle = PoqButtonStyle()
        buttonStyle.backgroundColor = AppTheme.sharedInstance.forceUpdateButtonBackgroundColor
        
        let cornerRadius = CGFloat(AppSettings.sharedInstance.forceUpdateButtonCornerRadius)
        let colorsForControlStates: [UIControlState: UIColor] = [.normal: AppTheme.sharedInstance.forceUpdateButtonBackgroundColor, .disabled: AppTheme.sharedInstance.forceUpdateButtonBackgroundColor, .highlighted: AppTheme.sharedInstance.forceUpdateButtonBackgroundColor]
        
        buttonStyle.backgroundImageForState = getBackgroundImagesForColorsOfStates(colorForState: colorsForControlStates, cornerRadius: cornerRadius)
        buttonStyle.font = AppTheme.sharedInstance.forceUpdateLabelFont
        buttonStyle.titleColorForState = [.normal: AppTheme.sharedInstance.forceUpdateButtonColor]
        buttonStyle.cornerRadius = cornerRadius
        return buttonStyle
    }
    
    public var mySizeKidsButtonStyle: PoqButtonStyle? {
        var mySizeKidsButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var mySizeKidsButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "MySizeKidsButtonDefault")
        
        if mySizeKidsButtonDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawMySizeKids(frame: SquareBurButtonRect, pressed: false)
            mySizeKidsButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var mySizeKidsButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: "MySizeKidsButtonPressed")
        
        if mySizeKidsButtonPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawMySizeKids(frame: SquareBurButtonRect, pressed: true)
            mySizeKidsButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = mySizeKidsButtonDefault,
            let pressedImage = mySizeKidsButtonPressed {
            
            mySizeKidsButtonStyle.backgroundImageForState = [.normal: defaultImage, .highlighted: pressedImage]
        }
        
        return mySizeKidsButtonStyle
    }

    public var mySizeWomanButtonStyle: PoqButtonStyle? {
        var mySizeWomanButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var mySizeWomanButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "MySizeWomanButtonDefault")
        
        if mySizeWomanButtonDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawMySizeFemale(frame: SquareBurButtonRect, pressed: false)
            mySizeWomanButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var mySizeWomanButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: "MySizeWomanButtonPressed")
        
        if mySizeWomanButtonPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawMySizeFemale(frame: SquareBurButtonRect, pressed: true)
            mySizeWomanButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = mySizeWomanButtonDefault,
            let pressedImage = mySizeWomanButtonPressed {
            
            mySizeWomanButtonStyle.backgroundImageForState = [.normal: defaultImage, .highlighted: pressedImage]
        }
        
        return mySizeWomanButtonStyle
    }
    
    public var mySizeManButtonStyle: PoqButtonStyle? {
        var mySizeManButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var mySizeManButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "MySizeManButtonDefault")
        
        if mySizeManButtonDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawMySizeMale(frame: SquareBurButtonRect, pressed: false)
            mySizeManButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var mySizeManButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: "MySizeManButtonPressed")
        
        if mySizeManButtonPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawMySizeMale(frame: SquareBurButtonRect, pressed: true)
            mySizeManButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = mySizeManButtonDefault,
            let pressedImage = mySizeManButtonPressed {
            
            mySizeManButtonStyle.backgroundImageForState = [.normal: defaultImage, .highlighted: pressedImage]
        }
        
        return mySizeManButtonStyle
    }
    
    public var directionButtonStyle: PoqButtonStyle? {
        var directionButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var directionButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "DirectionButtonDefault")
        
        if directionButtonDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawDirectionButton(frame: SquareBurButtonRect, pressed: false)
            directionButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var directionButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: "DirectionButtonPressed")
        
        if directionButtonPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawDirectionButton(frame: SquareBurButtonRect, pressed: true)
            directionButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = directionButtonDefault,
            let pressedImage = directionButtonPressed {
            
            directionButtonStyle.backgroundImageForState = [.normal: defaultImage, .highlighted: pressedImage]
        }
        
        return directionButtonStyle
    }
    
    public var wishListCloseButtonStyle: PoqButtonStyle? {
        var wishListCloseButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        let alphaValue: CGFloat = 0.5
        
        var wishListCloseButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "WishListCloseButtonDefault")
        
        if wishListCloseButtonDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawWishListCloseButton(frame: SquareBurButtonRect, pressed: false, alpha: alphaValue)
            wishListCloseButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var wishListCloseButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: "WishListCloseButtonPressed")
        
        if wishListCloseButtonPressed == nil {
            // Draw Pressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawWishListCloseButton(frame: SquareBurButtonRect, pressed: true, alpha: alphaValue)
            wishListCloseButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = wishListCloseButtonDefault,
            let pressedImage = wishListCloseButtonPressed {
            
            wishListCloseButtonStyle.backgroundImageForState = [.normal: defaultImage, .highlighted: pressedImage]
        }
        
        return wishListCloseButtonStyle
    }
    
    // MARK: - UIView

    public func getLogoView (forFrame frame: CGRect) -> UIView? {
  
        return Logo(frame: frame)
    }
    
    // MARK: - UIImage

    public var voucherDetailHeaderImage: UIImage? {
        
        return UIImage(named: "PoqLogo", in: Bundle(identifier: "com.poq.platform"), compatibleWith: nil)
    }

    public var pdpWishlistButtonImageDefault: UIImage? {
        return ImageInjectionResolver.loadImage(named: "LikeButtonImageDefault")
    }
    
    public var pdpWishlistButtonImagePressed: UIImage? {
        return ImageInjectionResolver.loadImage(named: "LikeButtonImagePressed")
    }
    
    // MARK: - PDP Ratings -
    
    public var pdpRatingStarsUnfilledColor: UIColor? {
        return .lightGray
    }
    
    public var pdpRatingStarsFilledColor: UIColor? {
        return .black
    }
    
    // MARK: - Bag
    
    public func createBagControl() -> BadgedControl & BarButtonItemProvider {
        let rightSideMenu = RightSideMenu(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        rightSideMenu.backgroundColor = UIColor.clear
        return rightSideMenu
    }
    
    public func getBackgroundImagesForColorsOfStates(colorForState: [UIControlState: UIColor], cornerRadius: CGFloat) -> [UIControlState: UIImage?] {
        var imagesForStates = [UIControlState: UIImage?]()
        colorForState.keys.forEach({ controlState in
            if let colorForState = colorForState[controlState] {
                let image = UIImage.createResizableColoredImage(colorForState, cornerRadius: cornerRadius)
                imagesForStates[controlState] = image
            }
        })
        
        return imagesForStates
    }
    
    // MARK: - BorderedButton

    public func adjustBorderedNavigationBarButtonSize(basedOn size: CGSize) -> CGSize {
        
        let minimumWidth: CGFloat = 50.0
        
        // If the button is going to be under minimumWidth, do it minimumWidth
        // Else just return the actual size
        if size.width < minimumWidth {
            return CGSize(width: minimumWidth, height: size.height)
        } else {
            return size
        }
    }
}
