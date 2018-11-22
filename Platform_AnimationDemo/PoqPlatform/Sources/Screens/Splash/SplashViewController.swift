//
//  SplashViewController.swift
//  Poq.iOS
//
//  Created by Jun Seki on 24/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqModuling
import PoqNetworking
import PoqUtilities
import UIKit

/**
 `SplashViewController` is one of the available entry points
 of the Application as defined by `InitialControllers` enum.
 It is presented as a loading screen with (optional) background
 image during the Application configuration and setup.
 
 **NOTE:**
 An optional `LaunchScreen.xib` can be created to be used as a background view.
 */
class SplashViewController: PoqBaseViewController, PoqSplashPresenter {
    
    // Service can be overriden before viewDidLoad
    lazy var service: PoqSplashService = {
        let service = SplashViewModel()
        service.presenter = self
        return service
    }()

    var retryCount: Int = 0
    
    @IBOutlet weak var logoView: SplashLogo?
    @IBOutlet weak var launchImage: PoqAsyncImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadLaunchImage()
        
        service.getSettings()
        
        view.backgroundColor = service.getSplashBackgroundColorStyle()
        
        let launchScreen  = NibInjectionResolver.loadViewFromNib("LaunchScreen")

        // if the clients have custmoised static launch screen xib, then use that as a transition.
        // need to remove that from the paint code splash logo.
        if let launchView = launchScreen {
            view.insertSubview(launchView, at: 0)

            launchView.translatesAutoresizingMaskIntoConstraints = false
            
            let views: [String: AnyObject] = ["launchView": launchView]
            var horConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[launchView]-0-|",
                                                                                                    options: NSLayoutFormatOptions.alignAllLeft,
                                                                                                    metrics: nil,
                                                                                                    views: views)
            let verConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[launchView]-0-|",
                                                                                                    options: NSLayoutFormatOptions.alignAllLeft,
                                                                                                    metrics: nil,
                                                                                                    views: views)
            horConstraints.append(contentsOf: verConstraints)
            view.addConstraints(horConstraints)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()        
    }
    
    // TODO: Refactor this function into its correct home.
    /// This function is used purely by `loadLuanchImage` to return the cached splash image url.
    private func settingValue(for key: String) -> String {
        let setting = SettingsCoreDataHelper.fetchSetting(nil, key: key, settingTypeId: PoqSettingsType.config.rawValue)
        
        if let value = setting?.value, !value.isEmpty {
            return value
        } else {
            return PListHelper.sharedInstance.getValue(key)
        }
    }
    
    /**
     Check `MightyBot` settings for provided `splashImageUrl` for the current device.
     If such is available, it hides the drawn `splashLogo` by PaintCode
     and displays the image from the URL instead.
     */
    private func loadLaunchImage() {
        // Get from core data before overriding.
        let imageUrlIphone = settingValue(for: AppSettings.sharedInstance.splashImageUrl_iPhone)
        let imageUrlIphone4 = settingValue(for: AppSettings.sharedInstance.splashImageUrl_iPhone4)
        let imageUrlIpad = settingValue(for: AppSettings.sharedInstance.splashImageUrl_iPad)
        var url = DeviceType.IS_IPAD ? imageUrlIpad : imageUrlIphone
        url = DeviceType.IS_IPHONE_4_OR_LESS ? imageUrlIphone4 : url
        
        guard !url.isEmpty else {
            return
        }
        
        guard let imageUrl = URL(string: url) else {
            Log.error("Failed to use SplashImageURL: \(url)")
            return
        }
        
        logoView?.isHidden = true
        launchImage?.getImageFromURL(imageUrl, isAnimated: true, showLoadingIndicator: false)
    }
    
    // MARK: - PoqPresenter protocol
    
    func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        if networkTaskType == PoqNetworkTaskType.splash {
            WishlistController.shared.fetchOnLaunchIfNeeded()
            service.setupApplication()
        }
    }
}
