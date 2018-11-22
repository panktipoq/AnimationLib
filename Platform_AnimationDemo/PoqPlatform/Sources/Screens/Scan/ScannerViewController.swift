//
//  ScannerViewController.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 2/26/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import AVFoundation
import DBPrivacyHelper
import PoqModuling
import PoqNetworking
import PoqAnalytics
import RSBarcodes_Swift
import UIKit

public enum PoqBarcodeType: String {
    // Handle different type
    case QR = "org.iso.QRCode"
    case EAN13 = "org.gs1.EAN-13"
    case EAN8 = "org.gs1.EAN-8"
    case Code39 = "org.iso.Code39"
    case UPCE = "org.gs1.UPC-E"
    case Code128 = "org.iso.Code128"
}

public enum BarcodeInputType: String {
    case manual = "Manual"
    case scan = "Scan"
}

open class ScannerViewController: PoqBaseViewController, UITextFieldDelegate, UIAlertViewDelegate, BlackButtonDelegate {

    override open var screenName: String {
        return "Product Scan Screen"
    }
    
    // Barcode scanner view
    @IBOutlet var topLabel: UILabel?
    @IBOutlet var bottomLabel: UILabel?
    @IBOutlet var scanFrame: ScanFrame?
    @IBOutlet open var manualEnterButton: BlackButton?
    @IBOutlet weak var manualEnterButtonLeadingSpace: NSLayoutConstraint?
    @IBOutlet weak var manualEnterButtonTrailingSpace: NSLayoutConstraint?
    @IBOutlet weak var manuallyEnterSubmitButtonLeadingSpace: NSLayoutConstraint?
    @IBOutlet weak var manuallyEnterSubmitButtonTrailingSpace: NSLayoutConstraint?
    
    // Manual enter view
    @IBOutlet var barcodeImage: UIImageView?
    @IBOutlet var barcodeImageTopConstraint: NSLayoutConstraint?
    @IBOutlet open var submitButton: SignButton?
    @IBOutlet var submitButtonTopConstraint: NSLayoutConstraint?
    
    @IBOutlet open var topTextFieldLine: SolidLine?
    @IBOutlet open var codeTextField: FloatLabelTextField? {
        didSet {
            codeTextField?.delegate = self
            codeTextField?.titleActiveTextColour = AppTheme.sharedInstance.mainColor
            codeTextField?.font = AppTheme.sharedInstance.loginTextFieldFont
            codeTextField?.placeholder = AppLocalization.sharedInstance.scanManualEnterPlaceholder
            codeTextField?.keyboardType = UIKeyboardType.namePhonePad
            codeTextField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    @IBOutlet var bottomTextFieldLine: SolidLine?
    
    open var scanInProgress: Bool = false
    open var cameraBtn: UIBarButtonItem?
    var enterCodeButton: UIBarButtonItem?
    open var titleLabel: UILabel?

    var product: PoqProduct?
    var stringResult: String = ""
    open var viewModel: ScannerViewModel?
    var barcodeInputMethod = BarcodeInputType.scan
    
    var readerViewController: RSCodeReaderViewController?
    
    // For unit testing
    var uiAlertController: UIAlertController?
    var action = UIAlertAction.self
    var actionString: String?
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        viewModel = ScannerViewModel(viewControllerDelegate: self)
        
        customizeControls()
        setUpReaderViewController()
        setUpScanner()
        setUpPermissionHelper()
        setUpiPadSpecificConfigurations()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideScanController(readerViewController)
        readerViewController = nil
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    func setUpReaderViewController() {
        
        if readerViewController == nil {
            readerViewController = RSCodeReaderViewController()
        }
        
        readerViewController?.focusMarkLayer.strokeColor = AppTheme.sharedInstance.scanFocusMarkColor.cgColor
        
        readerViewController?.cornersLayer.strokeColor = AppTheme.sharedInstance.scanBarcodeLineColor.cgColor
        
        readerViewController?.barcodesHandler = { (barcodes: ([AVMetadataMachineReadableCodeObject])) in
            for barcode in barcodes {
                if let stringValue = barcode.stringValue {
                    self.checkBarcode(barcode.type.rawValue, barcodeValue: stringValue)
                }
            }
        }
    }
    
    func setUpScanner() {
        
        if AppSettings.sharedInstance.scanPlatformDesign {
            
            // Setup navigation bar item for platform
            setUpTransparentNavigationBar()
            setUpEnterButtonOnNavigationBar()
            
            // Disable manual enter button underneath
            manualEnterButton?.isHidden = true
            showManualEnterControls(false)
            displayScanController(readerViewController)
            
        } else {
            
            setUpCameraButtonOnNavigationBar()
            
            // Enable the manual enter button underneath.
            setUpButtons()
            showManualView(false)
        }
    }
    
    func displayScanController(_ content: UIViewController?) {
        
        guard let contentController = content, let scanFrameView = scanFrame else {
            return
        }

        self.addChildViewController(contentController)
        contentController.view.frame = self.view.frame
        self.view.insertSubview(contentController.view, belowSubview: scanFrameView)
        contentController.didMove(toParentViewController: self)
        scanFrame?.isUserInteractionEnabled = false
    }
    
    func hideScanController(_ content: UIViewController?) {
        
        guard let contentController = content else {
            return
        }
        
        contentController.willMove(toParentViewController: nil)
        contentController.view.removeFromSuperview()
        contentController.removeFromParentViewController()
    }

    func checkBarcode(_ barcodeType: String, barcodeValue: String) {
        
        if scanInProgress {
            return
        }

        switch barcodeType {
            
        case PoqBarcodeType.QR.rawValue:
            checkQRCodes(barcodeValue)
            
        default:
            captureResult(barcodeValue)
        }
    }
    
    // MARK: - CameraMethods
    
    func captureResult(_ result: String) {

        // If results were returned send query to viewModel
        if !result.isNullOrEmpty() {
            // Disable the camera
            scanInProgress = true
            
            // Vibrate
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            searchBarcodeAndLogEvent(result.escapeStr(), actionName: "Barcode")
            // Display information about the result onscreen
            stringResult = result
        }
    }

    // MARK: - CustomizeControls
    
    open func customizeControls() {
        
        // Set up view compnents fonts and styles
        titleLabel = UILabel()
        
        titleLabel?.text = AppLocalization.sharedInstance.scanNavigationTitle
        titleLabel?.font = AppTheme.sharedInstance.scanNavigationTitleFont
        titleLabel?.textColor = AppTheme.sharedInstance.scanLabelColor
        titleLabel?.textAlignment = NSTextAlignment.center
        titleLabel?.sizeToFit()
        
        self.navigationItem.titleView = titleLabel

        // Set up back button
        self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self, isWhite: true)

        // Status bar light
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Label text/color
        topLabel?.text = AppLocalization.sharedInstance.alignBarcodeText
        topLabel?.font = AppTheme.sharedInstance.scanTopLabelFont
        topLabel?.textColor = AppTheme.sharedInstance.scanLabelColor
        
        bottomLabel?.text = AppLocalization.sharedInstance.barcodePositionText
        bottomLabel?.font = AppTheme.sharedInstance.scanBottomLabelFont
        bottomLabel?.textColor = AppTheme.sharedInstance.scanLabelColor
        
        // Fix layout for smaller devices
        if DeviceType.IS_IPHONE_5 {
            barcodeImageTopConstraint?.constant -= 20
            submitButtonTopConstraint?.constant -= 20
        }
    }
    
    func setUpEnterButtonOnNavigationBar() {
        
        enterCodeButton = UIBarButtonItem(title: AppLocalization.sharedInstance.scanEnterCodeText, style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScannerViewController.popUpEnterCode))
        let naviBarItemFontDict = [NSAttributedStringKey.font: AppTheme.sharedInstance.naviBarItemFont,
                                   NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.scanLabelColor]
        enterCodeButton?.setTitleTextAttributes(naviBarItemFontDict, for: UIControlState())
        self.navigationItem.rightBarButtonItem = enterCodeButton
    }
    
    open func setUpCameraButtonOnNavigationBar() {
        
        // Setup navigation bar item for HOF
        cameraBtn=UIBarButtonItem(title: "CAMERA".localizedPoqString, style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScannerViewController.goToScanner))
        let naviBarItemFontDict = [NSAttributedStringKey.font: AppTheme.sharedInstance.naviBarItemFont,
                                   NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.naviBarItemColor]
        cameraBtn?.setTitleTextAttributes(naviBarItemFontDict, for: UIControlState())
        self.navigationItem.rightBarButtonItem = cameraBtn
    }
    
    open func setUpButtons() {
        manualEnterButton?.setTitle(AppLocalization.sharedInstance.scanManualEnterText, for: .normal)
        submitButton?.setTitle(AppLocalization.sharedInstance.submitButtonText, for: .normal)
        submitButton?.isEnabled = false
        let highlightedImage = ImageInjectionResolver.loadImage(named: "BarcodeIcon")
        barcodeImage?.image = highlightedImage
    }
    
    open func setUpTransparentNavigationBar() {
        
        // Set background color to clear to show camera background
        navigationController?.navigationBar.setBackgroundImage(toColor: .clear)
        navigationController?.navigationBar.setShadowImage(toColor: .clear)
        titleLabel?.textColor = AppTheme.sharedInstance.scanLabelColor
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self, isWhite: true)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    open func setUpSolidNavigationBar() {
        
        // Set solid background color and change statusbar
        navigationController?.navigationBar.resetImages()
        titleLabel?.textColor = UIColor.black
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self, isWhite: false)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
   
    // MARK: - NetworkTasks
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if self.viewModel?.product != nil {
            
            let selectedProduct = self.viewModel?.product
            
            guard let validSelectedProduct = selectedProduct, let validSelectedProductId = validSelectedProduct.id, let validSelectedProductExternalId = validSelectedProduct.externalID else {
                return
            }
            
            NavigationHelper.sharedInstance.loadProduct(validSelectedProductId, externalId: validSelectedProductExternalId, sourceTracking: PoqTrackingSource.scan(String(describing: validSelectedProduct.externalID)), source: ViewProductSource.barcodeScanner.rawValue, productTitle: selectedProduct?.title)

            self.dismiss(animated: true, completion: nil)
            
            // Log successful scan event
            if let validSelectedProductId = selectedProduct?.id {
                PoqTrackerHelper.trackScan(PoqTrackerActionType.ProductID, label: String(describing: validSelectedProductId))
            } else {
                PoqTrackerHelper.trackScan(PoqTrackerActionType.ProductID, label: "")
            }
            PoqTrackerV2.shared.barcodeScan(type: barcodeInputMethod.rawValue, result: ActionResultType.successful.rawValue, ean: stringResult, productId: validSelectedProductId, productTitle: validSelectedProduct.title ?? "")
            
        } else {
            
            popUpNotFoundDialog()
            
            // Log unsuccessful scan event with local variable stringResult
            PoqTrackerHelper.trackScan(PoqTrackerActionType.FailedCode, label: stringResult)
            PoqTrackerV2.shared.barcodeScan(type: barcodeInputMethod.rawValue, result: ActionResultType.unsuccessful.rawValue, ean: stringResult, productId: 0, productTitle: "")
        }
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        super.networkTaskDidFail(networkTaskType, error: error, actionHandler: { [weak self] in
            self?.scanInProgress = false
        })
    }
    
    // MARK: - ENTER DIFFERENT VIEW
    
    @objc open func goToScanner() {
        
        showManualView(false)
        resetTextField()
    }
    
    // Enter code manually
    @IBAction public func blackButtonClicked(_ sender: Any?) {
        showManualView(true)
    }
    
    // Show / hide manual view
    open func showManualView(_ isManualEnter: Bool) {
        
        if isManualEnter {
            setUpSolidNavigationBar()
            hideScanController(readerViewController)
            barcodeInputMethod = .manual
        } else {
            setUpTransparentNavigationBar()
            displayScanController(readerViewController)
            barcodeInputMethod = .scan
        }
        
        // Scan cameraView?
        scanFrame?.isHidden = isManualEnter
        
        topLabel?.isHidden = isManualEnter
        bottomLabel?.isHidden = isManualEnter
        
        manualEnterButton?.isHidden = isManualEnter
        
        cameraBtn?.title = isManualEnter ? "CAMERA".localizedPoqString : ""
        
        // Manual enter view
        showManualEnterControls(isManualEnter)
    }
    
    open func showManualEnterControls(_ isDisplayed: Bool) {
        
        barcodeImage?.isHidden = !isDisplayed
        codeTextField?.isHidden = !isDisplayed
        submitButton?.isHidden = !isDisplayed
        topTextFieldLine?.isHidden = !isDisplayed
        bottomTextFieldLine?.isHidden = !isDisplayed
    }

    // MARK: - PLATFORM ENTER CODE POPUP
    
    @objc func popUpEnterCode() {
        
        let titleText = AppLocalization.sharedInstance.scanManualEnterPlaceholder
        let continueText = "Continue".localizedPoqString
        let cancelText = "CANCEL".localizedPoqString
        
        uiAlertController = UIAlertController(title: titleText, message: nil, preferredStyle: .alert)
        
        let cancelAction = action.init(title: cancelText, style: .cancel) { _ in
            self.actionString = cancelText
        }
        
        let continueAction = action.init(title: continueText, style: .default) { _ in
            if let alertTextFields = self.uiAlertController?.textFields {
                self.searchBarcodeAndLogEvent(alertTextFields[0].obligatoryText(), actionName: "Manual Code")
                self.actionString = continueText
            }
        }
        continueAction.isEnabled = false
        
        // Init textField
        uiAlertController?.addTextField { (textField: UITextField) in
            textField.placeholder = AppLocalization.sharedInstance.scanCodeText
            textField.keyboardType = UIKeyboardType.namePhonePad
            textField.text = self.stringResult.isNullOrEmpty() ? "" : self.stringResult
            
            _ = NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { _ in
                continueAction.isEnabled = textField.text != ""
            }
        }
        
        // Add both action to the controller
        uiAlertController?.addAction(continueAction)
        uiAlertController?.addAction(cancelAction)
        
        // Presenting the alert
        if let alert = uiAlertController {
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - NOT FOUND
    func popUpNotFoundDialog() {
        let okText = "OK".localizedPoqString
        
        uiAlertController = UIAlertController(title: AppLocalization.sharedInstance.scanNoItemsText,
                                              message: AppLocalization.sharedInstance.scanTryAgainText, preferredStyle: .alert)
        
        let okAction = action.init(title: okText, style: .default) { _ in
            // Reset flag for scan in progress since user just tapped "Ok" and we can start scanning again
            self.scanInProgress = false
            self.actionString = okText
        }
        
        uiAlertController?.addAction(okAction)
        
        // Presenting the alert
        if let alert = uiAlertController {
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - UITextFieldDelegate functions
    
    func resetTextField() {
        
        if codeTextField?.isFirstResponder == true {
            codeTextField?.resignFirstResponder()
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let codeTextField = codeTextField {
            
            searchBarcodeAndLogEvent(codeTextField.obligatoryText(), actionName: "Manual Code")
        }
        
        return true
    }
    
    func searchBarcodeAndLogEvent(_ result: String, actionName: String) {
        
        stringResult = result
        
        // Log successful capture barcode event
        PoqTrackerHelper.trackScan(actionName, label: stringResult)
        
        if viewModel?.scanTask == nil {
            viewModel?.searchByScan(stringResult)
        }
    }
    
    // MARK: - Permission helper
    
    func setUpPermissionHelper() {
        PermissionHelper.checkCameraAccess { (success: Bool) in
            
            if !success {
                let didDismiss = {
                    self.dismiss(animated: true, completion: nil)
                }
                
                self.showPrivacyHelper(for: .camera, controller: { _ in }, didPresent: { }, didDismiss: didDismiss, useDefaultSettingPane: false)
            }
        }
    }
    
    // MARK: - iPad settings
    
    func setUpiPadSpecificConfigurations() {
        
        if DeviceType.IS_IPAD {
            
            manualEnterButtonLeadingSpace?.constant = CGFloat(AppSettings.sharedInstance.iPadScanEnterButtonLeadingSpace)
            manualEnterButtonTrailingSpace?.constant = CGFloat(AppSettings.sharedInstance.iPadScanEnterButtonTrailingSpace)
            manualEnterButton?.fontSize = CGFloat(AppTheme.sharedInstance.iPadScanManualEnterButtonFontSize)
            manuallyEnterSubmitButtonLeadingSpace?.constant = CGFloat(AppSettings.sharedInstance.iPadScanEnterSubmitButtonLeadingSpace)
            manuallyEnterSubmitButtonTrailingSpace?.constant = CGFloat(AppSettings.sharedInstance.iPadScanEnterSubmitButtonTrailingSpace)
            submitButton?.fontSize = CGFloat(AppTheme.sharedInstance.iPadScanManuallyEnterSubmitButtonFontSize)
        }
    }
    
    // MARK: - handle different URL

    open func checkQRCodes(_ qrCode: String) {
        scanInProgress = true
        
        let titleText = AppLocalization.sharedInstance.scanQRCodeDetectedTitle
        let openLinkText = "OPEN_LINK".localizedPoqString
        let cancelText = "CANCEL".localizedPoqString
        
        uiAlertController = UIAlertController(title: titleText, message: qrCode, preferredStyle: .alert)
        
        let cancelAction = action.init(title: cancelText, style: .cancel) { _ in
            self.scanInProgress = false
            self.actionString = cancelText
        }
        
        // Open external link
        let openLinkAction = UIAlertAction(title: openLinkText, style: .default) { _ in
            
            // Log successful capture barcode event
            PoqTrackerHelper.trackScan(PoqTrackerActionType.OpenQRCode, label: openLinkText)
            PoqTrackerV2.shared.barcodeScan(type: self.barcodeInputMethod.rawValue, result: ActionResultType.successful.rawValue, ean: qrCode, productId: 0, productTitle: "")
            
            self.scanInProgress = false
            
            self.dismiss(animated: true, completion: nil)
            
            NavigationHelper.sharedInstance.loadExternalLink(qrCode)
            
            self.actionString = openLinkText
        }

        // Add both action to the controller
        uiAlertController?.addAction(openLinkAction)
        uiAlertController?.addAction(cancelAction)
        
        // Presenting the alert
        if let alert = uiAlertController {
            present(alert, animated: true)
        }
    }
    
    @objc func textFieldDidChange() {
        submitButton?.isEnabled = codeTextField?.text?.isEmpty == false
    }
}

extension ScannerViewController: SignButtonDelegate {
    
    @IBAction public func signButtonClicked(_ sender: Any?) {
        
        resetTextField()
        
        if scanInProgress {
            return
        }
        
        scanInProgress = true
        
        if let codeTextField = codeTextField {
            searchBarcodeAndLogEvent(codeTextField.obligatoryText(), actionName: "Manual Code")
        }
    }
}
