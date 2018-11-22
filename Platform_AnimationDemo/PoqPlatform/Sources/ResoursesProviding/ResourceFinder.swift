//
//  ResourceFinder.swift
//  PoqPlatform
//
//  Created by Andrei Mirzac on 16/05/2018.
//

import Foundation
import PoqModuling
import PoqUtilities
import UIKit

open class ResourceFinder {
    
    /// Looks through the bundles of all the modules in the order they were added and returns the path name for the first bundle in which the resource is found.
    public static func path(forResource resourceName: String, ofType type: String) -> String? {
        
        guard let path = PoqPlatform.shared.modules.compactMap({ $0.bundle.path(forResource: resourceName, ofType: type) }).first else {
            Log.error("Missing Resource with name \(resourceName) ofType \(type)")
            return nil
        }
        return path
    }
}
