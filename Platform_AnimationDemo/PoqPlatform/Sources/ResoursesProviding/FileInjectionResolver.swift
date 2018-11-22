//
//  FileInjectionResolver.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Gabriel Sabiescu on 10.10.2018.
//
//

import Foundation
import PoqModuling
import PoqUtilities

/**
 FileInjectionResolver is a helper class that has a static method that allows us to:
 - Retrieve a file path

 It loops through the bundles and looks for the file in each bundle and returns the file URL from the first bundle it finds it in.
 It checks the app bundle first followed by the Platform bundle.
 */
class FileInjectionResolver {
    
    public static func fileURL(named fileName: String, extension: String) -> URL? {
        Log.verbose("Fetch file url with filename name \(fileName)")
        
        let bundles: [Bundle] = PoqPlatform.shared.modules.map({ return $0.bundle })
        for bundle in bundles {
            Log.verbose("Checking bundle \(bundle.bundleURL)")
            if let validURL = bundle.url(forResource: fileName, withExtension: `extension`) {
                return validURL
            }
        }
        
        Log.error("Didn't find suitable file with name \(fileName)")
        return nil
    }
}
