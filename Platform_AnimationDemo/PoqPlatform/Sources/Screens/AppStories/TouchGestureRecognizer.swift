//
//  TouchGestureRecognizer.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 8/22/17.
//
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class TouchGestureRecognizer: UIGestureRecognizer {
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)   
        state = .began
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = .ended
    }
    
}
