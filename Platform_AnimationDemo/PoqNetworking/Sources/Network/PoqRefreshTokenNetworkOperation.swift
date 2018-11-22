//
//  PoqRefreshTokenNetworkOperation.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 29/08/2016.
//
//

import Foundation
import ObjectMapper
import PoqUtilities

/**
 Refresh token for oath2 authorization
 All manipulation and functional calls must happen on SessionContainer.reposnseUnderlyingQueue
 
 We can have only one operation at the same time
 */

// TODO: #PLA-863 firh now we stop all network task, even if they really not require logged in status.
// We do it because we don't know - does it needs to be logged in for request or not.
class PoqRefreshTokenNetworkOperation: PoqNetworkTask<JSONResponseParser<PoqAccount>> {
    
    // while this variablen not nil - we have already on operation in queue
    static weak var currentlyRunningOperation: PoqRefreshTokenNetworkOperation?
    
    fileprivate override init(request: PoqNetworkRequest, networkTaskDelegate: PoqNetworkTaskDelegate?) {
        super.init(request: request, networkTaskDelegate: networkTaskDelegate)
    }
    
    // We will create and schedule refresh token operation, to make it works we will make request queue serial, until we got response
    class final func createAndQueueRefreshTokenOperation() {

        NetworkRequestsQueue.maxConcurrentOperationCount = 1
        let existedOperations: [Operation] = NetworkRequestsQueue.operations
        
        let postBody = PoqPostRefreshToken()
        postBody.refreshToken = LoginHelper.getReshreshToken()

        let request = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.refreshToken, httpMethod: .POST)
        request.setAppIdPath(format: PoqNetworkTaskConfig.apiRefreshToken)
        request.setBody(postBody)
        
        let operation: PoqRefreshTokenNetworkOperation = PoqRefreshTokenNetworkOperation(request: request, networkTaskDelegate: nil)
        
        currentlyRunningOperation = operation
        
        NetworkRequestsQueue.addOperation(operation)
        
        for op: Operation in existedOperations {
            guard let rerunableOperation = op as? RerunableOperation else {
                continue
            }
            
            rerunableOperation.requeueOperationCopy()
        }

    }
    
    override func execute() {
        
        guard let urlRequest = request.createURLRequest() else {
            NetworkRequestsQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
            logoutUser()
            finish()
            return
        }
        
        task = session.dataTask(with: urlRequest, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) in

            guard let responseData = data, let urlContent = String(data: responseData, encoding: .utf8) else {
                Log.info("PoqRefreshTokenNetworkOperation: response with error: \(String(describing: error?.localizedDescription))")
                NetworkRequestsQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
                self.logoutUser()
                self.finish()
                return
            }

            Log.info("PoqRefreshTokenNetworkOperation: Parse account")

            let account: PoqAccount? = Mapper<PoqAccount>().mapArray(JSONString: urlContent)?.first
            if let validAccess = account?.accessToken, let validRefresh = account?.refreshToken, let username = LoginHelper.getEmail(), !validAccess.isEmpty && !validRefresh.isEmpty && !username.isEmpty {
            
                Log.info("PoqRefreshTokenNetworkOperation: Save new token")
                LoginHelper.saveOAuthTokens(forUsername: username, accessToken: validAccess, refreshToken: validRefresh)
            } else {
                
                Log.info("PoqRefreshTokenNetworkOperation: Logout user due to unknown error")
                self.logoutUser()
            }
            
            NetworkRequestsQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
            self.finish()
        })
        task?.resume()
    }
    
    fileprivate final func logoutUser() {
        LoginHelper.clear() 
    }
    
}
