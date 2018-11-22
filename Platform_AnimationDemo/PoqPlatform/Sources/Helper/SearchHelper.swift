//
//  SearchHelper.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 2/25/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

public class SearchHelper: NSObject {
    
    // add a search query to user defaults
    public static func addSearch(_ keyword: String) {
        let defaults = UserDefaults.standard
        
        // make sure the search query isn't already stored in the defaults
        if var keywords = defaults.object(forKey: "search-keyword") as? [String] {
            if !keywords.contains(keyword) {
                keywords.append(keyword)
                defaults.set(keywords, forKey: "search-keyword")
            }
        } else {
            let keywords = [keyword]
            defaults.set(keywords, forKey: "search-keyword")
        }
        
        defaults.synchronize()
    }
    
    // get previous keywords

    public static func getSearchKeywordHistory() -> [String] {

        let defaults = UserDefaults.standard
        
        if let keywords = defaults.object(forKey: "search-keyword") as? [String] {
            if AppSettings.sharedInstance.isShowingMostRecentSearchesEnabled {
                return mostRecentSearchKeywords(keywords)
            }
            
            return keywords
        }
        
        return []
    }
    
    public static func mostRecentSearchKeywords(_ keywordsArray: [String]) -> [String] {
        return Array(keywordsArray.reversed().prefix(5))
    }
    
    // remove all search history
    public static func clearHistory() {

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "search-result")
        defaults.removeObject(forKey: "search-keyword")
        defaults.synchronize()
    }
}
