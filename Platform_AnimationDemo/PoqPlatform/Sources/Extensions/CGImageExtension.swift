//
//  CGImageExtension.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 8/8/17.
//
//

import Foundation
import CoreGraphics
import PoqModuling
import PoqUtilities

extension CGImage {
    
    /// Creates context and render iamge in it. It allows move deconding from main thread
    func render() -> CGImage? {
        
        // TODO: scale down images to screen width, if they are too big.
        
        let bitmapBytesPerRow = Int(width) * 4
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let bitmapContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else {
            Log.error("Can't create bitmap context")
            return nil
        }
        
        let size = CGSize(width: CGFloat(width), height: CGFloat(height))
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        bitmapContext.draw(self, in: bounds)

        return bitmapContext.makeImage()
    }
}
