//
//  ResourceProvider.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 31/05/2016.
//  Copyright © 2016 POQ. All rights reserved.
//

import Foundation

/**
     This class defines a singleton instance and properties that define the style of the app.
 
 -  Usage: Provide your custom style objects in your App Delegate
 
         `ResourceProvider.sharedInstance.clientStyle = ClientStyle()`
 */
public final class ResourceProvider {
    
    /**
         Singleton instance that is used across the app to access styles
     */
    public static let sharedInstance: ResourceProvider = ResourceProvider()
    
    /**
         This property defines various methods that draw the Views based on PaintCode. Set this property to your custom `HomePageStyleProvider` instance to override the default platform styles.
     
     **WARNING:** This method is deprecated.
     */
    public var homePageStyle: HomePageStyleProvider?
    
    /**
         This property defines the style of various UI elements in the app. Set this property to your custom `ClientStyleProvider` instance to override the default platform styles.
     */
    public var clientStyle: ClientStyleProvider?
}
