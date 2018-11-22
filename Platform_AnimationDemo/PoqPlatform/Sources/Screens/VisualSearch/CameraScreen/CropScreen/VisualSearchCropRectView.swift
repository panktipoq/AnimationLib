//
//  VisualSearchCropRectView.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 01/05/2018.
//

import Foundation

protocol VisualSearchCropRectViewDelegate: AnyObject {
    
    func cropRectViewDidBeginEditing(_ view: VisualSearchCropRectView)
    func cropRectViewDidChange(_ view: VisualSearchCropRectView)
    func cropRectViewDidEndEditing(_ view: VisualSearchCropRectView)
}

/**
 VisualSearchCropRectView is in charge of:
 
 - Drawing a 3x3 grid on top of the picture
 - Adding an image view with the corners asset so they look pannable/draggable to the user
 - Adding 4 views to each corner of the big grid which are draggable/pan. These views are `VisualSearchDraggableView`
 */
class VisualSearchCropRectView: UIView, VisualSearchDraggableViewDelegate {

    public static let visualSearchBottomRightDraggableViewAccessibilityId = "visualSearchBottomRightDraggableViewAccessibilityId"
    public static let visualSearchBottomLeftDraggableViewAccessibilityId = "visualSearchBottomLeftDraggableViewAccessibilityId"
    public static let visualSearchTopRightDraggableViewAccessibilityId = "visualSearchTopRightDraggableViewAccessibilityId"
    public static let visualSearchTopLeftDraggableViewAccessibilityId = "visualSearchTopLeftDraggableViewAccessibilityId"

    weak var delegate: VisualSearchCropRectViewDelegate?
    fileprivate var resizeImageView: UIImageView!
    fileprivate let topLeftCornerView = VisualSearchDraggableView()
    fileprivate let topRightCornerView = VisualSearchDraggableView()
    fileprivate let bottomLeftCornerView = VisualSearchDraggableView()
    fileprivate let bottomRightCornerView = VisualSearchDraggableView()
    fileprivate var initialRect = CGRect.zero
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        backgroundColor = UIColor.clear
        contentMode = .redraw
        
        setupAccessibility()
        setupResizeImageView()
        setupCornerViews()
    }
    
    fileprivate func setupAccessibility() {
        bottomRightCornerView.isAccessibilityElement = true
        bottomRightCornerView.accessibilityIdentifier = VisualSearchCropRectView.visualSearchBottomRightDraggableViewAccessibilityId
        bottomLeftCornerView.isAccessibilityElement = true
        bottomLeftCornerView.accessibilityIdentifier = VisualSearchCropRectView.visualSearchBottomLeftDraggableViewAccessibilityId
        topRightCornerView.isAccessibilityElement = true
        topRightCornerView.accessibilityIdentifier = VisualSearchCropRectView.visualSearchTopRightDraggableViewAccessibilityId
        topLeftCornerView.isAccessibilityElement = true
        topLeftCornerView.accessibilityIdentifier = VisualSearchCropRectView.visualSearchTopLeftDraggableViewAccessibilityId
    }
    
    fileprivate func setupResizeImageView() {
        resizeImageView = UIImageView(frame: bounds.insetBy(dx: -2.0, dy: -2.0))
        resizeImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let image = ImageInjectionResolver.loadImage(named: "PhotoCropEditorBorder") {
            resizeImageView.image = image.resizableImage(withCapInsets: UIEdgeInsets(top: 23.0, left: 23.0, bottom: 23.0, right: 23.0))
        }
        addSubview(resizeImageView)
    }
    
    fileprivate func setupCornerViews() {
        topLeftCornerView.delegate = self
        addSubview(topLeftCornerView)
        topRightCornerView.delegate = self
        addSubview(topRightCornerView)
        bottomLeftCornerView.delegate = self
        addSubview(bottomLeftCornerView)
        bottomRightCornerView.delegate = self
        addSubview(bottomRightCornerView)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in subviews where subview is VisualSearchDraggableView {
            if subview.frame.contains(point) {
                return subview
            }
        }
        return nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let width = bounds.width
        let height = bounds.height
        let borderPadding: CGFloat = 0.5

        // This for loop will be drawing the grid of the view with 3x3 squares which will appear on top of the picture
        for index in 1 ..< 4 {
            UIColor.white.set()
            UIRectFill(CGRect(x: round(CGFloat(index) * width / 3.0), y: borderPadding, width: 1.0, height: round(height) - borderPadding * 2.0))
            UIRectFill(CGRect(x: borderPadding, y: round(CGFloat(index) * height / 3.0), width: round(width) - borderPadding * 2.0, height: 1.0))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topLeftCornerView.frame.origin = CGPoint(x: topLeftCornerView.bounds.width / -2.0, y: topLeftCornerView.bounds.height / -2.0)
        topRightCornerView.frame.origin = CGPoint(x: bounds.width - topRightCornerView.bounds.width - 2.0, y: topRightCornerView.bounds.height / -2.0)
        bottomLeftCornerView.frame.origin = CGPoint(x: bottomLeftCornerView.bounds.width / -2.0, y: bounds.height - bottomLeftCornerView.bounds.height / 2.0)
        bottomRightCornerView.frame.origin = CGPoint(x: bounds.width - bottomRightCornerView.bounds.width / 2.0, y: bounds.height - bottomRightCornerView.bounds.height / 2.0)
    }
    
    // MARK: - VisualSearchDraggableView delegate methods
    
    func visualSearchDraggableViewDidBeginResizing(_ control: VisualSearchDraggableView) {
        initialRect = frame
        delegate?.cropRectViewDidBeginEditing(self)
    }
    
    func visualSearchDraggableViewDidResize(_ control: VisualSearchDraggableView) {
        frame = cropRectWithVisualSearchDraggableView(control)
        delegate?.cropRectViewDidChange(self)
    }
    
    func visualSearchDraggableViewDidEndResizing(_ control: VisualSearchDraggableView) {
        delegate?.cropRectViewDidEndEditing(self)
    }
    
    fileprivate func cropRectWithVisualSearchDraggableView(_ visualSearchDraggableView: VisualSearchDraggableView) -> CGRect {
        var rect = frame
        
        if visualSearchDraggableView == topLeftCornerView {
            rect = CGRect(x: initialRect.minX + visualSearchDraggableView.translation.x,
                          y: initialRect.minY + visualSearchDraggableView.translation.y,
                          width: initialRect.width - visualSearchDraggableView.translation.x,
                          height: initialRect.height - visualSearchDraggableView.translation.y)
        } else if visualSearchDraggableView == topRightCornerView {
            rect = CGRect(x: initialRect.minX,
                          y: initialRect.minY + visualSearchDraggableView.translation.y,
                          width: initialRect.width + visualSearchDraggableView.translation.x,
                          height: initialRect.height - visualSearchDraggableView.translation.y)
        } else if visualSearchDraggableView == bottomLeftCornerView {
            rect = CGRect(x: initialRect.minX + visualSearchDraggableView.translation.x,
                          y: initialRect.minY,
                          width: initialRect.width - visualSearchDraggableView.translation.x,
                          height: initialRect.height + visualSearchDraggableView.translation.y)
        } else if visualSearchDraggableView == bottomRightCornerView {
            rect = CGRect(x: initialRect.minX,
                          y: initialRect.minY,
                          width: initialRect.width + visualSearchDraggableView.translation.x,
                          height: initialRect.height + visualSearchDraggableView.translation.y)
        }
        
        let minWidth = topLeftCornerView.bounds.width * 2
        if rect.width < minWidth {
            rect.origin.x = frame.maxX - minWidth
            rect.size.width = minWidth
        }

        let minHeight = topLeftCornerView.bounds.height * 2
        if rect.height < minHeight {
            rect.origin.y = frame.maxY - minHeight
            rect.size.height = minHeight
        }
        return rect
    }
}
