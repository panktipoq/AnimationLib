//
//  PoqVoucherV2.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 30/12/2016.
//
//

import Foundation
import ObjectMapper

public class PoqVoucherV2: Mappable {
    public final var id: Int?
    public final  var voucherCode: String?
    public final  var isOnline: Bool?
    public final  var isInStore: Bool?
    public final  var discountValue: String?
    public final  var description: String?
    public final  var isExpiringSoon: Bool?
    public final  var endDate: String?
    public final  var isExclusionsApplicable: Bool?
    public final  var exclusions: String?
    public final  var isFeatured: Bool?
    public final  var sortIndex: Int?
    public final  var name: String?
    public final  var value: Double?

    // MARK: Mappable
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    public func mapping(map: Map) {
        
        id <- map["id"]
        voucherCode <- map["voucherCode"]
        discountValue <- map["discountValue"]
        isOnline <- map["isOnline"]
        isInStore <- map["isInStore"]
        discountValue <- map["discountValue"]
        description <- map["description"]
        isExpiringSoon <- map["isExpiringSoon"]
        endDate <- map["endDate"]
        isExclusionsApplicable <- map["isExclusionsApplicable"]
        exclusions <- map["exclusions"]
        isFeatured <- map["isFeatured"]
        sortIndex <- map["sortIndex"]
        name <- map["name"]
        value <- map["value"]
    }
}
