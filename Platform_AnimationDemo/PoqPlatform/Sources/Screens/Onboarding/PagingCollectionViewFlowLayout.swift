//
//  PagingCollectionViewFlowLayout.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 28/12/2016.
//
//

import Foundation
import UIKit

class PagingCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        // we assume - we can have only one section in onbarding
        guard let existedCollectionView = collectionView, existedCollectionView.numberOfSections == 1 else {
            return CGPoint.zero
        }
        
        let contentOffset = existedCollectionView.contentOffset
        var offsetX = contentOffset.x
        
        // special case: touch while delecelrating - we will navigate to page wehre we touch
        if velocity == CGPoint.zero && existedCollectionView.isDecelerating {
            let touchPosition = existedCollectionView.panGestureRecognizer.location(in: existedCollectionView)
            offsetX = touchPosition.x
        }

        let pageWidth = UIScreen.main.bounds.size.width
        
        let numberOfRows = existedCollectionView.numberOfItems(inSection: 0)
        
        var targetLeftPage = Int(offsetX/pageWidth)
        
        let suggestedOffsetX = CGFloat(targetLeftPage) * pageWidth
        
        // we did some significant move in terms of speed
        if fabs(velocity.x) > 0.3 {
            if velocity.x > 0 && suggestedOffsetX < contentOffset.x {
                targetLeftPage += 1
            } else if velocity.x < 0 && suggestedOffsetX > contentOffset.x {
                targetLeftPage -= 1
            }
        }
        
        if targetLeftPage < 0 {
            targetLeftPage = 0
        } else if targetLeftPage >= numberOfRows {
            targetLeftPage = numberOfRows - 1
        }
        
        let res = CGPoint(x: CGFloat(targetLeftPage) * pageWidth, y: 0)
        return res
        
    }

}
