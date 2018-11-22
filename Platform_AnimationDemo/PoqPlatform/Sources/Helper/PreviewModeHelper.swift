//
//  PreviewModeHelper.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 4/11/17.
//
//

import Foundation
import PoqNetworking

class PreviewModeHelper: PoqNetworkRequestConveyorStep {
    
    init(dateString: String?) {
        self.dateString = dateString
    }

    var dateString: String?
    
    // MARK: PoqNetworkRequestConveyorStep
    func run(on request: PoqNetworkRequest) {
        
        request.setHeader("preview", toValue: "TRUE")
        
        if let dateStringUnwrpped = dateString {
            request.setHeader("previewDateValue", toValue: dateStringUnwrpped)
        }
    }
}

