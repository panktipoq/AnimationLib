//
//  PaymentSourceTransform.swift
//  Poq.iOS
//
//  Created by Gabriel Sabiescu on 12/03/2018.
//

import UIKit
import Foundation
import ObjectMapper
import PoqUtilities

class PaymentSourceTransform: TransformType {

    public typealias Object = PoqPaymentSource
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> PoqPaymentSource? {
        guard let jsonDictionary = value as? [String: Any] else {
            return nil
        }
        let objectType = jsonDictionary["klarna"] != nil ? PoqPaymentMethod.Klarna: PoqPaymentMethod.Card
        
        switch objectType {
        case .Card:
            let mapper = Mapper<PoqStripeCardPaymentSource>()
            let object = mapper.map(JSONObject: jsonDictionary)
            return object
        case .Klarna:
            let mapper = Mapper<PoqStripeKlarnaPaymentSource>()
            let object = mapper.map(JSONObject: jsonDictionary)
            return object
        default:
            Log.debug("The object type was not specified properly. Specified as \(objectType)")
        }
        
        return nil
    }
    
    open func transformToJSON(_ value: PoqPaymentSource?) -> String? {
        return ""
    }
}
