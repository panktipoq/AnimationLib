//
//  StartCartTransferResponse.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 2/14/17.
//
//

import Foundation
import ObjectMapper

public final class CartTransferResponseHeader: Mappable {
    
    public final var name: String?
    public final var value: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    public final func mapping(map: Map) {
        name <- map["name"]
        value <- map["value"]
    }
}

public class StartCartTransferResponse: Mappable {

    public final var body: String?
    public final var cookies: [PoqAccountCookie]?
    public final var cssOverriding: String?
    public final var errorMessage: String?
    public final var headers: [CartTransferResponseHeader]?
    public final var httpMethod: String?
    public final var jsOverriding: String?
    public final var order: StartCartTransferResponseOrder?
    public final var orderCostTrackingJs: String?
    public final var orderNumberTrackingJs: String?
    public final var statusCode: Int?
    public final var storeName: String?
    public final var url: String?
    
    // MARK: - Mappable
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    public func mapping(map: Map) {
        body <- map["body"]
        cookies <- map["cookies"]
        cssOverriding <- map["cssOverriding"]
        errorMessage <- map["errorMessage"]
        headers <- map["headers"]
        httpMethod <- map["httpMethod"]
        jsOverriding <- map["jsOverriding"]
        order <- map["order"]
        orderCostTrackingJs <- map["orderCostTrackingJs"]
        orderNumberTrackingJs <- map["orderNumberTrackingJs"]
        statusCode <- map["statusCode"]
        storeName <- map["storeName"]
        url <- map["url"]
    }
}
