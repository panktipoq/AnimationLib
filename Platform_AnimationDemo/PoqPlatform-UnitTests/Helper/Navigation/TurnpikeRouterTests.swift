//
//  TurnpikeRouterTests.swift
//  PoqPlatform-UnitTests
//
//  Created by GabrielMassana on 18/04/2018.
//

@testable import PoqPlatform
import XCTest

class TurnpikeRouterTests: XCTestCase {
    
    let router = TurnpikeRouter.sharedInstance
    let url = "uk.co.houseoffraser.uat://signup?is_modal=true"
    let urlNoScheme = "signup?is_modal=true"
    let scheme = "uk.co.appcommerce.uat"
    let route = "signup"
    let parameterKey = "is_modal"
    let parameterValue = "true"
    
    func test_TurnpikeRouter_exists() {
        XCTAssertNotNil(router, "The TurnpikeRouter sigleton should not be nil.")
    }
    
    /// Check that the resolved scheme matches the one we used to build the mapped URL.
    func test_TurnpikeRouter_scheme() {
        let urlString = scheme + "://" + route + "?" + parameterKey + "=" + parameterValue
        guard let url = URL(string: urlString) else {
            XCTFail("Expected a valid URL for string \(urlString)")
            return
        }
        let urlResolved = router.resolve(url: url)
        guard let resolvedScheme = urlResolved.scheme else {
            XCTFail("Expected to resolve a scheme for string \(urlString)")
            return
        }
        XCTAssert(resolvedScheme == scheme, "TurnpikeRouter default scheme should be \(scheme) but it is \(String(describing: urlResolved.scheme))")
    }
    
    /// Check that the resolved scheme is nil for URLs mapped without an scheme.
    func test_TurnpikeRouter_scheme_safeScheme() {
        let urlString = scheme + "/" + route + "?" + parameterKey + "=" + parameterValue
        guard let url = URL(string: urlString) else {
            XCTFail("Expected a valid URL for string \(urlString)")
            return
        }
        let urlResolved = router.resolve(url: url)
        XCTAssertNil(urlResolved.scheme, "TurnpikeRouter resolved scheme should be nil")
    }
    
    /// Check that a non valid scheme suffix discards the rest of the route.
    /// For instance, "uk.co.appcommerce.uat::/signup?is_modal=true" turns into "uk.co.appcommerce.uat://"
    func test_TurnpikeRouter_scheme_sanitize() {
        let urlString = scheme + "::/" + route + "?" + parameterKey + "=" + parameterValue
        guard let url = URL(string: urlString) else {
            XCTFail("Expected a valid URL for string \(urlString)")
            return
        }
        let urlResolved = router.resolve(url: url)
        XCTAssert(urlResolved.route.isEmpty, "TurnpikeRouter sanitize, route should be empty")
    }
    
    /// Check that we are resolving the route in a valid URL.
    func test_TurnpikeRouter_route() {
        let urlString = scheme + "://" + route + "?" + parameterKey + "=" + parameterValue
        guard let url = URL(string: urlString) else {
            XCTFail("Expected a valid URL for string \(urlString)")
            return
        }
        let urlResolved = router.resolve(url: url)
        XCTAssert(urlResolved.route == route, "TurnpikeRouter resolved route is wrong")
    }
    
    // swiftlint:disable comments_space
    /// Check that we are properly resolving a parameter for a valid URL.
    /// For instance, URL "uk.co.appcommerce.uat://signup?is_modal=true" should contain a parameter with key "is_modal"
    func test_TurnpikeRouter_queryParameters() {
        let urlString = scheme + "://" + route + "?" + parameterKey + "=" + parameterValue
        guard let url = URL(string: urlString) else {
            XCTFail("Expected a valid URL for string \(urlString)")
            return
        }
        let urlResolved = router.resolve(url: url)
        guard let resolvedParameter = urlResolved.queryParameters[parameterKey] else {
            XCTFail("Expected to resolve a parameter for key \(parameterKey) and url \(urlString)")
            return
        }
        XCTAssert(parameterValue == resolvedParameter, "TurnpikeRouter resolved parameterValue is wrong")
    }
}
