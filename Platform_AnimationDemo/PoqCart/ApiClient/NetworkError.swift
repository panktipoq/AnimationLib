//
//  NetworkError.swift
//  PoqCart
//
//  Created by Balaji Reddy on 22/06/2018.
//

import Foundation
import PoqModuling

// This enum type enscapsulates a Network Error
public enum NetworkError: Error {
    case invalidResponse
    case urlError(code: Int, description: String)
    case unspecified
}

extension NetworkError: LocalizedError {
    
    public var errorDescription: String? {
        
        switch self {
            
        case .invalidResponse:
            return "Unable to parse response".localizedPoqString
            
        case .urlError(_, let description):
            return description
            
        case .unspecified:
            return "HTTP_ERROR".localizedPoqString
        }
    }
}
