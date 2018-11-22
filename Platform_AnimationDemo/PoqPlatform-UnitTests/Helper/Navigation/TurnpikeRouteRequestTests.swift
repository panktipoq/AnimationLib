//
//  TurnpikeRouteRequestTests.swift
//  PoqPlatform-UnitTests
//
//  Created by GabrielMassana on 18/04/2018.
//
@testable import PoqPlatform
import XCTest

class TurnpikeRouteRequestTests: XCTestCase {
    
    let urlSchema = "uk.co.houseoffraser.uat"
    let queryParameters = ["is_modal": "false", "external_id": "282600317", "is_animated": "true"]
    let matchedRoute = "products/detail/:product_id"
    let routeParameters = ["product_id": "14992174"]
    var turnpikeRouteRequest: TurnpikeRouteRequest {
        return TurnpikeRouteRequest(
            urlSchema: urlSchema,
            queryParameters: queryParameters,
            matchedRoute: matchedRoute,
            routeParameters: routeParameters)
    }
    
    func test_TurnpikeRouteRequest_exists() {
        XCTAssertNotNil(turnpikeRouteRequest, "TurnpikeRouteRequest should not be nil")
    }
    
    func test_TurnpikeRouteRequest_urlSchema() {
        XCTAssert(turnpikeRouteRequest.urlSchema == urlSchema, "TurnpikeRouteRequest with wrong urlSchema")
    }
    
    func test_TurnpikeRouteRequest_queryParameters() {
        guard let queryParameters = turnpikeRouteRequest.queryParameters else {
            XCTFail("Expected queryParameters for request \(turnpikeRouteRequest)")
            return
        }
        XCTAssert(queryParameters == queryParameters, "TurnpikeRouteRequest with wrong queryParameters")
    }
    
    func test_TurnpikeRouteRequest_queryParameters_count() {
        guard let queryParameters = turnpikeRouteRequest.queryParameters else {
            XCTFail("Expected queryParameters for request \(turnpikeRouteRequest)")
            return
        }
        XCTAssert(queryParameters.count == queryParameters.count, "TurnpikeRouteRequest with wrong queryParameters")
    }
    
    func test_TurnpikeRouteRequest_matchedRoute() {
        XCTAssert(turnpikeRouteRequest.matchedRoute == matchedRoute, "TurnpikeRouteRequest with wrong matchedRoute")
    }
    
    func test_TurnpikeRouteRequest_routeParameters() {
        guard let parameters = turnpikeRouteRequest.routeParameters else {
            XCTFail("Expected parameters for request \(turnpikeRouteRequest)")
            return
        }
        XCTAssert(parameters == routeParameters, "TurnpikeRouteRequest with wrong routeParameters")
    }
    
    func test_TurnpikeRouteRequest_routeParameters_count() {
        guard let parameters = turnpikeRouteRequest.routeParameters else {
            XCTFail("Expected parameters for request \(turnpikeRouteRequest)")
            return
        }
        XCTAssert(parameters.count == routeParameters.count, "TurnpikeRouteRequest with wrong routeParameters")
    }
}
