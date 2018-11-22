//
//  TurnpikeRouteRequest.swift
//  Turnpike
//
//  Created by GabrielMassana on 18/04/2018.
//  Copyright (c) 2018 Poq Studio. All rights reserved.
//
import UIKit

/// A route to be invoked.
open class TurnpikeRouteRequest: NSObject {
    
    // MARK: - Properties
    
    /// The URL schema of the incoming URL. If invoked internally, this will be `nil`.
    public fileprivate(set) var urlSchema: String?
    
    /// The query parameters parsed from the query string.
    public fileprivate(set) var queryParameters: [String: String]?
    
    /// Matched defined route. If no match was found, the default route will be invoked and this will be `nil`.
    public fileprivate(set) var matchedRoute: String?
    
    /// Route parameters found in the matched route. If no route parameters are found this will be an empty Dictionary, and if no matched route was found, this will be `nil`.
    public fileprivate(set) var routeParameters: [String: String]?
    
    // MARK: - Init
    
    /**
     For instance:
     - urlSchema       = com.poq.poqdemoapp
     - queryParameters = search_type=search
     - matchedRoute    = products/search/:keyword
     - routeParameters = [keyword:dress]
     
     - Parameter urlSchema: scheme for this application.
     - Parameter queryParameters:
     - Parameter matchedRoute: Original route mapped.
     - Parameter routeParameters: Parameters in the route requested by the user.
     */
    public init(urlSchema: String? = nil,
                queryParameters: [String: String]? = nil,
                matchedRoute: String? = nil,
                routeParameters: [String: String]? = nil) {
        super.init()
        self.urlSchema = urlSchema
        self.queryParameters = queryParameters
        self.matchedRoute = matchedRoute
        self.routeParameters = routeParameters
    }
}
