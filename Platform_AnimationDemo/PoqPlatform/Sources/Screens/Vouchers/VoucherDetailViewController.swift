//
//  VoucherDetailViewController.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 30/12/2016.
//
//

import AVFoundation
import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import RSBarcodes_Swift
import UIKit

open class VoucherDetailViewController: PoqBaseViewController, PoqVoucherDetailPresenter {
    
    @IBOutlet var logoImageView: UIImageView?
    @IBOutlet var voucherDiscountLabel: UILabel?
    @IBOutlet var voucherNameLabel: UILabel?
    @IBOutlet var voucherDescriptionLabel: UILabel?
    @IBOutlet var voucherEndDateLabel: UILabel?
    @IBOutlet var voucherExpiringSoonLabel: UILabel?
    @IBOutlet var voucherCodeTitleLabel: UILabel?
    @IBOutlet var voucherCodeLabel: UILabel?
    @IBOutlet var voucherBarCodeImageView: UIImageView?
    @IBOutlet var exclusionsApplyLabel: UILabel?
    @IBOutlet var exclusionsApplyDisclosureIndicator: UIImageView?
    @IBOutlet var exclusionsApplyTransparentButton: UIButton?
    @IBOutlet var applyToBagButton: UIButton?
    @IBOutlet var scanInStoreLabel: UILabel?
    
    @IBOutlet var voucherCodeLabelHeight: NSLayoutConstraint?
    @IBOutlet var barcodeTopSpace: NSLayoutConstraint?
    @IBOutlet var barcodeBottomSpace: NSLayoutConstraint?
    
    @IBOutlet var scanInStoreTrailinToApplyToBagLeading: NSLayoutConstraint?
    @IBOutlet var scanInStoreApplyButtonEqualWidth: NSLayoutConstraint?
    @IBOutlet var endDateToExpiringSoonSpace: NSLayoutConstraint?
    
    var defaultBrightness: CGFloat?
    var voucherDetailScreenBrightness: CGFloat = 1.0
    
    open lazy var service: PoqVoucherDetailService = {
        let service = VoucherDetailViewModel()
        service.presenter = self
        return service
    }()
    
    open var voucherId: Int?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupNavigationBar()
        
        guard let voucherId = voucherId else {
            Log.error("Attempt to load voucher detail with nil voucher Id")
            return
        }
        
        service.getVoucherDetails(voucherId)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if service.voucher?.isInStore ?? false {
            setMaxBrightness()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        if service.voucher?.isInStore ?? false {
            setBrightnessToDefault()
        }
    }
    
    open func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.getVoucherDetails:
            setup()
            PoqTrackerV2.shared.loyaltyVoucher(action: LoyaltyVoucherAction.details.rawValue, voucherId: voucherId ?? 0)
            
        case PoqNetworkTaskType.postVoucher:
            PopupMessageHelper.showMessage("icn-done", message: AppLocalization.sharedInstance.voucherAppliedToYourBagLabel)
            PoqTrackerV2.shared.loyaltyVoucher(action: LoyaltyVoucherAction.applyToBag.rawValue, voucherId: voucherId ?? 0)
            
        default:
            break
        }
    }
    
    open func setup() {
        
        setupLogo()
        
        setupVoucherDetails()
        
        setupCouponCode()
        
        if let exclusionsApply = service.voucher?.isExclusionsApplicable, exclusionsApply {
            setupExclusions()
        }
        
        let isInStore = service.voucher?.isInStore ?? false
        let isOnline = service.voucher?.isOnline ?? false
        
        if isInStore {
            setupScanInStoreLabel(isOnline)
            setMaxBrightness()
            setupObserversToAdjustBrightness()
        }
        
        if isOnline {
            setupApplyToBagButton(isInStore)
            
            if isInStore == false {
                let barcodeTop = barcodeTopSpace?.constant ?? 0
                let barcodeBottom = barcodeBottomSpace?.constant ?? 0
                let barcodeHeight = voucherBarCodeImageView?.bounds.height ?? 0
                let voucherCodeHeight = voucherCodeLabelHeight?.constant ?? 0
                
                let textHeight = barcodeTop + barcodeHeight + voucherCodeHeight + (barcodeBottom - 20)
                
                barcodeTopSpace?.constant = 0
                barcodeBottomSpace?.constant = 20
                
                voucherCodeLabel?.font = voucherCodeLabel?.font.withSize(26)
                
                voucherCodeLabelHeight?.constant = textHeight
            }
        }
    }
    
    func setupLogo() {
        logoImageView?.image = ResourceProvider.sharedInstance.clientStyle?.voucherDetailHeaderImage
        logoImageView?.contentMode = .scaleAspectFit
    }
    
    func setupVoucherDetails() {
 
        voucherDiscountLabel?.text = service.voucher?.discountValue
        voucherNameLabel?.text = service.voucher?.name
        voucherDescriptionLabel?.text = service.voucher?.description
        
        if let endDate = service.voucher?.endDate {
            setupEndDate(endDate)
        }
        
        if service.voucher?.isExpiringSoon ?? false {
            voucherExpiringSoonLabel?.text = AppLocalization.sharedInstance.voucherExpiringSoonLabel
        } else {
            voucherEndDateLabel?.textAlignment = .center
            endDateToExpiringSoonSpace?.isActive = false
            if let voucherEndDateTrailing = voucherEndDateLabel?.superview?.trailingAnchor {
                voucherEndDateLabel?.trailingAnchor.constraint(equalTo: voucherEndDateTrailing, constant: 0).isActive = true
            }
        }
    }
    
    func setupCouponCode() {
        
        voucherCodeTitleLabel?.text = AppLocalization.sharedInstance.voucherDetailsVoucherCodeLabel
        voucherCodeLabel?.text = service.voucher?.voucherCode
        
        if let voucherCode = service.voucher?.voucherCode, !voucherCode.isEmpty && (service.voucher?.isInStore ?? false) {
            voucherBarCodeImageView?.image = RSUnifiedCodeGenerator.shared.generateCode(voucherCode, machineReadableCodeObjectType: AppSettings.sharedInstance.voucherBarcodeFormat)
        }
    }
    
    func setupEndDate(_ endDate: String) {
        let dateFormatter = DateFormatter()
        let endDateFormat = AppSettings.sharedInstance.voucherEndDateFormat
        let endDateDisplayFormat = AppSettings.sharedInstance.voucherEndDateDisplayFormat
        let endDateLabelFormat = AppSettings.sharedInstance.voucherListEndDateFormatString
        
        if let displayDate = dateFormatter.formatFromUTCToLocal(endDate, fromFormat: endDateFormat, toFormat: endDateDisplayFormat) {
            voucherEndDateLabel?.text = String(format: endDateLabelFormat, displayDate)
        }
    }
    
    func setupExclusions() {
        exclusionsApplyLabel?.isHidden = false
        exclusionsApplyDisclosureIndicator?.isHidden = false
        exclusionsApplyTransparentButton?.isEnabled = true
        exclusionsApplyTransparentButton?.addTarget(self, action: #selector(exclusionsButtonClicked), for: .touchUpInside)
    }
    
    func setupScanInStoreLabel(_ isOnlineAsWell: Bool) {
        
        if isOnlineAsWell {
            
            scanInStoreLabel?.text = AppLocalization.sharedInstance.voucherDetailsScanInStoreShortLabel

        } else {
            
            scanInStoreTrailinToApplyToBagLeading?.isActive = false
            scanInStoreApplyButtonEqualWidth?.isActive = false
            if let labelParent = scanInStoreLabel?.superview {
                scanInStoreLabel?.trailingAnchor.constraint(equalTo: labelParent.trailingAnchor, constant: -15.0).isActive = true
            }
            scanInStoreLabel?.text = AppLocalization.sharedInstance.voucherDetailsScanInStoreLongLabel
            applyToBagButton?.isHidden = true
        }
        
        scanInStoreLabel?.isHidden = false
    }
    
    func setupApplyToBagButton(_ isInStoreAsWell: Bool) {
        
        applyToBagButton?.configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.applyToBagButtonStyle)
        applyToBagButton?.setTitle("Apply To Bag", for: UIControlState())
        applyToBagButton?.addTarget(self, action: #selector(applyToBagButtonClicked), for: .touchUpInside)
        
        if !isInStoreAsWell {
            
            scanInStoreTrailinToApplyToBagLeading?.isActive = false
            scanInStoreApplyButtonEqualWidth?.isActive = false
            if let labelParent = scanInStoreLabel?.superview {
                applyToBagButton?.leadingAnchor.constraint(equalTo: labelParent.leadingAnchor, constant: 15.0).isActive = true
            }
            scanInStoreLabel?.isHidden = true
        }
        
        applyToBagButton?.isHidden = false
    }
    
    @objc open func applyToBagButtonClicked(_ sender: UIButton) {
        sender.isEnabled = false
        
        if let voucher = service.voucher {
            service.postVoucherToBag(voucher)
        }
    }
    
    @objc open func exclusionsButtonClicked(_ sender: UIButton) {
        if let exclusions = service.voucher?.exclusions {
            openExclusionsView(exclusions)
        }
    }
    
    func setupObserversToAdjustBrightness() {
        NotificationCenter.default.addObserver(self, selector: #selector(setBrightnessToDefault), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setMaxBrightness), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc func setBrightnessToDefault() {
        if let defaultBrightness = defaultBrightness {
            UIScreen.main.brightness = defaultBrightness
        }
    }
    
    @objc func setMaxBrightness() {
        // Save the brightness setting, set it to full brightness and restore it defaut when we leave
        defaultBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = voucherDetailScreenBrightness
    }
}
