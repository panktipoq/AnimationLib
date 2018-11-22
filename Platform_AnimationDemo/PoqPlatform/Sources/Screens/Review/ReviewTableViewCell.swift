//
//  ReviewTableViewCell.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 3/10/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

open class ReviewTableViewCell: UITableViewCell {

    // MARK: - Variables
    
    /// Label with the review user name.
    @IBOutlet open weak var userNameLbl: UILabel?
    
    /// Label with the review title.
    @IBOutlet open weak var reviewTitleLbl: UILabel?
    
    /// Label with the review text.
    @IBOutlet open weak var reviewLbl: UILabel?
    
    /// View with the rating stars.
    @IBOutlet open weak var rating: StarRatingView?
    
    /// The Review Model with the data.
    var review: PoqProductReview?
    
    // MARK: - AwakeFromNib

    override open func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Set up view components
        
        rating?.starSize = CGSize(width: 15.0,
                                  height: 15.0)
        
        reviewLbl?.numberOfLines = 0
        reviewLbl?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        userNameLbl?.font = AppTheme.sharedInstance.reviewNameFont
        userNameLbl?.textColor = AppTheme.sharedInstance.reviewColor
            
        reviewTitleLbl?.font = AppTheme.sharedInstance.reviewTitleFont
        reviewTitleLbl?.textColor  = AppTheme.sharedInstance.reviewColor
        
        reviewLbl?.font = AppTheme.sharedInstance.reviewContentFont
        reviewLbl?.textColor = AppTheme.sharedInstance.reviewColor
    }

    // MARK: - UITableViewCell
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Setup
    
    /**
     Function to handle the view update.
     
     - Parameter review: Review Model with the data.
     */
    func updateView(_ review: PoqProductReview?) {
        
        self.review = review
        
        userNameLbl?.text = review?.username
        reviewTitleLbl?.text = review?.title
        reviewLbl?.text = review?.reviewText
        
        if let reviewRating = review?.rating {
            rating?.rating = Float(reviewRating)
        }
    }
}
