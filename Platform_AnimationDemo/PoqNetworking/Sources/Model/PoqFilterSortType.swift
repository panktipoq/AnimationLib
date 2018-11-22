//
//  PoqFilterSortType.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

/// Used in conjunction with sort type. Wether to make it ascending or descending.
///
/// - DEFAULT: Sort as default provided by backend.
/// - DESC: Sort descending.
/// - ASC: Sort ascending.
public enum PoqFilterSortType : String {
    
    case DEFAULT = ""
    case DESC = "desc"
    case ASC = "asc"
}
