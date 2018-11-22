//
//  PoqOfferListService.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 05/01/2017.
//
//

import Foundation
import PoqNetworking
import PoqUtilities

public protocol PoqOfferListService: PoqNetworkTaskDelegate {
    
    //MARK :- Properties
    var presenter: PoqOfferListPresenter? { get set }
    var offers: [PoqOffer]? { get set }
    var content: [PoqOfferListContentItem]? { get set }
    
    //MARK :- Network operation requests
    func getOffers()
    
    //MARK :- Network operation responses
    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?)
    func parseOffers(_ result: [PoqOffer]?)
    
    func generateContent()
    
    func showOfferNotFound()
    
}


extension PoqOfferListService {
    
    public func generateContent() {
        
        guard let offers = self.offers else {
            Log.error("Attempt to generate offer content without fetching offers")
            return
        }
        content = []
        
        for offer in offers {
            content?.append(PoqOfferListContentItem(type: .info, offer: offer))
        }
    }
    
    func getOffers() {
        
        PoqNetworkService(networkTaskDelegate: self).getOffers()
    }
    
    public func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        switch networkTaskType {
        case PoqNetworkTaskType.getOffers:
            parseOffers(result as? [PoqOffer])
        default:
            Log.error("Response handler for network task type not implemented")
            
        }
    }
    
    public func parseOffers(_ result: [PoqOffer]?) {
        
        guard let offers = result, offers.count > 1 else {
            showOfferNotFound()
            self.offers = []
            return
        }
        
        self.offers = offers
        presenter?.update(state: .completed, networkTaskType: PoqNetworkTaskType.getOffers)
        
    }
    
    
    func showOfferNotFound() {
        
        let error = NSError(domain: "Not Found", code: HTTPResponseCode.NOT_FOUND, userInfo: [NSLocalizedDescriptionKey : "OFFERS_NOT_FOUND".localizedPoqString])
        presenter?.update(state: .error, networkTaskType: PoqNetworkTaskType.getOffers, withNetworkError: error)
    }
    
    
    // MARK: - Network Task Callbacks
    
    /**
     Callback before start of the async network task
     */
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        presenter?.update(state: .loading, networkTaskType: networkTaskType)
    }
    
    /**
     Callback after async network task is completed successfully
     */
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        parseResponse(networkTaskType, result: result)
    }
    
    /**
     Callback when task fails due to lack of responded data, connectivity etc.
     */
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
    }
    
}

