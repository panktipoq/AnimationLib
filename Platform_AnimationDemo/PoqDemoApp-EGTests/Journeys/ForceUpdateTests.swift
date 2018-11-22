//
//  ForceUpdateTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Manuel Marcos Regalado on 04/08/2017.
//

import EarlGrey

class ForceUpdateTests: EGTestCase {
    
    override var resourcesBundleName: String {
        return "JourneyTests"
    }
    
    override func setUp() {
        super.setUp()
    }
    
    func testForceUpdate() {
        // Setup Splash response that has all the force update values
        MockServer.shared["/splash/ios/*/3"] = response(forJson: "Splash.ForceUpdate")
        
        insertInitialViewController()
        
        let forceUpdateLabelText = "Want to see our new app features? Please update the app to continue shopping"
        let forceUpdateButtonText = "UPDATE NOW"
        
        EarlGrey.selectElement(with: grey_text(forceUpdateLabelText)).assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: grey_buttonTitle(forceUpdateButtonText)).perform(grey_tap())
    }
    
    func testForceUpdateDisabled() {
        // Setup Splash response with disabled force update
        MockServer.shared["/splash/ios/*/3"] = response(forJson: "Splash.ForceUpdate.Disabled")
        
        insertInitialViewController()
        
        let forceUpdateLabelText = "Want to see our new app features? Please update the app to continue shopping"
        let forceUpdateButtonText = "UPDATE NOW"
        
        EarlGrey.selectElement(with: grey_text(forceUpdateLabelText)).assert(grey_nil())
        EarlGrey.selectElement(with: grey_buttonTitle(forceUpdateButtonText)).assert(grey_nil())
    }
}
