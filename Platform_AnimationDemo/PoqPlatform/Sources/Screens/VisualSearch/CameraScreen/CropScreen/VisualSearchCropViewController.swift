//
//  VisualSearchCropViewController.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 01/05/2018.
//

import Foundation
import PoqUtilities
import PoqAnalytics

open class VisualSearchCropViewController: PoqBaseViewController {
    
    public static let visualSearchMinimumImageSize = CGSize(width: 200.0, height: 200.0)
    public static let visualSearchDoneButtonAccessibilityId = "visualSearchDoneButtonAccessibilityId"
    public static let visualSearchCancelButtonAccessibilityId = "visualSearchCancelButtonAccessibilityId"
    public static let visualSearchCropViewAccessibilityId = "visualSearchCropViewAccessibilityId"
    public static let visualSearchCropAlertViewAccessibilityId = "visualSearchCropAlertViewAccessibilityId"
    
    open var visualSearchImage: UIImage
    open var visualSearchAnalyticsImageSource: VisualSearchImageSource
    open var cropView: VisualSearchCropView?
    @IBOutlet weak open var croppingContainerView: UIView?
    @IBOutlet weak open var submitButtonsEffectView: UIVisualEffectView?
    @IBOutlet weak open var cancelButton: UIButton? {
        didSet {
            cancelButton?.isAccessibilityElement = true
            cancelButton?.accessibilityIdentifier = VisualSearchCropViewController.visualSearchCancelButtonAccessibilityId
            cancelButton?.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak open var doneButton: UIButton? {
        didSet {
            doneButton?.isAccessibilityElement = true
            doneButton?.accessibilityIdentifier = VisualSearchCropViewController.visualSearchDoneButtonAccessibilityId
            doneButton?.addBorders([.left], color: .black, width: 2.0)
            doneButton?.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        }
    }
    public init(image: UIImage, source: VisualSearchImageSource) {
        visualSearchImage = image
        visualSearchAnalyticsImageSource = source
        super.init(nibName: VisualSearchCropViewController.XibName, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.isAccessibilityElement = true
        view.accessibilityIdentifier = VisualSearchCropViewController.visualSearchCropViewAccessibilityId
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        addCropView()
    }
    
    open func addCropView() {
        // Add CropView
        guard let frame = croppingContainerView?.bounds else {
            Log.error("Couldn't get Cropping Container View frame")
            return
        }
        cropView = VisualSearchCropView(frame: frame, image: visualSearchImage)
        guard let visualSearchCropView = cropView else {
            Log.error("Couldn't create crop view")
            return
        }
        croppingContainerView?.autoresizingMask = .flexibleWidth
        croppingContainerView?.addSubview(visualSearchCropView)
        guard let submitButtonsEffectViewUnwrapped = submitButtonsEffectView else {
            Log.error("Couldn't get buttons")
            return
        }
        // Make sure that the buttons view is above the rest of the views so buttons are tappable
        view.bringSubview(toFront: submitButtonsEffectViewUnwrapped)
    }

    // MARK: - Actions

    @objc open func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc open func doneButtonTapped(_ sender: UIBarButtonItem) {
        guard let image = cropView?.croppedImage() else {
            Log.error("Couldn't get cropped image")
            return
        }
        if image.size.width > VisualSearchCropViewController.visualSearchMinimumImageSize.width && image.size.height > VisualSearchCropViewController.visualSearchMinimumImageSize.height {
            dismiss(animated: true) {
                let cropped = self.hasCroppedOriginalImage(forNewImage: image)
                let poqVisualSearchImageAnalyticsData = PoqVisualSearchImageAnalyticsData(source: self.visualSearchAnalyticsImageSource, crop: cropped)
                let visualSearchResultsListViewController = VisualSearchResultsListViewController(image: image, imageAnalyticsData: poqVisualSearchImageAnalyticsData)
                NavigationHelper.sharedInstance.openController(visualSearchResultsListViewController)
            }
        } else {
            let alertController = UIAlertController(title: "ERROR".localizedPoqString, message: "VISUAL_SEARCH_INVALID_IMAGE_SIZE".localizedPoqString, preferredStyle: .alert)
            alertController.view.isAccessibilityElement = true
            alertController.view.accessibilityIdentifier = VisualSearchCropViewController.visualSearchCropAlertViewAccessibilityId
            alertController.addAction(UIAlertAction(title: "OK".localizedPoqString, style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    open func hasCroppedOriginalImage(forNewImage: UIImage) -> Bool {
        if visualSearchImage.size.width == forNewImage.size.width &&
            visualSearchImage.size.height == forNewImage.size.height {
            return false
        }
        return true
    }
}
