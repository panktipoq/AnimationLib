//
//  CustomDataProvidable.swift
//  PoqCart
//
//  Created by Balaji Reddy on 12/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import Foundation
import PoqUtilities

/**
 
 A protocol that ensures that every Data Model that conforms to it has a custom payload property of type AnyCodable - A type that encode and decode data of arbitrary type.
 
 */
protocol CustomDataProvidable {
    
    var customData: AnyCodable? { get set }
}
