//
//  CartTransferVersion.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 2/14/17.
//
//

import Foundation
import PoqUtilities

enum CartTransferVersion: String {
    case v1 = "V1"
    case v2 = "V2"
     
    /// Returns value corresponded to AppSettings.cartTransferVersion. If such value not the case, v1 will be returned
    static var currentVersion: CartTransferVersion {
        guard let version = CartTransferVersion(rawValue: AppSettings.sharedInstance.cartTransferVersion) else {
            Log.error("Can't create CartTransferVersion with raw value in AppSettings.cartTransferVersion( \(AppSettings.sharedInstance.cartTransferVersion) ). v1 will be returned ")
            return .v1
        }
        
        return version
    }
}
