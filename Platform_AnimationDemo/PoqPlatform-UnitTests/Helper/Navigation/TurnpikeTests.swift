//
//  TurnpikeTests.swift
//  PoqPlatform-UnitTests
//
//  Created by GabrielMassana on 18/04/2018.
//

@testable import PoqPlatform
import XCTest

class TurnpikeTests: XCTestCase {
    
    let routeSomething = "something"
    let routeSomethingElse = "something/else"
    let somethingRequest = { (_: TurnpikeRouteRequest?) in
        // Closure for route "something"
    }
    
    let somethingElseRequest = { (_: TurnpikeRouteRequest?) in
        // Closure for route "something/else"
    }
    
    let defaultRequest = { (_: TurnpikeRouteRequest?) in
        // Closure for default request
    }
    
    override func setUp() {
        Turnpike.unmap(nil)
        Turnpike.unmap(routeSomething)
        Turnpike.unmap(routeSomethingElse)
    }
    
    func test_Turnpike_mapRoute_count() {
        let countBefore = TurnpikeRouter.sharedInstance.definedRoutes.count
        Turnpike.mapDefault(toDestination: defaultRequest)
        Turnpike.mapRoute(routeSomething, toDestination: somethingRequest)
        Turnpike.mapRoute(routeSomethingElse, toDestination: somethingElseRequest)
        let countAfter = TurnpikeRouter.sharedInstance.definedRoutes.count
        XCTAssert(countAfter - countBefore == 3, "After defining two routes, the number of routes should be three (those added plus the default route).")
    }
    
    func test_Turnpike_resolve() {
        Turnpike.mapRoute(routeSomething, toDestination: somethingRequest)
        Turnpike.mapRoute(routeSomethingElse, toDestination: somethingElseRequest)
        let something = PListHelper.sharedInstance.getURLScheme() + routeSomething
        guard let url = URL(string: something) else {
            XCTFail("Expected a URL \"com.poq.poqdemoapp://something\" for a route \"something\"")
            return
        }
        let completion = Turnpike.resolve(url)
        XCTAssertNotNil(completion, "After adding a route, it should have the default poq scheme for this application.")
    }
    
    func test_Turnpike_resolve_default() {
        Turnpike.mapRoute(routeSomething, toDestination: somethingRequest)
        Turnpike.mapDefault(toDestination: defaultRequest)
        guard let url = URL(string: "nothing:here") else {
            XCTFail("Expected a valid URL.")
            return
        }
        let completion = Turnpike.resolve(url)
        XCTAssertNotNil(completion, "When defining a default route, Turnpike should return the default closure for non existent routes.")
    }
    
    func test_Turnpike_resolve_emptyDefault() {
        Turnpike.mapRoute(routeSomething, toDestination: somethingRequest)
        guard let url = URL(string: "nothing:no/default") else {
            XCTFail("Expected a valid URL.")
            return
        }
        let completion = Turnpike.resolve(url)
        XCTAssertNil(completion, "If there isn’t a default route, Turnpike should reutrn a nil closure.")
    }
}
