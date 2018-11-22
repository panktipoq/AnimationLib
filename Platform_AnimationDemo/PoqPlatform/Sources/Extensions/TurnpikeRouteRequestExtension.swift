//
//  TurnpikeRouteRequestExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 9/29/16.
//
//

import Foundation

extension TurnpikeRouteRequest {
    
    /// Search title in query, and deoce it
    @nonobjc
    public final var title: String? {
        guard let queryParameters = queryParameters,
            let existedTitle: String = queryParameters["title"] else {
            return nil
        }
        
        return existedTitle.descapeStr()
    }
}
