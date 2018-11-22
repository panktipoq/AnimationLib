//
//  PopupMessageHelper.swift
//  Poq.iOS
//
//  Created by Jun Seki on 07/02/2016.
//
//

import Foundation
import SVProgressHUD

open class PopupMessageHelper: NSObject {

    public static func showMessage(_ imageName: String, message: String, displayInterval: UInt32 = 2) {
        
        // Styling

        SVProgressHUD.setFont(AppTheme.sharedInstance.popUpTextFont)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(AppTheme.sharedInstance.popUpBackgroundColor)
        SVProgressHUD.setForegroundColor(AppTheme.sharedInstance.popUpForegroundColor)
        SVProgressHUD.setCornerRadius(AppSettings.sharedInstance.svprogressHudCornerRadius)
        SVProgressHUD.setImageViewSize(CGSize(width: AppSettings.sharedInstance.svprogressIconSize, height: AppSettings.sharedInstance.svprogressIconSize))
        SVProgressHUD.show(ImageInjectionResolver.loadImage(named: imageName), status: message)
        
        // Dismiss after 1 sec
        let delayTime = DispatchTime.now() + Double(Int64(Int64(displayInterval) * Int64(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
             SVProgressHUD.dismiss()
        }
    }
}
