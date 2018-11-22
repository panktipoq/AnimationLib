//
//  ImageInjectionResolver.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Konstantin Bakalov on 2/16/17.
//
//

import Foundation
import PoqModuling
import PoqUtilities
import UIKit

/**
 ImageInjectionResolver is a helper class that has a static method that allows us to:
 - Find an image in the PoqPlatform framework
 - Override an image in the PoqPlatorm framework with an image of the same name from the client
 
 It loops through the bundles and looks for the image in each bundle and returns the image from the first bundle it finds it in.
 It checks the app bundle first followed by the Platform bundle.
 */
open class ImageInjectionResolver {
    
    /**
     Search for UIImage with a given name in all available bundles.
     - parameter named: The image asset name
     - returns: An UIImage object if such was found for `named` else it returns `nil`.
     */
    public static func loadImage(named imageName: String) -> UIImage? {
        Log.verbose("Loading image asset with name \(imageName)")
        
        let bundles: [Bundle] = PoqPlatform.shared.modules.map({ return $0.bundle })
        for bundle in bundles {
            Log.verbose("Checking bundle \(bundle.bundleURL)")
            
            if let imageFound = UIImage(named: imageName, in: bundle, compatibleWith: nil) {
                return imageFound
            }
        }
        
        Log.error("Didn't find suitable image asset with name \(imageName)")
        return nil
    }
}
