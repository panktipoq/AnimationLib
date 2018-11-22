//
//  ImageHelper.swift
//  Poq.iOS
//
//  Created by Jun Seki on 10/02/2016.
//
//

import Foundation
import PoqUtilities
import UIKit

open class ImageHelper: NSObject {
    
    open class func returnImageScalingMode(_ mode: PoqImageContentMode) -> UIViewContentMode {
        switch mode {

        case .ScaleAspectFill:
            return UIViewContentMode.scaleAspectFill
        case .ScaleAspectFit:
            return UIViewContentMode.scaleAspectFit
        }
    }
    
    public class func returnImageScalingMode(fromString string: String) -> UIViewContentMode {
        guard let mode: PoqImageContentMode = PoqImageContentMode(rawValue: string) else {
            Log.error("Can't conver \(string) to PoqImageContentMode")
            return UIViewContentMode.scaleAspectFill
        }

        switch mode {
        case .ScaleAspectFill:
            return UIViewContentMode.scaleAspectFill
        case .ScaleAspectFit:
            return UIViewContentMode.scaleAspectFit
        }
    }
}
