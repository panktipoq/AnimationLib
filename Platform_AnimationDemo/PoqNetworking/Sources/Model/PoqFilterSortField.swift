//
//  PoqFilterSortField.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

/// The type of sorting that needs to be made on a given product list. Ususally found in PLP
///
/// - DEFAULT: The standard sort as provided by backend
/// - TITLE: Sort by title 
/// - PRICE: Sort by price
/// - DATE: Sort by date
/// - RATING: Sort by rating
/// - BRAND: Sort by brand name
/// - SELLER: Sort by seller name
public enum PoqFilterSortField : String {
    
    case DEFAULT = ""
    case TITLE = "title"
    case PRICE = "price"
    case DATE = "date"
    case RATING = "rating"
    case BRAND = "brand"
    case SELLER = "seller"
}
