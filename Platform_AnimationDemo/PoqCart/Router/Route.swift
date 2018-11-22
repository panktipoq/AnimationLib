//
//  Route.swift
//  PoqCart
//
//  Created by Balaji Reddy on 18/06/2018.
//

import Foundation

/**
 
 This struct holds the routing information required to navigate/route to a new screen
 
 */
public struct Route {
    
    /// A string identifying the screen to route to
    public var routeIdentifier: String
    
    /// Any data to be passed to the scree being routed to
    public var data: Any?
}
