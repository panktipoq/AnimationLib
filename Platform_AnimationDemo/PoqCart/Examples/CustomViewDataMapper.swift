//
//  CustomViewDataMapper.swift
//  PoqCart
//
//  Created by Balaji Reddy on 09/07/2018.
//

import Foundation

// MARK: - Dictionary Hashable Extension
extension Dictionary: Hashable where Dictionary.Key == String, Dictionary.Value == String {

    public var hashValue: Int {

        return self.keys.reduce(0, { nextValue, key in

            if let valueHash = self[key]?.hashValue {
              return (key.hashValue ^ valueHash) ^ nextValue
            }

            return key.hashValue ^ nextValue
        })
    }
}

// MARK: - CustomViewDataMapper

/**
    A type that conforms to BagViewDataMappable subclass that maps a Bag with custom payload carrying Order Summary information
 */
public struct CustomViewDataMapper: CartViewDataMappable {
    
    public init() {}
    
    public func mapToViewData(_ model: CartDomainModel) -> CartViewDataRepresentable {
        
        var defaultMappedBag = CartViewDataMapper().mapToViewData(model)

        if let orderSummaryData: [String: Float] = model.customData?.decode() {
            
            let orderSummaryViewData = orderSummaryData.mapValues({ Decimal(Double($0)).currencyString ?? "" })
            
            let keyValueArray = orderSummaryViewData.reduce(into: [], { result, keyValue in result.append((keyValue.key, keyValue.value)) })
            
            let keyValueCard = KeyValueCardTableViewCell.KeyValueCard(id: orderSummaryViewData.hashValue, title: "Order Summary", subtitle: nil, keyValueArray: keyValueArray)
            
            let orderSummaryContentItem = CartContentBlocks.custom(payload: AnyHashable(keyValueCard))
            
            let indexToInsert = defaultMappedBag.contentBlocks.count
            
            defaultMappedBag.contentBlocks.insert(orderSummaryContentItem, at:  indexToInsert)
        }
        
        return defaultMappedBag
    }
}
