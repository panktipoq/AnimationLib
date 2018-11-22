//
//  NibInjectionResolver.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 9/27/16.
//
//

import Foundation
import PoqModuling
import PoqUtilities
import UIKit

/**
 NibInjectionResolver is a helper class with static methods that allow us to:
 - Find a nib of a given name in all the available bundles
 - Return the View of a given return if it is present in a nib of a given name in any of the bundles
 - Find the bundle in which a give nib exists
 
 This allows us to override a given platform nib file by providing a client nib file with the same nib, as these methods will always look for the nib in the app bundle first.
 Note: This helper will check app bundle first(assume overrided nib files has more priority)
 */
open class NibInjectionResolver {
    
    /**
     Search proper bundle with nib file, load nib and find our view in it.
     - parameter nibName: Optional. Nib file name, since not always nib named as desired view. If nil paases we will search nib file with name equal to class name
     - parameter owner: Optional. owner, whicl will be used, while loading nib 
     - returns: view, if nib was found and it contains view. Otherwise nill will be  returned
     */
    public static func loadViewFromNib<V: UIView>(_ nibName: String? = nil, owner: NSObject? = nil) -> V? {
        
        let nibFileName: String
        if let existedNibName = nibName {
            nibFileName = existedNibName
        } else {
            nibFileName = String(describing: V.self)
        }
        
        Log.verbose("Loading nib with name \(nibFileName)")
        
        let bundles: [Bundle] = PoqPlatform.shared.modules.map({ return $0.bundle })
        for bundle in bundles {
            Log.verbose("Checking bundle \(bundle.bundleURL)")

            guard let _ = bundle.path(forResource: nibFileName, ofType: "nib") else {
                continue
            }
            
            guard let items = bundle.loadNibNamed(nibFileName, owner: owner, options: nil) else {
                continue
            }
            
            var resView: V?
            for item in items {
                if let desiredView = item as? V {
                    resView = desiredView
                    break
                }
            }
            
            if let view = resView {
                return view
            }
        }
        
        Log.warning("Didn't find suitable nib file with desired view, kind of \(NSStringFromClass(V.self))")
        return nil
    }
    
    /**
     Search UINib in all bundles of platform
     - parameter nibName: nib filename
     - returns: valid UINib if we found bundle with nib named <nibName>
     */
    public static func findNib(_ nibName: String) -> UINib? {

        Log.verbose("Loading nib with name \(nibName)")
        
        let bundles: [Bundle] = PoqPlatform.shared.modules.map({ return $0.bundle })
        for bundle in bundles {
            Log.verbose("Checking bundle \(bundle.bundleURL)")
            
            guard let _ = bundle.path(forResource: nibName, ofType: "nib") else {
                continue
            }

            return UINib(nibName: nibName, bundle: bundle)
        }
        
        Log.warning("Didn't find suitable nib file with name \(nibName)")
        return nil
    }
    
    /**
     Search nib in all bundles of platform, and return this bundle
     - parameter nibName: nib filename
     - returns: valid Bundle, if we found bundle with nib named <nibName>
     */
    public static func findBundle(nibName nibNameOrNil: String?) -> Bundle? {
        
        guard let nibName = nibNameOrNil else {
            return nil
        }
        
        Log.verbose("Loading nib with name \(nibName)")
        
        let bundles: [Bundle] = PoqPlatform.shared.modules.map({ return $0.bundle })
        for bundle in bundles {
            Log.verbose("Checking bundle \(bundle.bundleURL)")
            
            guard let _ = bundle.path(forResource: nibName, ofType: "nib") else {
                continue
            }
            
            return bundle
        }
        
        Log.warning("Didn't find suitable nib file with name \(nibName)")
        return nil
    }
   
}
