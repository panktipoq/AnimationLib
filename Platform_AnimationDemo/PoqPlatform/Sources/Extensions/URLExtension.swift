//
//  URLExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/31/16.
//
//

import Foundation

extension URL {

    func queryValue(forKey key: String) -> String? {
        guard let urlComponents = URLComponents(string: absoluteString) else {
            return nil
        }
        
        guard let queryItems = urlComponents.queryItems else {
            return nil
        }

        for item: URLQueryItem in queryItems {
            if item.name == key {
                return item.value  
            }
        }
        
        return nil
    }
}
