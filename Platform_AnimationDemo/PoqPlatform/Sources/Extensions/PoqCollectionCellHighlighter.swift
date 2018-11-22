//
//  PoqCollectionCellHighlighter.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 07/12/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import UIKit

public protocol PoqCollectionCellHighlighter {
    
    func highlightDidTap(_ cell:UICollectionViewCell, duration:TimeInterval, color:UIColor)
}

extension PoqCollectionCellHighlighter {
    
    public func highlightDidTap(_ cell:UICollectionViewCell, duration:TimeInterval, color:UIColor) {
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            
            cell.backgroundColor = color
            
            }, completion: { (isCompleted) -> Void in
                
            cell.backgroundColor = UIColor.white
        })
            
    }
}
