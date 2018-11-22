//
//  VisualSearchOverlayView.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 15/05/2018.
//

import Foundation

open class VisualSearchOverlayView: UIView {
    @IBOutlet open var imageView: UIImageView?
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeFromSuperview()
    }
}
