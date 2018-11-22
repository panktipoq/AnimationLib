//
//  PassThroughContainerView.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 03/02/2016.
//
//

import UIKit

/**
 * This class has pupose of container which pass throug most touches
 * Only touches which interact with subviews won't be passed
 * If there is no subview - all touches passed throgh
*/

public class PassThroughContainerView: UIView {

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview: UIView in subviews {
            
            // convert point
            let localViewPoint: CGPoint = convert(point, to: subview)
            let view: UIView? = subview.hitTest(localViewPoint, with: event)
            
            if let resView = view {
                return resView
            }
            
        }
        
        return nil
    }
}
