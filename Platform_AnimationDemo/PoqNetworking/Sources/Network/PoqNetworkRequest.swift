//
//  PoqNetworkRequest.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 06/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper
import PoqUtilities

private let logTag: String = "PoqNetworkRequest: "
let boundary = "Boundary-\(UUID().uuidString)"

// Basic HTTP Request types
public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

public enum BodyDataType {
    case json
    case form
    case multiPartForm
}

public typealias PoqMultipartFormDataPost = (parameters: [String: String]?, multipartData: Data, mimeType: String, fileName: String)

open class PoqNetworkRequest {

    // MARK: - Attributes
    
    // Network task type (HomeBanners, Categories, etc.)
    public let networkTaskType: PoqNetworkTaskTypeProvider

    fileprivate var urlHost = PoqNetworkTaskConfig.poqApi
    private(set) var urlPath = ""
    fileprivate var bodyJson: [String: Any]?
    fileprivate let httpMethod: HTTPMethod
    fileprivate var httpHeaders = [String: String]()
    fileprivate var httpMultiPartFormData: Data?
    fileprivate var urlQueryParams = [String: String]()
    fileprivate var bodyDataType = BodyDataType.json

    public var isRefresh: Bool = false {
        didSet {
            // Add additional query to avoid cached responses
            urlQueryParams["refresh"] = isRefresh ? "1" : nil
        }
    }
    
    // MARK: - Setup

    public convenience init(networkTaskType: PoqNetworkTaskTypeProvider, httpMethod: HTTPMethod, bodyDataType: BodyDataType = .json, urlHost: String? = nil) {
        self.init(networkTaskType: networkTaskType, httpMethod: httpMethod, urlHost: urlHost)
        self.bodyDataType = bodyDataType
    }
    
    public init(networkTaskType: PoqNetworkTaskTypeProvider, httpMethod: HTTPMethod, urlHost: String? = nil) {
        self.httpMethod = httpMethod
        self.networkTaskType = networkTaskType
        self.urlHost = urlHost ?? PoqNetworkTaskConfig.poqApi
    }
    
    /// Sets the network path of the request e.g. /categories/%/% and replaces %s with the passed arguments.
    public final func setPath(format: String, _ arguments: [String]) {
        var path = format
        
        for argument in arguments {
            guard let range = path.range(of: "%") else {
                break
            }
            
            path.replaceSubrange(range, with: argument)
        }
        
        urlPath = path
    }
    
    /// Sets the network path of the request e.g. /categories/%/% and replaces %s with the passed arguments.
    public final func setPath(format: String, _ arguments: String...) {
        setPath(format: format, arguments)
    }
    
    /** Sets the network path of the request e.g. /categories/%/% and replaces the first % with the appId
       and any following %s with the passed arguments. */
    public final func setAppIdPath(format: String, _ arguments: String...) {
        var argumentsWithAppId = [PoqNetworkTaskConfig.appId]
        argumentsWithAppId.append(contentsOf: arguments)
        
        setPath(format: format, argumentsWithAppId)
    }
    
    public final func setQueryParam(_ key: String, toValue value: String?) {
        urlQueryParams[key] = value
    }
    
    public final func setQueryParam(_ key: String, toValues values: [String]?, joinedBy separator: String = ";") {
        urlQueryParams[key] = values?.joined(separator: separator)
    }
    
    public final func setHeader(_ key: String, toValue value: String) {
        httpHeaders[key] = value
    }
    
    /// Sets the body of a POST request
    ///
    /// - Parameter body: A BaseMappable instance of the body to be set for a POST request
    public final func setBody(_ body: BaseMappable) {
        
        var bodyObject = body
        
        let map = Map(mappingType: .toJSON, JSON: [:], context: nil, shouldIncludeNilValues: false)
        bodyObject.mapping(map: map)
        
        bodyJson = map.JSON
    }
    
    /// Sets the body of a POST request
    ///
    /// - Parameter body: An Encodable instance of the body to be set for a POST request
    public final func setBody<T: Encodable>(_ body: T) {
        
        guard let data = try? JSONEncoder().encode(body), let json = try? JSONSerialization.jsonObject(with: data), let bodyJson = json as? [String: Any] else {
            
            assertionFailure("Could encode data into Json.")
            return
        }
        
        self.bodyJson = bodyJson
    }
    
    public final func setMultipartFormData(_ poqMultipartFormDataPost: PoqMultipartFormDataPost) {
        let requestBodyData = NSMutableData()
        
        // 1.----- Start the boundary -----
        requestBodyData.append(utf8Encoded: "--\(boundary)\r\n")
        
        // 2.----- Set the Multipart Data -----
        requestBodyData.append(encodeMultipartFormData(forPoqMultipartFormDataPost: poqMultipartFormDataPost))
        
        // 3.----- Finish the boundary -----
        requestBodyData.append(utf8Encoded: "\r\n--\(boundary)--\r\n")
        
        // 4.- Set it as the httpMultiPartFormData which will be used as Httpbody
        httpMultiPartFormData = requestBodyData as Data
        
        // 5.- Set the content type of the POST request to be multipart
        setHeader("Content-Type", toValue: "multipart/form-data; boundary=" + boundary)
    }
    
    private func encodeMultipartFormData(forPoqMultipartFormDataPost: PoqMultipartFormDataPost) -> Data {
        let multipartFormMutableData = NSMutableData()
        if let parameters = forPoqMultipartFormDataPost.parameters {
            for (key, value) in parameters {
                multipartFormMutableData.append(utf8Encoded: "--\(boundary)\r\n")
                multipartFormMutableData.append(utf8Encoded: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                multipartFormMutableData.append(utf8Encoded: "\(value)\r\n")
            }
        }
        multipartFormMutableData.append(utf8Encoded: "Content-Disposition: form-data; name=\"file\"; filename=\"\(forPoqMultipartFormDataPost.fileName)\"\r\n")
        multipartFormMutableData.append(utf8Encoded: "Content-Type: \(forPoqMultipartFormDataPost.mimeType)\r\n\r\n")
        multipartFormMutableData.append(forPoqMultipartFormDataPost.multipartData)
        return multipartFormMutableData as Data
    }
    
    public final func setAlternativeAuthorizationHeader(_ headerValue: String) {
        setHeader("Authorization", toValue: headerValue)
    }
    
    // MARK: - Finalization
    
    /// Called at the start of createURLRequest; override to set authorization headers using setHeader(key:value:).
    private func addAuthorizationHeader() {
        if let authorizationHeader = httpHeaders["Authorization"] {
            setHeader("Authorization", toValue: authorizationHeader)
            Log.debug(logTag + "Authorization: \(authorizationHeader)")
        } else if let authorizationHeader = LoginHelper.getAuthenticationHeader() {
            setHeader("Authorization", toValue: authorizationHeader)
            Log.debug(logTag + "Authorization: \(authorizationHeader)")
        } else {
            Log.debug(logTag + "No Authentication header")
        }
    }
    
    private func addCurrencyHeaderIfNeeded() {
        if let currencyCode = PoqNetworkTaskConfig.currencyCode {
            setHeader("Currency-Code", toValue: currencyCode)
        }
    }
    
    /// Called by createURLRequest to load the requests body data; override to return custom body data and set any related headers
    /// using setHeader(key:value:). By default this also sets the headers for "Content-Type" and "Accept" to "application/json".
    open func finalizeBodyData() -> Data? {
        switch bodyDataType {
        case .json:
            return encodeToJson()
        case .form:
            return encodeToForm()
        case .multiPartForm:
            return httpMultiPartFormData
        }
    }
    
    fileprivate func encodeToJson() -> Data? {

        guard let bodyJson = bodyJson else {
            return nil
        }
        
        var bodyData: Data?
        
        do {
            bodyData = try JSONSerialization.data(withJSONObject: bodyJson, options: .prettyPrinted)
        } catch let error {
            Log.error("We catch exception while parsing post body. error = \(error)")
            return nil
        }

        if let bodyData = bodyData, Log.level >= .trace {
            if let jsonString = String(data: bodyData, encoding: .utf8) {
                Log.verbose(logTag + "HTTP Post Body: \(jsonString)")
            }
        }
        
        setHeader("Content-Type", toValue: "application/json")
        setHeader("Accept", toValue: "application/json")

        return bodyData
    }
    
    fileprivate func encodeToForm() -> Data? {
        
        guard let bodyJson = bodyJson else {
            return nil
        }
        
        var bodyString: String = ""

        let structuredParams = PoqNetworkRequest.createAllIndentionPathes(forParams: bodyJson)
        for valuePath in structuredParams {
            if !bodyString.isEmpty {
                bodyString += "&"
            }
            
            guard let key = PoqNetworkRequest.createEncodedKey(forPath: valuePath.path) else {
                let components: [String?] = valuePath.path.map({ return $0 as String })
                Log.error("We were unable to encode path - \(String(describing: String.combineComponents(components, separator: ", ")))")
                continue
            }
            
            guard let value: String = PoqNetworkRequest.encodedString(fromString: valuePath.value) else {
                Log.error("We were unable to encode value - \(valuePath.value)")
                continue
            }
            
            bodyString += "\(key)=\(value)"
        }
        
        setHeader("Content-Type", toValue: "application/x-www-form-urlencoded")
        setHeader("Accept", toValue: "application/x-www-form-urlencoded")
        
        return bodyString.data(using: .ascii)
    }
    
    private final func makeUrl(_ skipRefresh: Bool = false) -> String? {
        let hostCharacters = CharacterSet.urlHostAllowed.union(.urlPathAllowed)
        guard let host = urlHost.addingPercentEncoding(withAllowedCharacters: hostCharacters) else {
            Log.error(logTag + "Invalid URL Host could not be encoded: \(urlHost)")
            return nil
        }
            
        guard let path = urlPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            Log.error(logTag + "Invalid URL Path could not be encoded: \(urlPath)")
            return nil
        }
        
        let url = host + path
        
        let queryString = urlQueryParams
            .filter({ !$0.value.isEmpty }) // Filter out empty values.
            .compactMap({ "\($0.key.escapeStr())=\($0.value.escapeStr())" }) // Flatmap to escaped array of each key=value.
            .sorted() // Sorts the key=value's alphabetically.
            .joined(separator: "&") // Joins key=value with & symbol.
        
        guard !queryString.isEmpty else {
            return url
        }
        
        return url + "?\(queryString)"
    }
    
    final func createURLRequest() -> URLRequest? {
        PoqNetworkRequestConveyor.runConveyor(on: self)

        guard let urlString = makeUrl() else {
            Log.error(logTag + "URL string for request could not be created.")
            return nil
        }
        
        Log.info("Network Call: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            Log.error("Invalid URL: \(urlString)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue

        if httpMethod == HTTPMethod.POST || httpMethod == HTTPMethod.PUT || httpMethod == HTTPMethod.PATCH {
            request.httpBody = finalizeBodyData()
        }
        
        addAuthorizationHeader()
        addCurrencyHeaderIfNeeded()
        
        let platform = UIDevice.current.userInterfaceIdiom == .pad ? "ipad" : "iphone"
        request.setValue(platform, forHTTPHeaderField: "platform")

        if !NetworkSettings.shared.userAgent.isEmpty {
            request.setValue(NetworkSettings.shared.userAgent, forHTTPHeaderField: "appUserAgent")
        }

        request.addValue(PoqNetworkTaskConfig.appId, forHTTPHeaderField: "Poq-App-Id")
        request.addValue(User.getUserId(), forHTTPHeaderField: "Poq-User-Id")
        
        if let apiVersion = PoqNetworkTaskConfig.settingsVersion, !apiVersion.isEmpty {

            request.addValue(apiVersion, forHTTPHeaderField: "Version-Code")
        }

        for (key, value) in httpHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        Log.debug(String(describing: request.httpMethod))
        
        if Log.level == LogLevel.trace {
            var headersString = "\n"
            if let headerFields = request.allHTTPHeaderFields {
                for (key, value) in headerFields {
                    headersString += "\(key): \(value)\n"
                }
            }
            Log.verbose("HTTP headers: \(headersString)")
        }
        
        return request
    }
}

extension PoqNetworkRequest {
    
    fileprivate typealias ValuePath = (path: [String], value: String)
    
    /// For Stripe we have to use form data. In this case you have to send like 'root[child1][child2]=value' instead of { root: { child1: { child2: value } } }
    /// So we will run on whole parameteres and create pathes like [root, child1, child2] and return coples (paht: [String], value: String)
    /// - parameter forParams: json-like structure. Root object is hash map
    /// - returns: tuples (path: [String], value: String)
    fileprivate static func createAllIndentionPathes(forParams params: [String: Any]) -> [ValuePath] {
        var res = [ValuePath]()
        for (key, value) in params {
            // Leaf
            if let string = value as? String {
                
                res.append(([key], string)) 
            } else if let map = value as?  [String: Any] {
                
                // Node with childs
                let subRes = PoqNetworkRequest.createAllIndentionPathes(forParams: map)
                for valuePath: ValuePath in subRes {
                    
                    var extensdedPath: [String] = valuePath.path
                    extensdedPath.insert(key, at: 0)
                    res.append((extensdedPath, valuePath.value))
                }
                
            } else {
                Log.error("We trying to use unsupported parameter \(value)")
            }
        }
        
        return res
    }
   
    fileprivate static func createEncodedKey(forPath path: [String]) -> String? {
        let pathString = path.reduce("", { $0 + "[\($1)]" })
        return PoqNetworkRequest.encodedString(fromString: pathString)
    }
    
    fileprivate static func encodedString(fromString string: String) -> String? {
        let reservedCharacters = CharacterSet(charactersIn: "&()<>@,;:\\\"/[]?=+$|^~`{} ")
        let urlQueryPartAllowedCharacterSet = CharacterSet.urlQueryAllowed.subtracting(reservedCharacters)
        guard let encodedString = string.addingPercentEncoding(withAllowedCharacters: urlQueryPartAllowedCharacterSet) else {
            return nil
        }
        return encodedString
    }
}
