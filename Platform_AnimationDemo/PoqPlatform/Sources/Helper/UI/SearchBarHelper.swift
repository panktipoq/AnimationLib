//
//  SearchBarHelper
//  Poq.iOS
//
//  Created by Jun on 20/10/2015.
//  Copyright (c) 2015 Poq . All rights reserved.
//

import Foundation
import PoqUtilities
import UIKit

open class SearchBarHelper {
    
    // MARK: - barcode scanner functionality
    
    public static func searchScanButtonClicked(_ viewControllerDelegate: UIViewController) {
        guard AppSettings.sharedInstance.enableScanOnSearchBar else {
            Log.error("go to barcode scanning")
            return
        }
        NavigationHelper.sharedInstance.loadScan()
    }

    // MARK: - Visual search functionality
    
    public static func searchVisualButtonClicked(_ viewControllerDelegate: UIViewController) {
        guard AppSettings.sharedInstance.enableVisualSearch else {
            Log.error("Trying to show visual search when it should be disabled")
            return
        }
        NavigationHelper.sharedInstance.loadVisualSearch()
    }
}
