//
//  SearchTypeExtension.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/24/17.
//
//

import Foundation

extension SearchType {

    /// Check appsettings for raw value and return SearchType
    public static var currentSearchType: SearchType {
        guard let searchType = SearchType(rawValue: AppSettings.sharedInstance.searchType) else {
            return .classic
        }
        
        return searchType
    }
}

