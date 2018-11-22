//
//  NSAttributedStringExtension.swift
//  Poq.iOS.Platform
//
//  Created by Mohamed Arradi-Alaoui on 18/05/2017.
//
//

import Foundation


extension NSAttributedString {
    
    @nonobjc
    func estimatedHeight(forWidth width: CGFloat) -> CGFloat {
        
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingRect = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading, .usesDeviceMetrics], context: nil)
        
        return boundingRect.height
    }
}
