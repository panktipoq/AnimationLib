//
//  WishlistTableViewFooter.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 24/12/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import UIKit

let WishlistTableViewFooterHeight: CGFloat = 44.0

class WishlistTableViewFooter: UITableViewHeaderFooterView {
    
    static let WishlistFooterReuseIdentifier: String = "WishlistTableViewFooter"
    
    var footerSpinner: PoqSpinner?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupProgressView()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupProgressView()
    }
   
    func setupProgressView()
    {
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundView = nil
        
        // set default size
        let frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        footerSpinner = PoqSpinner(frame: frame)
        // Set the tint color of the spinner
        footerSpinner?.tintColor = AppTheme.sharedInstance.mainColor
        self.addSubview(footerSpinner!)
        footerSpinner?.startAnimating()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let imageWidth = fminf(Float(self.bounds.size.width), Float(self.bounds.size.height));
        let progressViewWidth = CGFloat(imageWidth/2);
        let frame = CGRect(x: 0, y: 0, width: progressViewWidth, height: progressViewWidth);
        footerSpinner?.frame = frame

        footerSpinner?.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2);
        
    }
    
}
