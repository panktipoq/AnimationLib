//
//  NotFoundContentCollectionViewCell.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/24/17.
//
//

import Foundation
import UIKit

open class NotFoundContentCollectionViewCell: FullWidthAutoresizedCollectionCell {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        /// we need add it for autoresizing cells
        let heightContraint = heightAnchor.constraint(equalToConstant: 1)
        heightContraint.priority = UILayoutPriority(rawValue: 999.0)
        heightContraint.isActive = true
    }
    
}
