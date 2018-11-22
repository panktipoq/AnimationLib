//
//  PoqBagService.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 11/01/2017.
//
//

import Foundation
import PoqNetworking
import PoqUtilities

public protocol PoqBagService: PoqNetworkTaskDelegate {
    
    // ______________________________________________________
    
    // MARK: Properties
    
    // Stored data in view model
    var presenter: PoqBagPresenter? { get set }
    var bag: PoqBag? { get set }
    var content: [PoqBagContentItem] { get set }
    
    // ______________________________________________________
    
    // MARK: Methods
    
    // Network operation responses
    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?)
    func parseBag(_ result: [PoqBag]?)
    func updateContentItem(_ atRow: Int, withContent contentItem: PoqBagContentItem)
    
    func deleteContentItem(_ atRow: Int)
    func getBagTotal() -> Double?
    
    func getItemCount() -> Int?
    
    // Error messages
    func showBagNotFound()
    
    // Network operations requests
    func getBag()
    func updateBag()
    
    func generateContent()
    
    // Checkout
    func bagCheckout()
}


extension PoqBagService {
    
    func deleteContentItem(_ atRow: Int) {
        
    }
    func getBagTotal() -> Double? {
        return 0.0
    }
    
    func getItemCount() -> Int? {
        return 0
    }
    
    func updateContentItem(_ atRow: Int, withContent contentItem: PoqBagContentItem) {
        
    }
    
    public func getBag() {

       PoqNetworkService(networkTaskDelegate: self).getBag()
        
    }
    
    public func updateBag() {
        
    }
    
    public func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.getModularBag:
            parseBag(result as? [PoqBag])

        default:
            Log.error("Network task is not implemented:\(networkTaskType)")
        }
    }
    
    
    public func parseBag(_ result: [PoqBag]?) {
        
        guard let bags = result, bags.count == 1 else {
            Log.warning("No bag or more than one bags present for user")
            showBagNotFound()
            return
        }
        
        self.bag = bags[0]
        
        generateContent()
        
        presenter?.update(state: .completed, networkTaskType: PoqNetworkTaskType.getModularBag, withNetworkError: nil)
    }
    
    
    public func generateContent() {

        //Empyt content for now. To be overriden by client.
        
    }
    
    public func showBagNotFound() {
        
        let error = NSError(domain: "Not Found", code: HTTPResponseCode.NOT_FOUND, userInfo: [NSLocalizedDescriptionKey : "BAG_NOT_FOUND".localizedPoqString])
        presenter?.update(state: .error, networkTaskType: PoqNetworkTaskType.getModularBag, withNetworkError: error)

    }
    
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        presenter?.update(state: .loading, networkTaskType: PoqNetworkTaskType.getModularBag, withNetworkError: nil)
    }

    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        presenter?.update(state: .error, networkTaskType: PoqNetworkTaskType.getModularBag, withNetworkError: error)
        
    }
    
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        parseResponse(networkTaskType, result: result)
        
    }
}
