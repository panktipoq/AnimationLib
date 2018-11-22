//
//  OfferListViewCell.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 05/01/2017.
//
//

import Foundation
import PoqNetworking
import UIKit

open class OfferListViewCell: UICollectionViewCell, PoqOfferListReusableView {
    
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var detailLabel: UILabel?
    @IBOutlet var captionLabel: UILabel?
   
    weak var presenter: PoqOfferListPresenter?
    
   
    
    var offer: PoqOffer? {
        didSet {
            
            if offer == nil {
                nameLabel?.text = nil
                detailLabel?.text = nil
                captionLabel?.text = nil
            }
            
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        offer = nil
    }
    override open func prepareForReuse() {
        super.prepareForReuse()
        offer = nil
    }
    
    func setup(using content: PoqOfferListContentItem) {
        
        nameLabel?.font = AppTheme.sharedInstance.offerNameLabelFont
        detailLabel?.font = AppTheme.sharedInstance.offerDetailLabelFont
        captionLabel?.font = AppTheme.sharedInstance.offerCaptionLabelFont
        
        nameLabel?.textColor = AppTheme.sharedInstance.offerNameLabelColor
        detailLabel?.textColor = AppTheme.sharedInstance.offerDetailLabelColor
        captionLabel?.textColor = AppTheme.sharedInstance.offerCaptionLabelColor
        
        offer = content.offer
        nameLabel?.text = content.offer.name
        detailLabel?.text = content.offer.details
        captionLabel?.text = content.offer.captionTitle
        
    }
    
}
