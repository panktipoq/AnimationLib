//
//  ForceUpdateViewController.swift
//  Poq.iOS.Platform
//
//  Created by Manuel Marcos Regalado on 02/08/2017.
//
//

import Foundation
import PoqModuling
import PoqUtilities
import UIKit

/**
 This view controller's sole purpose is to force users to always use
 the latest available version of the App.
 
 When the `SplashViewController` completes loading, if the MightyBot
 setting `forceUpdate` is **true**, this controller will be presented
 on top of the view hierarchy.
 
 - Important:
 In order Force Update functionality to work properly, a MightyBot
 setting `forceUpdateItunesLink` must be configured.
 */
class ForceUpdateViewController: PoqBaseViewController {
    
    @IBOutlet weak var forceUpdateLabel: UILabel? {
        didSet {
            forceUpdateLabel?.text = AppLocalization.sharedInstance.forceUpdateLabelText
            forceUpdateLabel?.textColor = AppTheme.sharedInstance.forceUpdateLabelColor
            forceUpdateLabel?.font = AppTheme.sharedInstance.forceUpdateLabelFont
        }
    }
    
    @IBOutlet weak var forceUpdateImage: PoqAsyncImageView? {
        didSet {
            let url = DeviceType.IS_IPAD  ? AppSettings.sharedInstance.forceUpdateUrl_iPad : AppSettings.sharedInstance.forceUpdateUrl_iPhone
            
            guard let validURL = URL(string: url) else {
                Log.error("URL cannot be created")
                return
            }
            forceUpdateImage?.fetchImage(from: validURL)
        }
    }
    
    @IBOutlet weak var updateButton: UIButton? {
        didSet {
            updateButton?.configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.forceUpdateButtonStyle)
            updateButton?.setTitle(AppLocalization.sharedInstance.forceUpdateButtonText, for: .normal)
        }
    }
    
    @IBAction func checkVersionButtonClicked() {
        guard let url = URL(string: AppSettings.sharedInstance.forceUpdateItunesLink) else {
            Log.error("URL cannot be created")
            return
        }
        // TODO: Use the Navigation helper
        UIApplication.shared.openURL(url)
    }
}
