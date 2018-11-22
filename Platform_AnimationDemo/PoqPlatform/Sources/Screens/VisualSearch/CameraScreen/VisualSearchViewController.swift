//
//  VisualSearchViewController.swift
//  Poq.iOS.Platform
//
//  Created by Manuel Marcos Regalado on 19/02/2018.
//

import Foundation
import UIKit
import AVFoundation
import PoqUtilities
import PoqAnalytics

open class VisualSearchViewController: PoqBaseViewController, VisualSearchPresenter {
    
    public static let overlayShownStatusDefaultsKey = "PoqVisualSearchOverlayShownStatus"
    public static let visualSearchCameraViewAccessibilityId = "visualSearchCameraViewAccessibilityId"
    public static let visualSearchViewAccessibilityId = "visualSearchViewAccessibilityId"
    public static let visualSearchCameraSwitchNavButtonAccessibilityId = "visualSearchCameraSwitchNavButtonAccessibilityId"
    public static let visualSearchCameraFlashNavButtonAccessibilityId = "visualSearchCameraFlashNavButtonAccessibilityId"
    public static let visualSearchGalleryButtonAccessibilityId = "visualSearchGalleryButtonAccessibilityId"
    public static let visualSearchPhotoImageViewAccessibilityId = "visualSearchPhotoImageViewAccessibilityId"
    public static let visualSearchCameraButtonAccessibilityId = "visualSearchCameraButtonAccessibilityId"
    public static let visualSearchRetakeButtonAccessibilityId = "visualSearchRetakeButtonAccessibilityId"
    public static let visualSearchUsePhotoButtonAccessibilityId = "visualSearchUsePhotoButtonAccessibilityId"
    
    @IBOutlet weak var blurCameraOverlayView: UIVisualEffectView?
    @IBOutlet weak public var cameraButton: UIButton? {
        didSet {
            cameraButton?.addTarget(self, action: #selector(cameraButtonTapped), for: UIControlEvents.touchUpInside)
        }
    }
    @IBOutlet weak public var galleryButton: UIButton? {
        didSet {
            galleryButton?.addTarget(self, action: #selector(galleryButtonTapped), for: UIControlEvents.touchUpInside)
        }
    }
    @IBOutlet weak public var cameraView: UIView? {
        didSet {
            // A fade in animation will happen as soon as the camera is available
            cameraView?.alpha = 0
        }
    }
    @IBOutlet weak public var photoImageView: UIImageView?
    @IBOutlet weak var submitButtonsEffectView: UIVisualEffectView?
    @IBOutlet weak public var usePhotoButton: UIButton? {
        didSet {
            usePhotoButton?.addBorders([.left], color: .black, width: 2.0)
            usePhotoButton?.addTarget(self, action: #selector(usePhotoButtonTapped), for: UIControlEvents.touchUpInside)
        }
    }
    @IBOutlet weak public var retakeButton: UIButton? {
        didSet {
            retakeButton?.addTarget(self, action: #selector(retakeButtonTapped), for: UIControlEvents.touchUpInside)
        }
    }
    lazy public var visualSearchCameraController: VisualSearchCameraDelegate = {
        return VisualSearchCameraController()
    }()
    
    lazy public var visualSearchGalleryController: VisualSearchGalleryDelegate = {
        return VisualSearchGalleryController()
    }()
    public var flashNavBarButton: UIBarButtonItem?
    public var changeNavBarButton: UIBarButtonItem?

    public var hideCameraControls: Bool? {
        didSet {
            self.navigationController?.setNavigationBarHidden(hideCameraControls ?? true, animated: false)
            blurCameraOverlayView?.isHidden = !(hideCameraControls ?? false)
        }
    }

    public var visualSearchCameraViewControllerMode: VisualSearchCameraViewControllerMode = .cameraNotReady
    fileprivate var visualSearchAnalyticsImageSource = VisualSearchImageSource.camera
    
    // MARK: - Constant duration animations
    
    fileprivate static let hideControlsAnimationDuration = 0.1
    fileprivate static let showCameraAnimationDuration = 0.3
    fileprivate static let flipCameraViewsAnimationDuration = 0.5
    
    // MARK: - Life cycle view controller
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Set up Views
        setupAppearance()
        // Set up accessible identifiers
        setUpAccessibilityIdentifiers()
        // Set the notifiers
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if visualSearchCameraViewControllerMode == .cameraReady {
           pauseCameraController()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch visualSearchCameraViewControllerMode {
        case .cameraNotReady:
            setUpCameraController()
        case .cameraReady:
            resumeCameraController()
        default:
            break
        }
    }
    
    @objc func applicationWillResignActive() {
        if visualSearchCameraViewControllerMode == .cameraReady {
            pauseCameraController()
        }
    }
    
    @objc func applicationDidBecomeActive() {
        if visualSearchCameraViewControllerMode == .cameraReady {
            resumeCameraController()
        }
    }
    
    // MARK: - Configuration
    
    public func pauseCameraController() {
        hideCameraControls = true
        visualSearchCameraController.pauseCamera()
    }
    
    public func resumeCameraController() {
        visualSearchCameraController.resumeCamera { [weak self] (error: CameraError?) in
            guard let strongSelf = self else {
                Log.error("Cannot get self")
                return
            }
            if let cameraControllerError = error {
                strongSelf.dismissViewController(withError: cameraControllerError)
            } else {
                strongSelf.hideCameraControls = false
            }
        }
    }
    
    public func setUpCameraController() {
        createSpinnerView()
        visualSearchCameraController.startCamera { [weak self] (error: CameraError?) in
            guard let strongSelf = self else {
                Log.error("Cannot get self")
                return
            }
            if let cameraControllerError = error {
                Log.error(cameraControllerError.localizedDescription)
                strongSelf.dismissViewController(withError: cameraControllerError)
            } else {
                strongSelf.presentCameraView()
            }
        }
    }
    
    func presentCameraView() {
        guard let cameraViewUnwrapped = cameraView else {
            return
        }
        visualSearchCameraController.displayCameraView(on: cameraViewUnwrapped) { [weak self] (error: CameraError?) in
            guard let strongSelf = self else {
                Log.error("Cannot get self")
                return
            }
            if let cameraControllerError = error {
                strongSelf.dismissViewController(withError: cameraControllerError)
            } else {
                strongSelf.removeSpinnerView()
                strongSelf.hideCameraControls = false
                UIView.animate(withDuration: VisualSearchViewController.showCameraAnimationDuration, animations: {
                    strongSelf.cameraView?.alpha = 1
                    strongSelf.visualSearchCameraViewControllerMode = .cameraReady
                })
            }
        }
    }
    
    // MARK: - Setup Views

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    public func setUpRightNavBarButtons() {
        let imageNameFlashNavBarButton = visualSearchCameraController.flashMode == .on ? "CameraFlash": "CameraFlashDisabled"
        flashNavBarButton = setUpRightNavBarButton(imageName: imageNameFlashNavBarButton, action: #selector(cameraFlashAction))
        changeNavBarButton = setUpRightNavBarButton(imageName: "CameraChange", action: #selector(cameraChangeAction))
        guard let flashNavBarButtonUnwrapped = flashNavBarButton,
            let changeNavBarButtonUnwrapped = changeNavBarButton else {
                Log.error("Failed to create bar button item")
                return
        }
        self.navigationItem.rightBarButtonItems = [changeNavBarButtonUnwrapped, flashNavBarButtonUnwrapped]
    }
    
    func setUpRightNavBarButton(imageName: String, action: Selector) -> UIBarButtonItem? {
        guard let buttonImage = ImageInjectionResolver.loadImage(named: imageName) else {
            Log.error("Failed to create bar button images")
            return nil
        }
        let button = UIButton.init(type: .custom)
        button.setImage(buttonImage, for: UIControlState.normal)
        button.addTarget(self, action: action, for: UIControlEvents.touchUpInside)
        button.frame = SquareBurButtonRect
        return UIBarButtonItem(customView: button)
    }
    
    public func setUpTransparentNavigationBar() {
        // Set background color to clear to show camera background
        navigationItem.titleView = nil
        navigationController?.navigationBar.setBackgroundImage(toColor: .clear)
        navigationController?.navigationBar.setShadowImage(toColor: .clear)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self, isWhite: true)
    }
    
    public func setupAppearance() {
        setUpTransparentNavigationBar()
        setUpRightNavBarButtons()
        setUpCameraControls()
        setUpGalleryButton()
    }
    
    public func setUpCameraControls() {
        // Hide the controls until the camera is available
        self.hideCameraControls = true
    }
    
    public func setUpGalleryButton() {
        let galleryButtonSize = CGSize(width: galleryButton?.frame.size.width ?? 0.0, height: galleryButton?.frame.size.height ?? 0.0)
        visualSearchGalleryController.galleryThumbnail(size: galleryButtonSize) { [weak self] (image: UIImage?, error: GalleryError?) in
            guard let strongSelf = self else {
                Log.error("Cannot get self")
                return
            }
            if error != nil {
                // We have an error so we display the placeholder image
                strongSelf.displayGalleryThumbnailPlaceHolder()
            } else {
                strongSelf.galleryButton?.setImage(image, for: .normal)
                strongSelf.galleryButton?.layer.borderWidth = 2.0
                strongSelf.galleryButton?.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func usePhotoButtonTapped() {
        if let imageCaptured = photoImageView?.image {
            let controller = VisualSearchCropViewController(image: imageCaptured, source: visualSearchAnalyticsImageSource)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func retakeButtonTapped() {
        // Change the controller mode back to camera
        visualSearchCameraViewControllerMode = .cameraReady
        hideCapturedPhotoViews(true)
    }
    
    @objc func cameraFlashAction() {
        visualSearchCameraController.flashMode = visualSearchCameraController.flashMode == .on ? .off : .on
        // Reset Navigation buttons
        flashNavBarButton = nil
        changeNavBarButton = nil
        navigationItem.rightBarButtonItems = nil
        setUpRightNavBarButtons()
    }
    
    @objc func cameraChangeAction() {
        // 1.- ANIMATION CAMERA CHANGE - Haptic feedback
        hapticFeedback()
        
        // 2.- ANIMATION CAMERA CHANGE - Animate the controls to hide
        UIView.animate(withDuration: VisualSearchViewController.hideControlsAnimationDuration, animations: {
            self.hideCameraControls = true
        }, completion: flipCameraViewsAnimationCompletion())
        
        // 3 AND 4 STEPS ARE DEFINED IN FUNCTIONS 3.-flipCameraViewsAnimationCompletion() and 4.-switchCameraAnimationCompletion()
    }
    
    // 3.- ANIMATION CAMERA CHANGE - Flip camera view animation
    func flipCameraViewsAnimationCompletion() -> ((Bool) -> Void) {
        return { (_: Bool) in
            guard let cameraViewUnwrapped = self.cameraView else {
                Log.error("Cannot animate view because the view is not there")
                return
            }
            UIView.transition(with: cameraViewUnwrapped, duration: VisualSearchViewController.flipCameraViewsAnimationDuration, options: [.transitionFlipFromLeft, .allowAnimatedContent], animations: nil, completion: self.switchCameraAnimationCompletion())
        }
    }
    
    // 4.- ANIMATION CAMERA CHANGE - Switch camera animation completion block
    func switchCameraAnimationCompletion() -> ((Bool) -> Void) {
        return { (_: Bool) in
            self.visualSearchCameraController.switchCameras(completion: { [weak self] (error: CameraError?) in
                guard let strongSelf = self else {
                    Log.error("Cannot get self")
                    return
                }
                if let cameraControllerError = error {
                    strongSelf.dismissViewController(withError: cameraControllerError)
                } else {
                    strongSelf.hideCameraControls = false
                }
            })
        }
    }
    
    @objc func cameraButtonTapped() {
        hapticFeedback()
        visualSearchCameraController.takePicture { [weak self] (image: UIImage?, error: Error?) in
            guard let strongSelf = self else {
                Log.error("Cannot get self")
                return
            }
            guard let imageUnwrapped = image else {
                Log.error("There wasn't an image to set")
                return
            }
            strongSelf.photoImageView?.contentMode = .scaleAspectFill
            strongSelf.visualSearchAnalyticsImageSource = .camera
            strongSelf.displayPicture(image: imageUnwrapped)
        }
    }
    
    func displayPicture(image: UIImage) {
        self.visualSearchCameraViewControllerMode = .capturedPhoto
        self.photoImageView?.image = image
        self.hideCapturedPhotoViews(false)
    }
    
    func hideCapturedPhotoViews(_ hide: Bool) {
        self.photoImageView?.isHidden = hide
        self.submitButtonsEffectView?.isHidden = hide
        hide ? resumeCameraController() : pauseCameraController()
    }
    
    @objc func galleryButtonTapped() {
        visualSearchGalleryController.openGallery(fromViewController: self) { (error: GalleryError?) in
            if let galleryControllerError = error,
                galleryControllerError == .galleryPermissionError {
                weak var weakSelf = self
                guard let strongSelf = weakSelf else {
                    Log.error("Cannot get self")
                    return
                }
                strongSelf.showPrivacyHelper(for: .photo, controller: { _ in }, didPresent: { }, didDismiss: nil, useDefaultSettingPane: false)
            }
        }
    }
    
    // MARK: - Helpers
    
    public func hapticFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    func dismissViewController(withError error: CameraError) {
        visualSearchCameraViewControllerMode = .cameraUnavailable
        let didDismiss = {
            self.dismiss(animated: true, completion: nil)
        }
        if error == .cameraPermissionError {
            visualSearchCameraViewControllerMode = .cameraUnavailable
            showPrivacyHelper(for: .camera, controller: { _ in }, didPresent: { }, didDismiss: didDismiss, useDefaultSettingPane: false)
        } else {
            displayError(error: "VISUAL_SEARCH_UNAVAILABLE".localizedPoqString)
            didDismiss()
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            assert(false, "Picker controller return without an image")
            return
        }
        visualSearchAnalyticsImageSource = .photos
        photoImageView?.contentMode = .scaleAspectFit
        displayPicture(image: image)
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - Accessibility
    
    public func setUpAccessibilityIdentifiers() {
        view.accessibilityIdentifier = VisualSearchViewController.visualSearchViewAccessibilityId
        view.isAccessibilityElement = true
        cameraView?.accessibilityIdentifier = VisualSearchViewController.visualSearchCameraViewAccessibilityId
        cameraView?.isAccessibilityElement = true
        changeNavBarButton?.customView?.accessibilityIdentifier = VisualSearchViewController.visualSearchCameraSwitchNavButtonAccessibilityId
        changeNavBarButton?.customView?.isAccessibilityElement = true
        flashNavBarButton?.customView?.accessibilityIdentifier = VisualSearchViewController.visualSearchCameraFlashNavButtonAccessibilityId
        flashNavBarButton?.customView?.isAccessibilityElement = true
        galleryButton?.accessibilityIdentifier = VisualSearchViewController.visualSearchGalleryButtonAccessibilityId
        galleryButton?.isAccessibilityElement = true
        photoImageView?.accessibilityIdentifier = VisualSearchViewController.visualSearchPhotoImageViewAccessibilityId
        photoImageView?.isAccessibilityElement = true
        cameraButton?.accessibilityIdentifier = VisualSearchViewController.visualSearchCameraButtonAccessibilityId
        cameraButton?.isAccessibilityElement = true
        usePhotoButton?.isAccessibilityElement = true
        usePhotoButton?.accessibilityIdentifier = VisualSearchViewController.visualSearchUsePhotoButtonAccessibilityId
        retakeButton?.isAccessibilityElement = true
        retakeButton?.accessibilityIdentifier = VisualSearchViewController.visualSearchRetakeButtonAccessibilityId
    }                
}
