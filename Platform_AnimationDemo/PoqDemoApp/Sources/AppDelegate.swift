//
//  AppDelegate.swift
//  PoqDemoApp
//
//  Created by Mohamed Arradi-Alaoui on 01/06/2017.
//
//

import Foundation
import PoqAnalytics
import PoqModuling
import PoqNetworking
import PoqPlatform
import PoqUrbanAirship
import UIKit

@UIApplicationMain
class AppDelegate: BaseAppDelegate {
    
    override func setupModules() {
        ResourceProvider.sharedInstance.homePageStyle = HomePageStyle()
        ResourceProvider.sharedInstance.clientStyle = PoqDemoAppStyle()
        
        PoqPlatform.shared.addModule(PoqPlatformModule())
        PoqPlatform.shared.addModule(PoqNetworkingModule())
        PoqPlatform.shared.addModule(PoqAnalyticsModule())
        
        if let urbanAirshipModule = PoqUrbanAirshipModule() {
            PoqPlatform.shared.addModule(urbanAirshipModule)
        }
        
        PoqPlatform.shared.addModule(PoqDemoModule())
        
        PoqTrackerV2.shared.addProvider(PoqFirebaseTracking())
    }
    
}
