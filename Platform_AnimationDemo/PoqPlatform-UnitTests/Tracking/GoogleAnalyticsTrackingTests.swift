//
//  GoogleAnalyticsTrackingTests.swift
//  PoqDemoApp-UnitTests
//
//  Created by Mohamed Arradi-Alaoui on 29/11/2017.
//

import XCTest

@testable import PoqPlatform
@testable import PoqModuling
@testable import GoogleAnalytics

private class GoogleTrackingProviderMock: PoqTrackingProtocol {
    
    weak var tracker: GAITracker?
    
    func trackInitOrder(_ trackingOrder: PoqTrackingOrder) {}
    func trackCompleteOrder(_ trackingOrder: PoqTrackingOrder) {}
    func logAnalyticsEvent(_ event: String, action: String, label: String, value: Double, extraParams: [String: String]?) {}
    func trackScreenName(_ screenName: String) {}
    func trackCheckoutAction(_ step: Int, option: String) {}
    func trackProductDetails(for product: PoqTrackingProduct) {}
    func trackGroupedProducts(forParent parentProduct: PoqTrackingProduct,  products: [PoqTrackingProduct]) {}
    func trackAddToBag(for product: PoqTrackingProduct, productSize: PoqTrackingProductSize) {}
    func trackCampaignAttribution(from url: URL) {
        
        let hitParams = GAIDictionaryBuilder()
        
        hitParams.setCampaignParametersFromUrl(url.absoluteString)
        
        if !(hitParams.get(kGAICampaignSource) != nil), let host = url.host {
            
            hitParams.set("referer", forKey: kGAICampaignMedium)
            hitParams.set(host, forKey: kGAICampaignSource)
        }
 
        XCTAssertTrue(hitParams.get(kGAICampaignSource) != nil)
        
        XCTAssertTrue(hitParams.get(kGAICampaignSource) == "newsletter")
        
        tracker?.set(kGAIScreenName, value: PoqTracker.attributionScreenEventId)
        
        if let valuesKeys = hitParams.build() as? [AnyHashable : Any],
            let hashTable = GAIDictionaryBuilder.createScreenView().setAll(valuesKeys).build() as? [AnyHashable: Any] {
            
            // Send event to GA
            tracker?.send(hashTable)
            
            // Remove the end point saved on the user default after using it. (avoid double campaign attribution)
            UserDefaults.standard.set(nil, forKey: PoqTracker.attributionUrlUserDefaultKey)
            UserDefaults.standard.synchronize()
        }
    }
}
    class GoogleAnalyticsTrackingTests: XCTestCase {
        
        func testTrackerAttributionWhenUrlHasBeenProvided() {
            
            let testAttributionURL = "https://examplepetstore.com/promo?utm_source=newsletter&utm_medium=email&utm_campaign=promotion"
            
            let url = URL(string: testAttributionURL)!
            
            UserDefaults.standard.set(url, forKey: PoqTracker.attributionUrlUserDefaultKey)
            UserDefaults.standard.synchronize()

            // Test that the end point is present in user default
            XCTAssertFalse(UserDefaults.standard.url(forKey: PoqTracker.attributionUrlUserDefaultKey) == nil)
            
            let trackingProvider = GoogleTrackingProviderMock()
            trackingProvider.tracker = GAI.sharedInstance().tracker(withTrackingId: "UA-7844954-99")
            trackingProvider.tracker?.allowIDFACollection = true
            
            trackingProvider.trackCampaignAttribution(from: url)
            
            // Test that the end point is well removed
            XCTAssertTrue(UserDefaults.standard.url(forKey: PoqTracker.attributionUrlUserDefaultKey) == nil)
        }
    }
