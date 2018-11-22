//
//  LogoutButtonView.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 17/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import UIKit

public enum PoqActionButtonType {
    
    // More native actions to be added
    // Otherwise use PoqLinkBlock for deeplinked actions
    case logout
}

public protocol PoqActionButtonBlock: AnyObject {
    
    func triggerAction(_ actionType: PoqActionButtonType?)
    
    func logout()
}

extension PoqActionButtonBlock {
    
    public func triggerAction(_ actionType: PoqActionButtonType?) {
        
        guard let action = actionType else {
            
            return
        }
        
        switch action {
            
        case .logout:
            logout()
        }
    }
}
