//
//  PoqDownloadNetworkRequest.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 25/08/2016.
//
//

import Foundation

public final class PoqDownloadNetworkRequest: PoqNetworkRequest {
    
    let urlString: String
    
    init(urlString: String, networkTaskType: PoqNetworkTaskTypeProvider) {
        self.urlString = urlString
        super.init(networkTaskType: networkTaskType, httpMethod: .GET, urlHost: "")
    }

}
