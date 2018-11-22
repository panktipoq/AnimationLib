//
//  UItextFieldExtension.swift
//  Poq.iOS
//
//  Created by Nikolay on 28/09/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import UIKit

extension UITextField {
    
   @nonobjc
   public func obligatoryText() -> String {
        return text ?? ""
    }
}
