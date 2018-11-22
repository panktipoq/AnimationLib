//
//  UIImageExtension.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/26/17.
//
//

import Foundation
import PoqUtilities
import UIKit

extension UIImage {
    
    /// Create resizableimage filled with solid color
    /// - parameter color: image color
    @nonobjc
    public static func createResizableColoredImage(_ color: UIColor, cornerRadius: CGFloat = 0) -> UIImage? {
        
        let inset: CGFloat = 5
        let capInsets: UIEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        let dimensionSize: CGFloat = 2 * inset + 1

        let image = UIImage.createColoredImage(color, size: CGSize(width: dimensionSize, height: dimensionSize), corderRadius: cornerRadius)

        let resizableImage = image?.resizableImage(withCapInsets: capInsets, resizingMode: UIImageResizingMode.stretch)
        return resizableImage 
    }

    /// Create filled with solid color
    /// - parameter color: image color
    /// - parameter size: image size
    /// - parameter corderRadius: we can make corner radius, if 'corderRadius' > 0
    @nonobjc
    public static func createColoredImage(_ color: UIColor, size: CGSize, corderRadius: CGFloat = 0) -> UIImage? {
        
        let screenScale: CGFloat = UIScreen.main.scale

        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        
        let context = UIGraphicsGetCurrentContext()
        guard let validContext: CGContext  = context else {
            Log.error("Can't create context")
            return nil
        }
        
        validContext.setFillColor(color.cgColor)
        
        let path = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: size), cornerRadius: corderRadius)
        validContext.addPath(path.cgPath)
        validContext.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image 
    }
    
    /// This function will return the same image but with the orientation to always be UP. Sometimes UIImages that come from the camera might have the wrong orientation so this function makes sure that the orientation is always UP.
    ///
    /// - Returns: The image with the Up orientation
    public func fixedUpOrientation() -> UIImage? {
        
        guard imageOrientation != UIImageOrientation.up else {
            // This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else {
            Log.error("CGImage is not available")
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            Log.error("Not able to create CGContext")
            return nil
        }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        }
        
        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        guard let newCGImage = ctx.makeImage() else {
            Log.error("Not able to make image")
            return nil
        }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}
