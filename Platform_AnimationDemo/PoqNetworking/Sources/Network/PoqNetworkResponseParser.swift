//
//  PoqNetworkResponseParser.swift
//  Poq.iOS.Belk
//
//  Created by Nikolay Dzhulay on 11/16/16.
//
//

import Foundation
import ObjectMapper
import PoqUtilities
import UIKit

/// Protol describe API of parsing srting to response accepted by delegate: '[AnyObject]'
/// We need this protocol to unify different types of response

public protocol PoqNetworkResponseParser {
    
    /// Convert string to sutable for 'delegate' type
    /// If response is a single object - just create array with one item
    static func parseResponse(from data: Data) -> [Any]
}

/// Most widespread parsing: from string to array of poq model items
public final class JSONResponseParser<ModelClass: Mappable>: PoqNetworkResponseParser {

    public static func parseResponse(from data: Data) -> [Any] {
        
        let jsonRootObjet: Any?
        do {
            jsonRootObjet = try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            jsonRootObjet = nil
            Log.error("Catch exception while parsing response")
        }
        
        let mapper = Mapper<ModelClass>()
        
        var result: [ModelClass]?
        if let rootArray = jsonRootObjet as? [Any] {
            
            if let resArray = mapper.mapArray(JSONObject: rootArray) {
                result = resArray 
            }
            
        } else if let rootObject = jsonRootObjet as? [String: Any] {
            
            if let resObject = mapper.map(JSON: rootObject) {
                result = [resObject]
            }
            
        } else {
            Log.error("We can't identify root json object, or there is none")
        }
        
        guard let existedResult = result else {
            Log.error("can't parse MappableClassarray of  \(String(describing: ModelClass.self)) from data")
            return []
        }
        return existedResult
    }
}

/// In some cases we got [Int] or even just Int, non of them can be parsed with ObjectMapper.Mapper, so special parser
public class CountResponseParser: PoqNetworkResponseParser {

    public static func parseResponse(from data: Data) -> [Any] {

        guard let string = String(data: data, encoding: .utf8) else {
            Log.error("We can't convert input data to String with utf8 encoding")
            return []
        }
        
        guard string.contains("[") && string.contains("]") else {
            
            // this is just most rare case, just in in response, thank you API
            guard let countData = Int(string) else { 
                Log.error("Response string is not int: \(string)")
                return []
            }
            
            return [countData]
        }
        
        // [Int] can't be parsed using mapArray, even while Int is Mappable
        // So we have to do it manually
        
        var integersArray = [Int]()
        do {
            if let stringData = string.data(using: String.Encoding.utf8, allowLossyConversion: true) {
                let object: Any = try JSONSerialization.jsonObject(with: stringData, options: [])
                
                if let array = object as? NSArray {
                    for element in array {
                        if let existedInt = element as? Int {
                            integersArray.append(existedInt)
                        }
                    }
                }
            }
            
        } catch {
            Log.error("Invalid JSON data")
        }

        return integersArray

    }
}

/// We have one more special case: stirng downloading for js and css. So we need return the same string wraped in PoqDownloadedData
public class DownloadDataParser: PoqNetworkResponseParser {

    public static func parseResponse(from data: Data) -> [Any] {
        guard let string = String(data: data, encoding: .utf8) else {
            Log.error("We can't convert input data to String with utf8 encoding")
            return []
        }
        
        let result = PoqDownloadedData(data: string)
        return [result]
    }
}

