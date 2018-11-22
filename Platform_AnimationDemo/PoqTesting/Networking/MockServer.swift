//
//  MockServer.swift
//  PoqTesting
//
//  Created by Joshua White on 27/09/2017.
//

import Swifter
import XCTest
import PoqUtilities

public struct MockServer {
    
    /// The shared test server.
    static var shared = HttpServer.forMocks()
    
    public static func reset() {
        shared.stop()
        Log.info("Server stopped.")
        shared = HttpServer.forMocks()
    }
}

fileprivate extension HttpServer {
    
    /// The mock server which will be used whilst the app is being tested.
    /// Hopefully they will free the socket in a proper way when finished.
    static func forMocks() -> HttpServer {
        let result = HttpServer()
        var port = UInt16(50100)
        
        let environment = ProcessInfo.processInfo.environment
        if let baseUrlString = environment["BASE_URL"], let urlPort = URLComponents(string: baseUrlString)?.port {
            port = UInt16(urlPort)
        }
        
        do {
            try result.start(port)
            Log.info("Server started")
        } catch let error as NSError {
            print("ERROR: Server start error: \(error)")
            XCTAssert(false, "We can't rise HTTP server, error = \(error)")
        } catch {
            print("ERROR: Can't rise server for unknown issue")
            XCTAssert(false, "We can't rise HTTP server")
        }
        
        return result
    }
    
}
