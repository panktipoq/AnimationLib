//
//  Turnpike.swift
//  Turnpike
//
//  Created by GabrielMassana on 18/04/2018.
//  Copyright (c) 2018 Poq Studio. All rights reserved.
//
import UIKit

/// Turnpike main class.
/// Project translated into Swift from https://github.com/URXtech/turnpike-ios
open class Turnpike: NSObject {
    
    // MARK: - MapRoutes
    
    /**
     Store a route with a completion callback.
     
     - Parameter format: a route with the proper format. Allowed formats: (i.e. "users/:id" or "logout"). When calling the deeplink, :id can be anything.
     - Parameter destination: the callback to be used when the route in invoked.
     */
    open class func mapRoute(_ format: String, toDestination destination: @escaping RouteCompletionBlock) {
        TurnpikeRouter.sharedInstance.mapRoute(withFormat: format, toDestination: destination)
    }
    
    /**
     Store a default completion callback.
     
     - Parameter destination: the callback to be used as default.
     */
    open class func mapDefault(toDestination destination: @escaping RouteCompletionBlock) {
        TurnpikeRouter.sharedInstance.mapRoute(withFormat: nil, toDestination: destination)
    }
    
    /**
     Remove the format from the mapped routes.
     
     - Parameter format: a route with the proper format.
     */
    open class func unmap(_ format: String?) {
        TurnpikeRouter.sharedInstance.unmap(withFormat: format)
    }
    
    // MARK: - ResolveURL
    
    // swiftlint:disable comments_space
    /**
     Starts the required actions to open a deeplink url.
     Note: This is called resolve, but it actually executes the closure and then returns it.
     
     For instance, `com.mycompany.MyApp:logout`,
     `com.mycompany.MyApp:users/16?highlight=portfolio`,
     `com.mycompany.MyApp:about/team/contact?city=san%20francisco`
     
     - Parameter url: the url to be invoked.
     - SeeAlso: [RFC 1738](http://www.ietf.org/rfc/rfc1738.txt)
     */
    @discardableResult open class func resolve(_ url: URL) -> RouteCompletionBlock? {
        let resolvedURL = TurnpikeRouter.sharedInstance.resolve(url: url)
        return resolvedURL.routeCompletionBlock
    }
}
