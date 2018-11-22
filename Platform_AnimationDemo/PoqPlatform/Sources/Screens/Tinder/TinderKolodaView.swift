//
//  TinderKolodaView.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 22/12/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import Koloda

// TODO: Rename to TinderDeckView
open class TinderKolodaView: KolodaView {
    
    public let topOffset: CGFloat = 35
    public let horizontalOffset: CGFloat = 10
    public let defaultHeightRatio: CGFloat = 1.5
    
    open override func frameForCard(at index: Int) -> CGRect {
        // First card will have the biggest top margin
        // The last card will have the smallest
        // So the cards should look like this according to design
        //       _________
        //     _|_________|_
        //   _|_____________|_
        //  |                 |
        //  |        **       |
        //  |      __()__     |
        //  |        ||       |
        //  |       )  (      |
        //  |       ****      |
        //  |                 |
        //  |      ******     |
        //  |      ******     |
        //  |                 |
        //  |_________________|
        
        let height = frameHeight(UInt(index))
        let width = frameWidth(UInt(index), height: height)
        
        let x = frameX(UInt(index), width: width)
        let y = frameY(UInt(index), height: height)
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        return frame
    }  
    open func frameWidth(_ index: UInt, height: CGFloat) -> CGFloat {
        
        if index > 0 && index < 3 {
            
            return height / defaultHeightRatio - horizontalOffset * CGFloat(index)
        } else {
            
            return height / defaultHeightRatio
        }
    }
    
    open func frameHeight(_ index: UInt) -> CGFloat {
        
        let height = self.frame.height - (frameTopMargin(index) + frameBottomMargin(index))
        
        if index > 0 && index < 3 {
            
            // The height should be smaller for achiving a smaller card
            return height - CGFloat(topOffset) * CGFloat(index)
        } else {
            
            return height
        }
    }
    
    open func frameTopMargin(_ index: UInt) -> CGFloat {
        
        return topOffset
    }
    
    open func frameBottomMargin(_ index: UInt) -> CGFloat {
        
        return horizontalOffset
    }
    
    open func frameX(_ index: UInt, width: CGFloat) -> CGFloat {
        
        return (self.frame.width - width) / 2
    }
    
    open func frameY(_ index: UInt, height: CGFloat) -> CGFloat {
        
        let y = (self.frame.height - height) / 2 + topOffset
        
        if index > 0 && index < 3 {
            
            // Background cards should be aligning from top
            return y - CGFloat(topOffset) * CGFloat(index)
        } else {
            
            return y
        }
    }
}
