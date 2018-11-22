//
//  PoqNetworkBaseTask.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 07/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper
import PoqUtilities
import Haneke

/// Describe operations  which can be
protocol RerunableOperation: AnyObject {

    /// Cancel current instance and add new copy with initial state on proper queue
    func requeueOperationCopy()
}

/// Describe operations  which can be
protocol PoqNetworkOperation: AnyObject {
    
    var task: URLSessionDataTask? { get }
    
    var request: PoqNetworkRequest { get }
    
    // When operation queued, this method will be called, to avoid big delay between queue and real start
    func notifyDelegateThatTaskStarted() 
}

public let NetworkRequestsQueue = PoqNetworkOperationQueue()

/// We need global session and configuration
/// It allow us use swift OHHTTPStubs for test, and don't recerate configurations
public struct SessionContainer {
    
    public static let reposnseUnderlyingQueue = DispatchQueue(label: "network.task.parsing.queue", attributes: [])

    public static let session: URLSession = {

        var config = URLSessionConfiguration.default
        // Set configuration (timeout, HTTP Headers etc.)
        config.timeoutIntervalForRequest = 100 // Default is 60 secs
        
        // We need point of synchronization of responces, it really simplify creating blocking operation
        let reposnseQueue = OperationQueue()
        reposnseQueue.maxConcurrentOperationCount = 1
        reposnseQueue.underlyingQueue = reposnseUnderlyingQueue
        reposnseQueue.qualityOfService = .userInitiated
        
        // Create session
        let resSession = URLSession(configuration: config, delegate: nil, delegateQueue: reposnseQueue)
        return resSession
    }()
}

// Common HTTP Response status codes
public struct HTTPResponseCode {
    public static let OK = 200
    public static let UNAUTHORIZED = 401
    public static let NOT_FOUND = 404
    public static let SERVER_ERROR = 500
    public static let OUT_OF_STOCK = 406
}

public struct NSErrorDef {
    public static let userInfo: String = "userInfoObject"
    public static let errorTitle: NSObject = "errorTitle" as NSObject
    public static let errorMessage: NSObject = "errorMessage" as NSObject
    public static let errorDomain: String = "poq.error.domain"
}

/// PoqNetworkTask serves to queue request and make dependences between them
/// If we got 401 while using OAuth2 - we will copy operation and add dependency(Refresh token)
open class PoqNetworkTask<ResponseParser: PoqNetworkResponseParser>: PoqOperation, RerunableOperation {
    
    // Request, which responble for cinfiguring NSURLRequest
    let request: PoqNetworkRequest
    
    // Delegate to listen network operation callbacks (networkTaskDidComplete, networkTaskDidFailq, etc)
    fileprivate weak var networkTaskDelegate: PoqNetworkTaskDelegate?

    // NSLog tag for easier debug
    fileprivate var logTag: String = "PoqNetworkTask: "
    
    // To support  tests, we need one objec for all
    var session: URLSession {
        return SessionContainer.session
    } 

    /// UserInfo helps pass adiitionl information with request
    /// For exmaple, if request failed, this object can be found in NSerror.userInfo[NSErrorDef.userInfo]
    var userInfo: AnyObject?
    
    /// We need this for copying operations, to avoid mulptiple delegate calls
    fileprivate var userNotifiedAboutOperationStart: Bool = false
    
    var task: URLSessionDataTask?

    /// Initialize a network task
    /// - parameter networkTaskType: Network task type to differentiate response data
    /// - parameter networkTaskDelegate: ViewController to receive callbacks
    public init(request: PoqNetworkRequest, networkTaskDelegate: PoqNetworkTaskDelegate?) {
        self.networkTaskDelegate = networkTaskDelegate
        self.request = request
    }
    
    /// Process API Call
    /// - parameter url: URL to load data
    override open func execute() {
        
        if isCancelled {
            responseError()
            return
        }

        guard let urlRequest = request.createURLRequest() else {
            responseError()
            return
        }

        task = session.dataTask(with: urlRequest, completionHandler: networkSessionCompletionHandler)
        task?.resume()      
    }
    
    /// This action will nil delegate, so on you own fix all delegates
    open override func cancel() {
        super.cancel()
        networkTaskDelegate = nil
        task?.cancel()
    }
    
    /// Create copy of current task anc cucen current one
    /// Can be called only on SessionContainer.reposnseUnderlyingQueue
    func requeueOperationCopy() {
        let copy = PoqNetworkTask(request: request, networkTaskDelegate: networkTaskDelegate)
        copy.userNotifiedAboutOperationStart = userNotifiedAboutOperationStart
        
        cancel()

        NetworkRequestsQueue.addOperation(copy)
    }
    
    /// In some cases we need parse error message from response
    open func parseErrorFromResponseData(_ responseData: Data?) -> NSError? {
        
        guard let validData = responseData else {
            return nil
        }
        
        do {
            
            let errorDictionary = try JSONSerialization.jsonObject(with: validData, options: JSONSerialization.ReadingOptions.allowFragments)

            guard let errorObject = errorDictionary as? NSDictionary  else {
                return nil
            }
            
            var errorMessage: String? = nil
            
            if let validErrorObject = errorObject["error"] as? NSDictionary, let validError = validErrorObject["message"] as? String {
                errorMessage = validError
            } else {
                errorMessage = (errorObject["Message"] as? String) ?? (errorObject["message"] as? String)   
            }
            
            guard let existedErrorMessage: String = errorMessage else {
                return nil
            }
            
            return NSError.errorWithTitle("", statusCode: 0, message: existedErrorMessage, userInfo: nil)
        } catch {
            Log.error("Exception while parsing error from response")
        }
        return nil
    }
    
    /// Addition actions in case of 401 response. Finish on operation will be called after this call
    open func handleUnathorizedResponse() {
        PoqRefreshTokenNetworkOperation.createAndQueueRefreshTokenOperation()
    }
 
    /// Callback network error
    final func responseError( _ error: NSError? = nil ) {
        DispatchQueue.main.async {
            [networkTaskType = request.networkTaskType] in
            Log.debug("Response with error \(error?.localizedDescription ?? "nil")")
            self.networkTaskDelegate?.networkTaskDidFail(networkTaskType, error: error)
            self.finish()
        }
    }

    /// Callback network timeout
    final func responseSuccessResponse(_ result: [Any]?, statusCode: Int) {
        
        // Call the deleage in main thread
        DispatchQueue.main.async {
            [networkTaskType = request.networkTaskType] in
            
            Log.debug("Returning parsed data \(result?.count ?? 0)")
            self.networkTaskDelegate?.networkTaskDidComplete(networkTaskType, result: result, statusCode: statusCode)

            self.finish()
        }
    }
}

// MARK: - PoqNetworkOperation
extension PoqNetworkTask: PoqNetworkOperation {

    final func notifyDelegateThatTaskStarted() {
        guard !userNotifiedAboutOperationStart else {
            return
        }
        
        userNotifiedAboutOperationStart = true
        
        // Call main thread for will start callback
        DispatchQueue.main.async {
            [networkTaskType = request.networkTaskType] in
            self.networkTaskDelegate?.networkTaskWillStart(networkTaskType)
        }
    }
}

// MARK: - private
extension PoqNetworkTask {

    /// Complete handler for async NSURLSession call
    fileprivate final func networkSessionCompletionHandler(_ data: Data?, response: URLResponse?, error: Error?) {
        
        if isCancelled {
            responseError()
            return
        }
        
        // Network connectivity error
        if let errorUnwrapped = error as NSError? {
            responseError(errorUnwrapped)
            Log.info(logTag + "Network Error Code: \(errorUnwrapped.code)")
            Log.info(logTag + "Network Error Description: \(errorUnwrapped.description)")
            return
        }
        
        guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
            // Looks like we used request in wrong way, we should use it only for http
            Log.error("httpResponse is not kind of NSHTTPURLResponse, how does it possible? httpResponse is kind of \(type(of: response))")
            responseError(error as NSError?)
            return
        }
        
        /// Check for onespecail code - UNAUTHORIZED. If we met if - we will create other operation, which will
        /// To avoid infinite loop of requests - we will check LoginHelper.isLoggedIn(), since if for some reason
        /// Request failed - we will logout user
        if let authenticationType = AuthenticationType(rawValue: NetworkSettings.shared.authenticationType),
            httpResponse.statusCode == HTTPResponseCode.UNAUTHORIZED && authenticationType == .oAuth && LoginHelper.isLoggedIn() {
            
            Log.info(logTag + " We got 401 - relogin")
            handleUnathorizedResponse()
            finish()
            
            return
        }
        
        if httpResponse.statusCode != HTTPResponseCode.OK, let error = parseErrorFromResponseData(data) {

            Log.info(logTag + "response status code is \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            if let url = request.createURLRequest()?.url {
                Log.warning("💔 HTTP \((response as? HTTPURLResponse)?.statusCode.description ?? "") \(url)")
            }
            
            responseError(error)
            return
            
        } else {
            
            // HTTP Status code is not 200 and the payload does not have a PoqMessage
            
            guard 200...399 ~= httpResponse.statusCode else {
                
                let userInfo = httpResponse.statusCode < 499 ? [NSLocalizedDescriptionKey: "HTTP_ERROR".localizedPoqString] : [NSLocalizedDescriptionKey: "SERVER_ERROR".localizedPoqString]
                let error = NSError(domain: NSURLErrorDomain, code: httpResponse.statusCode, userInfo: userInfo)
                
                if let url = request.createURLRequest()?.url {
                    Log.error("💔 HTTP \((response as? HTTPURLResponse)?.statusCode.description ?? "") \(url)")
                }
                
                if let data = data, let jsonString = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                    Log.error("😯 Something went wrong. HTTP Error code with non PoqMessage payload:\n\(jsonString)")
                }
                
                responseError(error)
                return
            }
            
            Log.verbose("status code \(httpResponse.statusCode)")
        }
        
        // Convert response data to NSString for parsing
        guard let responseData = data else {
            responseError()
            return
        }
        
        if Log.level == .trace, let urlContent = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue) {
            Log.verbose("Response as string:\n\(urlContent)")
        }
        
        // Parse JSON Data
        
        let result = ResponseParser.parseResponse(from: responseData)

        self.responseSuccessResponse(result, statusCode: httpResponse.statusCode)
    }
}
