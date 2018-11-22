//
//  VisualSearchPresenter.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 26/02/2018.
//

import Foundation
import PoqNetworking
import PoqUtilities

/// This will be the mode that the view controller can adopt to
///
/// - cameraReady: This mode will be when the camera is available and in the fore most view
/// - cameraNotReady: This mode will be when the camera is being initialised and not ready
/// - cameraUnavailable: This mode will be when the camera is not available, for example, it might not be available if the user has denied permissions
/// - capturedPhoto: This mode will be when the user has taken a picture and is being shown in the fore most view
public enum VisualSearchCameraViewControllerMode {
    case cameraReady
    case cameraNotReady
    case cameraUnavailable
    case capturedPhoto
}

/// VisualSearchPresenter defines the design that Visual Search presentation should follow. Any View Controller wishing to implement visual search should implement this protocol.
public protocol VisualSearchPresenter: PoqPresenter, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UI Appearance
    
    /// This function is in charge of setting up the appearance of the views in the controller. From their color to their state. It will be trigger from `viewDidLoad()`
    func setupAppearance()
    
    /// This function will initiliase the camera controls to its initial state. It gets trigger from `setUpViewsAppearance()`
    func setUpCameraControls()
    
    /// This function will set the gallery button. WARNING: At this point, user might not have given access to the gallery yet so please check for permissions and use `VisualSearchGalleryController` for Gallery usage. It gets trigger from `setUpViewsAppearance()`
    func setUpGalleryButton()
    
    /// Sets the navigation Bar to be transparent so the camera is full screen but the navigation buttons are visible. It gets trigger from `setUpViewsAppearance()`
    func setUpTransparentNavigationBar()
    
    /// This function sets up the navigation buttons in the navigation bar. It gets trigger from `setUpViewsAppearance()`
    func setUpRightNavBarButtons()
    
    /// This function is in charge of setting up the camera controller and display the camera on top of the visual search viewcontroller's view. It will be trigger from `viewDidLoad()`
    func setUpCameraController()
    
    /// This function should pause the camera capturing
    func pauseCameraController()
    
    /// This function should resume the camera capturing
    func resumeCameraController()
    
    /// The outlet for the gallery button to be hooked
    var galleryButton: UIButton? { get set }
    
    // MARK: - Controllers
    
    /// This controller will be responsible for handling the `VisualSearchCameraDelegate`` implementation
    var visualSearchCameraController: VisualSearchCameraDelegate { get set }
    
    /// This controller will be responsible for handling the ``VisualSearchGalleryDelegate` implementation
    var visualSearchGalleryController: VisualSearchGalleryDelegate { get set }
    
    // MARK: - Display Error
    
    /// This function will display the given message as an alert view error
    ///
    /// - Parameter error: The given error to be displayed
    func displayError(error: String)
    
    /// This function must be implemented to give accessibility identifiers too al accessible views
    func setUpAccessibilityIdentifiers()
    
    /// This var will define the mode that the view controller is in.
    var visualSearchCameraViewControllerMode: VisualSearchCameraViewControllerMode { get set }
}

extension VisualSearchPresenter where Self: PoqBaseViewController {        
    
    public func displayGalleryThumbnailPlaceHolder() {
        guard let buttonGalleryImage = ImageInjectionResolver.loadImage(named: "galleryPhoto") else {
            Log.error("Failed to create image")
            return
        }
        galleryButton?.setImage(buttonGalleryImage, for: .normal)
    }

    // MARK: - PoqPresenter
    
    public func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        Log.error("No networking being handled")
    }
    
    // MARK: - Display Error
    
    public func displayError(error: String) {
        let alertViewController = UIAlertController(title: "ERROR".localizedPoqString, message: error, preferredStyle: UIAlertControllerStyle.alert)
        alertViewController.addAction(UIAlertAction(title: "OK".localizedPoqString, style: UIAlertActionStyle.default, handler: nil))
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    public static var shouldShowOverlay: Bool {
        // Check first if the feature flag is on for early exit
        guard AppSettings.sharedInstance.enableVisualSearch else {
            return false
        }
        let alreadyShown = UserDefaults.standard.bool(forKey: VisualSearchViewController.overlayShownStatusDefaultsKey)
        // If it hasn't been shown it will be show now so we automatically set it be shown
        if alreadyShown == false {
            UserDefaults.standard.set(true, forKey: VisualSearchViewController.overlayShownStatusDefaultsKey)
            UserDefaults.standard.synchronize()
        }
        return !alreadyShown
    }    
}
