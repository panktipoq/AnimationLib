//
//  PoqContentTrackable.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 08/11/2017.
//

import Foundation

public protocol PoqContentTrackable {
    func onboarding(action: String)
    func appOpen(method: String, campaign: String)
    func bannerTap(bannerTitle: String, bannerType: String)
    func lookbookTap(lookbookTitle: String, type: String, productId: Int, screenNumber: Int)
    func storeFinder(action: String, storeName: String)
    func appStories(action: String, storyTitle: String, cardTitle: String)
}

extension PoqContentTrackable where Self: PoqAdvancedTrackable {
    
    public func onboarding(action: String) {
        let onboardingInfo: [String: Any] = [TrackingInfo.action: action]
        logEvent(TrackingEvents.Content.onboarding, params: onboardingInfo)
    }
    
    public func appOpen(method: String, campaign: String) {
        let appInfo: [String: Any] = [TrackingInfo.method: method, TrackingInfo.campaign: campaign]
        logEvent(TrackingEvents.Content.appOpen, params: appInfo)
    }
    
    public func bannerTap(bannerTitle: String, bannerType: String) {
        let bannerInfo: [String: Any] = [TrackingInfo.title: bannerTitle, TrackingInfo.type: bannerType]
        logEvent(TrackingEvents.Content.bannerTap, params: bannerInfo)
    }
    
    public func lookbookTap(lookbookTitle: String, type: String, productId: Int, screenNumber: Int) {
        let lookbookInfo: [String: Any] = [TrackingInfo.title: lookbookTitle, TrackingInfo.type: type, TrackingInfo.productId: productId, TrackingInfo.screenNumber: screenNumber]
        logEvent(TrackingEvents.Content.lookbookTap, params: lookbookInfo)
    }
    
    public func storeFinder(action: String, storeName: String) {
        let storeInfo: [String: Any] = [TrackingInfo.action: action, TrackingInfo.storeName: storeName]
        logEvent(TrackingEvents.Content.storeFinder, params: storeInfo)
    }
    
    public func appStories(action: String, storyTitle: String, cardTitle: String) {
        let storyInfo: [String: Any] = [TrackingInfo.action: action, TrackingInfo.title: storyTitle, TrackingInfo.cardTitle: cardTitle]
        logEvent(TrackingEvents.Content.appStories, params: storyInfo)
    }
}
