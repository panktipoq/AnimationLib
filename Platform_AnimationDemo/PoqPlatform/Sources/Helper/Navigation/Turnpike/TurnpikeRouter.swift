//
//  TurnpikeRouter.swift
//  Turnpike
//
//  Created by GabrielMassana on 18/04/2018.
//  Copyright (c) 2018 Poq Studio. All rights reserved.
//
import UIKit

/// Completion block to be used when a route is found.
public typealias RouteCompletionBlock = (TurnpikeRouteRequest?) -> Void

struct ResolvedURL {
    let route: String
    let scheme: String?
    let queryParameters: [String: String]
    let routeCompletionBlock: RouteCompletionBlock?
}

open class TurnpikeRouter: NSObject {
    
    // Routes that the user has defined.
    open fileprivate(set) var definedRoutes: [String: RouteCompletionBlock] = [String: RouteCompletionBlock]()
    
    // Default route format to invoke when no other route is matched upon invocation.
    fileprivate(set) static var defaultRouteFormat = "default/route/format"
    
    // MARK: - Singleton
    
    /**
     Singleton.
     
     - Returns: Router instance.
     */
    static let sharedInstance = TurnpikeRouter()
    
    // MARK: - Init
    
    fileprivate override init() {
        super.init()
    }
    
    // MARK: - MapRoutes
    
    /**
     Store a route with a completion callback.
     
     - Parameter format: a route with the proper format. If nil, it defines the default route.
     - Parameter destination: the callback to be used when the route in invoked.
     */
    func mapRoute(withFormat format: String?, toDestination destination: @escaping RouteCompletionBlock) {
        guard let format = format else {
            definedRoutes[TurnpikeRouter.defaultRouteFormat] = destination
            return
        }
        definedRoutes[format] = destination
    }
    
    /**
     Remove the format from the mapped routes.
     
     - Parameter format: a route with the proper format. If format is nil, default value will be unmapped.
     */
    func unmap(withFormat format: String?) {
        guard let format = format else {
            definedRoutes.removeValue(forKey: TurnpikeRouter.defaultRouteFormat)
            return
        }
        definedRoutes.removeValue(forKey: format)
    }
    
    // MARK: - ResolveURL
    
    /**
     Resolve the URL provided to be able to invoke the router to call for a defined route.
     The method breakes the url on small pieces.
     
     - Parameter url: url to be used to search a match.
     */
    @discardableResult func resolve(url: URL) -> ResolvedURL {
        let sanitizedURL = url.sanitize()
        let scheme = url.safeScheme()
        var host = ""
        let path = sanitizedURL.path
        if let urlHost = sanitizedURL.host {
            host = urlHost
        }
        let rawRoute = host + path
        let route = rawRoute.sanitizeMappedPath()
        var queryParameters = [String: String]()
        if let parameters = sanitizedURL.query?.queryStringToMap() {
            queryParameters = parameters
        }
        let routeCompletionBlock = invoke(route: route,
                                          withSchema: scheme,
                                          queryParameters: queryParameters)
        return ResolvedURL(route: route, scheme: scheme, queryParameters: queryParameters, routeCompletionBlock: routeCompletionBlock)
    }
    
    // MARK: - InvokeRoute
    
    /**
     Invoke a URL after being sanitized. If the URL route is stored in as a defined route, the related callback will be executed.
     If no route is found, the default callback will be executed.
     
     - Parameter route: url route to be used to search a match.
     - Parameter schema: url schema.
     - Parameter queryParameters: url query parameters as a dictionary.
     */
    fileprivate func invoke(route: String, withSchema schema: String?, queryParameters: [String: String]) -> RouteCompletionBlock? {
        var request: TurnpikeRouteRequest?
        var callback: RouteCompletionBlock?
        let routeSegments = route.components(separatedBy: "/")
        for definedRoute in definedRoutes.keys {
            let definedRouteSegments = definedRoute.components(separatedBy: "/")
            if routeSegments.count != definedRouteSegments.count {
                // A matching route should have the same number of segments
                continue
            }
            guard let routeParameters = extractParameters(incomingRouteSegments: routeSegments, definedRouteSegments: definedRouteSegments) else {
                // A matching route should have parameters.
                continue
            }
            request = TurnpikeRouteRequest(urlSchema: schema,
                                           queryParameters: queryParameters,
                                           matchedRoute: definedRoute,
                                           routeParameters: routeParameters)
            if let definedCallback = definedRoutes[definedRoute] {
                // Found a callback, search is over.
                callback = definedCallback
                break
            }
        }
        if request == nil && callback == nil {
            // Search failed so set a default callback
            request = TurnpikeRouteRequest(urlSchema: schema,
                                           queryParameters: queryParameters,
                                           matchedRoute: nil,
                                           routeParameters: nil)
            callback = definedRoutes[TurnpikeRouter.defaultRouteFormat]
        }
        if let callback = callback {
            // invoke the callback and return it
            callback(request)
            return callback
        }
        // Case where there isn’t a default callback defined
        return nil
    }
    
    // MARK: - MatchRoute
    
    /**
     Returns the parameters of the incomingRouteSegments.
     
     For instance, given these segments:
     ```
     products/search/dress    - this is the url the user is requesting
     products/search/:keyword - this is the url we mapped with turnpike
     ```
     the algorithm sees that every segment is equal except that starting with :, which will be returned in a dictionary as ["keyword": "dress"].
     If the segments without : prefix are not equal, the route is discarded.
     The search stops on the first matching route.
     The parameters returned are nil if there is no matching route.
     
     It would be more efficient to store routes as objects with a hashvalue based on the path so it can be stored in a set.
     Then the rest of the incoming path would be treated as parameters.
     
     - Parameter incomingRouteSegments: segments provided in the url.
     - Parameter definedRouteSegments: segments stored as in a defined route.
     - Returns: all the route parameters as a Dictionary of Strings.
     */
    fileprivate func extractParameters(incomingRouteSegments: [String], definedRouteSegments: [String]) -> [String: String]? {
        var routeParameters = [String: String]()
        for index in 0 ..< definedRouteSegments.count {
            // This iterates over all routes skipping iteration if the segments don’t match OR if the segment mapped doesn’t start with :
            var definedRouteSegment = definedRouteSegments[index]
            let incomingRouteSegment = incomingRouteSegments[index]
            let colonIndex = definedRouteSegment.index(definedRouteSegment.startIndex, offsetBy: 0)
            if definedRouteSegment[colonIndex] == ":" {                        // If this segment has format :something it is a parameter
                definedRouteSegment.remove(at: definedRouteSegment.startIndex) // Drop the colon
                routeParameters[definedRouteSegment] = incomingRouteSegment    // And save the parameter
                continue
            } else if definedRouteSegment == incomingRouteSegment {
                continue
            } else {
                return nil
            }
        }
        return routeParameters
    }
}
