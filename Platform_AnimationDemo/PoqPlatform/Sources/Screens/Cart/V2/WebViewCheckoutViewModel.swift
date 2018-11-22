//
//  WebViewCheckoutViewModel.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 2/14/17.
//
//

import Foundation
import CoreLocation
import PoqNetworking

class WebViewCheckoutViewModel: WebViewCheckoutService {
    public typealias OrderItemType = PoqOrder<PoqOrderItem>
    
    var isCheckoutCompleted: Bool {
        return order.isCheckoutCompleted
    }
    
    var cartTransferResponse: StartCartTransferResponse?
    
    weak var presenter: WebViewCheckoutPresenter?
    
    var locationManager: CLLocationManager?
    
    // MARK: WebViewCheckout
    var order = OrderItemType()
    
    var cartTransferWebView: UIWebView? {
        return presenter?.webView
    }

    var currentLoadingURL: URL?

}
