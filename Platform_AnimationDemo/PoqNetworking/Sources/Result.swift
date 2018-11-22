//
//  Result.swift
//  PoqNetworking
//
//  Created by Balaji Reddy on 04/10/2018.
//

import Foundation

public enum Result<T> {
    case success(T?)
    case failure(Error)
}
