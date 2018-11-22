//
//  VisualSearchDraggableView.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 01/05/2018.
//

import Foundation

/// VisualSearchDraggableViewDelegate is in charge of letting its superview or other views know that changes have happened to the position, therefore, to the size.
protocol VisualSearchDraggableViewDelegate: AnyObject {
    
    func visualSearchDraggableViewDidBeginResizing(_ control: VisualSearchDraggableView)
    func visualSearchDraggableViewDidResize(_ control: VisualSearchDraggableView)
    func visualSearchDraggableViewDidEndResizing(_ control: VisualSearchDraggableView)
}

/**
 VisualSearchDraggableView is just a view that can be dragged around the main view. It will trigger the `VisualSearchDraggableViewDelegate` when changes happen to its position.
 */
class VisualSearchDraggableView: UIView {

    weak var delegate: VisualSearchDraggableViewDelegate?
    var translation = CGPoint.zero
    fileprivate var startPoint = CGPoint.zero
 
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: 44.0, height: 44.0))
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: CGRect(x: 0, y: 0, width: 44.0, height: 44.0))
        initialize()
    }
    
    fileprivate func initialize() {
        backgroundColor = UIColor.clear
        isExclusiveTouch = true
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            let translation = gestureRecognizer.translation(in: superview)
            startPoint = CGPoint(x: round(translation.x), y: round(translation.y))
            delegate?.visualSearchDraggableViewDidBeginResizing(self)
        case .changed:
            let translation = gestureRecognizer.translation(in: superview)
            self.translation = CGPoint(x: round(startPoint.x + translation.x), y: round(startPoint.y + translation.y))
            delegate?.visualSearchDraggableViewDidResize(self)
        case .ended, .cancelled:
            delegate?.visualSearchDraggableViewDidEndResizing(self)
        default: ()
        }        
    }
}
