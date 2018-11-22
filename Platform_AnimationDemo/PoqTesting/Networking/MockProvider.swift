//
//  MockProvider.swift
//  PoqTesting
//
//  Created by Joshua White on 28/09/2017.
//

import Swifter
import XCTest

/// Interface for networking that provides a way to fetch response resources from an asociated bundle.
public protocol MockProvider: AnyObject {
    
    /// The name of the resources bundle for these tests; containing resources and responses.
    /// Defaults to the class name.
    var resourcesBundleName: String { get }
    
}

// MARK: Required Convenience Functions
public extension MockProvider {
    
    /// The resources bundle for these tests if it exists.
    var resourcesBundle: Bundle? {
        return bundle(named: resourcesBundleName)
    }
    
    /// Returns a bundle from within this target with the specified name if one exists.
    /// - parameter named: The name of the bundle to retreive.
    /// - returns: The bundle for the specified name or nil.
    func bundle(named: String) -> Bundle? {
        return Bundle(for: type(of: self)).path(forResource: named, ofType: "bundle").flatMap({ Bundle(path: $0) })
    }
    
    /// Creates and returns a response from the specified json file located within this test's resources bundle.
    /// - parameter json: The name of the json file within this test's `resourcesBundleName`.bundle.
    /// - parameter key: If non-nil the json is parsed for the corresponding value which is returned instead.
    /// - returns: The request response combination of either the whole or part of the json based on the key parameter.
    func response(forJson json: String, key: String? = nil, inBundle bundleName: String? = nil) -> ((HttpRequest) -> HttpResponse) {
        let bundleName = bundleName ?? resourcesBundleName
        let bundle = self.bundle(named: bundleName)
        
        return { (request: HttpRequest) in
            guard let bundle = bundle else {
                print("ERROR::JSON:: Bundle file NotFound for name: \(bundleName)")
                return .notFound
            }
            
            guard let path = bundle.path(forResource: json, ofType: "json") else {
                print("ERROR::JSON:: Return file NotFound for path \(request.path)")
                return .notFound
            }
            
            guard let data = FileManager.default.contents(atPath: path) else {
                print("ERROR::JSON:: Return file InternalServerError for path \(request.path)")
                return .internalServerError
            }
            
            guard let key = key else {
                print("ERROR::JSON:: Return file response for path \(request.path)")
                
                // No key so return the whole file.
                return .raw(200, "OK", [:], { (writer: HttpResponseBodyWriter) in
                    try! writer.write(data)
                })
            }
            
            guard let responseDictionary = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
                print("Error parsing file for specific key, key = \(key)")
                print("Return file InternalServerError for path \(request.path), key = \(key)")
                return .internalServerError
            }
            
            guard let component = responseDictionary[key] else {
                print("Return file InternalServerError for path \(request.path), key = \(key)")
                return .internalServerError
            }
            
            guard let componentData = try? JSONSerialization.data(withJSONObject: component, options: []) else {
                print("We can't turn component back to json for key \(key)")
                print("Return file InternalServerError for path \(request.path), key = \(key)")
                return .internalServerError
            }
            
            print("Return file component response for path \(request.path), for key \(key)")
            return .raw(200, "OK", [:], { (writer: HttpResponseBodyWriter) in
                try! writer.write(componentData)
            })
        }
    }
    
    /// Creates and returns a response from the specified resource located within this test's resources bundle.
    /// - parameter resource: The name of the resource file within this test's `resourcesBundleName`.bundle.
    /// - parameter extension: The file type of the resource.
    /// - returns: The request response combination for the specified resource.
    func response(forResource resource: String, ofType type: String, inBundle bundleName: String? = nil) -> ((HttpRequest) -> HttpResponse) {
        let bundleName = bundleName ?? resourcesBundleName
        let bundle = self.bundle(named: bundleName)
        
        return { (request: HttpRequest) in
            guard let bundle = bundle else {
                print("ERROR::Resource:: Bundle file NotFound for name: \(bundleName)")
                return .notFound
            }
            
            guard let path = bundle.path(forResource: resource, ofType: type) else {
                print("ERROR::Resource:: Return file NotFound for path \(request.path)")
                return .notFound
            }
            
            guard let data = FileManager.default.contents(atPath: path) else {
                print("ERROR::Resource:: Return file InternalServerError for path \(request.path)")
                return .internalServerError
            }
            
            return .raw(200, "OK", [:], { (writer: HttpResponseBodyWriter) in
                try! writer.write(data)
            })
        }
    }
    
}

// MARK: Optional Convenience Functions
public extension MockProvider {
    
    /// Creates and returns a data object from the specified json file located within this test's resources bundle.
    /// - parameter json: The name of the json file within this test's `resourcesBundleName`.bundle.
    /// - returns: The response data or nil if there was an issue.
    func responseData(forJson json: String, inBundle bundleName: String? = nil) -> Data? {
        let bundleName = bundleName ?? resourcesBundleName
        
        guard let bundle = self.bundle(named: bundleName) else {
            print("ERROR::JSON:: Bundle file NotFound for name: \(bundleName)")
            return nil
        }
        
        guard let path = bundle.path(forResource: json, ofType: "json") else {
            print("ERROR::JSON:: Return file NotFound for file \(json)")
            return nil
        }
        
        guard let data = FileManager.default.contents(atPath: path) else {
            print("ERROR::JSON:: Return file InternalServerError for file \(json)")
            return nil
        }
        
        return data
    }
    
}
