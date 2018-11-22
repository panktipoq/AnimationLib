//
//  ProductListViewFooter.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 26/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import UIKit

public class ProductListViewFooterCell: UICollectionViewCell {
    
    var footerSpinner: PoqSpinner?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupProgressView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressView()
    }
    
    func setupProgressView() {
        //set default size
        let frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        footerSpinner = PoqSpinner(frame: frame)
        // Set the tint color of the spinner
        footerSpinner?.tintColor = AppTheme.sharedInstance.mainColor
        if let footerSpinnerUnwrapped = footerSpinner {
            addSubview(footerSpinnerUnwrapped)
        }
        footerSpinner?.startAnimating()
    }
    
    public func stopAnimating() {
        footerSpinner?.stopAnimating()
    }
    
    public func startAnimating() {
        footerSpinner?.startAnimating()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        //update sizes
        let imageWidth = fminf(Float(bounds.size.width), Float(bounds.size.height))
        let progressViewWidth = CGFloat(imageWidth / 2)
        let frame = CGRect(x: 0, y: 0, width: progressViewWidth, height: progressViewWidth)
        footerSpinner?.frame = frame
        footerSpinner?.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        footerSpinner?.startAnimating()
    }
}
