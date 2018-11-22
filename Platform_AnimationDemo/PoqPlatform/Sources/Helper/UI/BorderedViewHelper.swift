//
//  BorderedViewHelper.swift
//  Poq.iOS.Platform
//
//  Created by Manuel Marcos Regalado on 23/12/2016.
//
//

import Foundation

public enum BorderViewPosition {
    case top
    case bottom
    case right
    case left
}

public extension UIView {
    
    @nonobjc
    func addBorders(_ borders: [BorderViewPosition], color: UIColor, width: CGFloat) {
        for borderViewPosition: BorderViewPosition in borders {
            switch borderViewPosition {
            case .top:
                addTopBorderWithColor(color, width: width)
                break
            case .bottom:
                addBottomBorderWithColor(color, width: width)
                break
            case .right:
                addRightBorderWithColor(color, width: width)
                break
            case .left:
                addLeftBorderWithColor(color, width: width)
                break
            }
        }
    }
    
    @nonobjc
    fileprivate func addTopBorderWithColor(_ color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: width)
        layer.addSublayer(border)
    }
    
    @nonobjc
    fileprivate func addRightBorderWithColor(_ color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: frame.size.width - width, y: 0, width: width, height: frame.size.height)
        layer.addSublayer(border)
    }
    
    @nonobjc
    fileprivate func addBottomBorderWithColor(_ color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: frame.size.height - width, width: frame.size.width, height: width)
        layer.addSublayer(border)
    }
    
    @nonobjc
    fileprivate func addLeftBorderWithColor(_ color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: frame.size.height)
        layer.addSublayer(border)
    }
}
