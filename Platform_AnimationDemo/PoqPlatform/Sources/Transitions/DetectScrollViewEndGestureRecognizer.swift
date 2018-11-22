//
//  DetectScrollViewEndGestureRecognizer.swift
//  PoqPlatform
//
//  Created by GabrielMassana on 12/03/2018.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

open class DetectScrollViewEndGestureRecognizer: UIPanGestureRecognizer {
    
    var scrollView: UIScrollView?
    var isFail: Bool?
    
    override open func reset() {
        super.reset()
        isFail = nil
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        
        super.touchesMoved(touches, with: event)
        
        guard let scrollView = scrollView else {
            return
        }
        
        if state == .failed {
            return
        }
        
        if isFail != nil {
            if isFail == true {
                state = .failed
            }
            return
        }
        
        let velocity = self.velocity(in: self.view)
        guard let nowPoint = touches.first?.location(in: self.view),
            let prevPoint = touches.first?.previousLocation(in: self.view) else {
                return
        }
        
        let topVerticalOffset = -scrollView.contentInset.top
        
        if (fabs(velocity.x) < fabs(velocity.y)) && (nowPoint.y > prevPoint.y) && (scrollView.contentOffset.y <= topVerticalOffset) {
            self.isFail = false
        } else if scrollView.contentOffset.y >= topVerticalOffset {
            self.state = .failed
            self.isFail = true
        } else {
            self.isFail = false
        }
    }
}
