//
//  PoqNetworkServiceStripeExtension.swift
//  Poq.iOS.Belk
//
//  Created by Nikolay Dzhulay on 11/16/16.
//
//

import Foundation
import PoqNetworking
import Stripe

extension PoqCard {
    
    public func stpCardParameters() -> STPCardParams {
        let cardParams = STPCardParams()
        
        cardParams.number = cardNumber
        cardParams.cvc = cvv
        cardParams.expMonth = UInt(expirationMonth ?? 0)
        cardParams.expYear = UInt(expirationYear ?? 0)
        
        cardParams.name = String.combineComponents([billingAddress?.firstName, billingAddress?.lastName], separator: " ")
        cardParams.address.line1 = billingAddress?.address1
        cardParams.address.line2 = billingAddress?.address2
        cardParams.address.city = billingAddress?.city
        cardParams.address.state = billingAddress?.county ?? billingAddress?.state
        cardParams.address.postalCode = billingAddress?.postCode
        cardParams.address.country = billingAddress?.country
        
        return cardParams
    }
}

extension PoqKlarnaSource {
    
    public func stpSourceParameters() -> STPSourceParams {
        let sourceParams = STPSourceParams()
        sourceParams.rawTypeString = "klarna"
        sourceParams.amount = NSNumber(floatLiteral: amount) 
        sourceParams.currency = currency
        let owner: [String: Any] = 
            [
                "email": email,
                "address": 
                [
                    "line1": billingAddress.address1,
                    "city": billingAddress.city,
                    "postal_code": billingAddress.postCode,
                    "state": billingAddress.state
                ]
            ]
        
        sourceParams.owner = owner
        return sourceParams
    }
}

// MARK: - Stripe
extension PoqNetworkService {
    
    /// Refocator this method and lead to same structure with just ceate/update as one method
    public final func createCustomer(_ customerBody: PoqStripeCustomerBody) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.stripeAttachCardCreateCustomer, httpMethod: .POST)   
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqStripeCustomer>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)   
        networkRequest.setBody(customerBody)
        networkRequest.setPath(format: PoqNetworkTaskConfig.stripeApiCreateCustomer, PoqNetworkTaskConfig.appId)
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func createTokenWithPoqCard(card: PoqCard, stripeClient: STPAPIClient) {
        createTokenFrom(cardParams: card.stpCardParameters(), stripeClient: stripeClient)
    }
    
    public final func createKlarnaTokenFromSource(source: PoqKlarnaSource, stripeClient: STPAPIClient) {
        createTokenFrom(source: source.stpSourceParameters(), stripeClient: stripeClient)
    }
    
    private func createTokenFrom(source: STPSourceParams, stripeClient: STPAPIClient) {
        networkTaskDelegate.networkTaskWillStart(PoqNetworkTaskType.stripeCreateSource)
        stripeClient.createSource(with: source) { (sourceOrNil: STPSource?, errorOrNil: Error?) in
            guard let source = sourceOrNil else {
                self.networkTaskDelegate.networkTaskDidFail(PoqNetworkTaskType.stripeCreateSource, error: errorOrNil as? NSError)
                return 
            }
            self.networkTaskDelegate.networkTaskDidComplete(PoqNetworkTaskType.stripeCreateSource, result: [source])
        }
    }
    
    private func createTokenFrom(cardParams: STPCardParams, stripeClient: STPAPIClient) {
        networkTaskDelegate.networkTaskWillStart(PoqNetworkTaskType.stripeCardTokenization)
        stripeClient.createToken(withCard: cardParams) { (tokenOrNil: STPToken?, errorOrNil: Error?) in
            guard let token = tokenOrNil else {
                self.networkTaskDelegate.networkTaskDidFail(PoqNetworkTaskType.stripeCardTokenization, error: errorOrNil as? NSError)
                return
            }
            self.networkTaskDelegate.networkTaskDidComplete(PoqNetworkTaskType.stripeCardTokenization, result: [token])
        }
    }
    
    public final func fetchStripeCustomerPaymentSources( forCustomerId customerId: String ) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.stripeGetCards, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqStripeCustomer>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.stripeApiGetCustomer, String(customerId))
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func removePaymentSourceCustomer(_ paymentSourceToken: String, fromCusomer customerId: String ) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.stripeDeleteCardToken, httpMethod: .DELETE)
        let networkTask = PoqNetworkTask<StripeMessageParser>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.stripeApiDeleteUpdateCustomerSource, String(customerId), paymentSourceToken)
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func attachTokenToCustomer(_ tokenId: String, toCustomer customerId: String, tokenBody: PoqStripeTokenBody ) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.stripeAttachCard, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqStripeCardPaymentSource>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        networkRequest.setBody(tokenBody)
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.stripeApiAddCustomerSource, String(customerId))
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func checkPaymentSource( _ tokenId: String, toCustomer customerId: String, zipCode: PoqStripeZipCodeBody ) {
        
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.stripeCheckCardToken, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqStripeCardPaymentSource>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        networkRequest.setBody(zipCode)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.stripeApiDeleteUpdateCustomerSource, String(customerId), tokenId)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
}
