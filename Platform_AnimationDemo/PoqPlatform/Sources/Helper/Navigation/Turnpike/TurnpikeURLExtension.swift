//
//  TurnpikeURL+Sanitizer.swift
//  Turnpike
//
//  Created by GabrielMassana on 18/04/2018.
//  Copyright (c) 2018 Poq Studio. All rights reserved.
//
import Foundation

extension URL {
    
    /// Returns the absolute string
    internal func sanitize() -> URL {
        // Note: This calls absoluteString in case you defined the URL using a relative path.
        guard let sanitized = URL(string: self.absoluteString.sanitize()) else {
            return self
        }
        return sanitized
    }
    
    /// Returns nil if there is no scheme.
    /// Note: This suggests that URL.scheme may return "" if there is no scheme, but it returns nil, so this method seems useless.
    internal func safeScheme() -> String? {
        guard let scheme = self.scheme,
            scheme.count > 0 else {
                return nil
        }
        return scheme
    }
}
