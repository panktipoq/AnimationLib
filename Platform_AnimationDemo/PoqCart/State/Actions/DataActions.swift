//
//  DataActions.swift
//  PoqCart
//
//  Created by Balaji Reddy on 02/05/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import Foundation
import ReSwift

/**
    A generic enum representing the different Actions that can be dispatched to modify the Data state.
 */
public enum DataAction<DataType>: Action {
    case set(data: DataType)
    case edit(data: DataType)
    case error(Error)
}
