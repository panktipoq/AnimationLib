//
//  BrandLandingTextCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 01/06/2016.
//
//

import PoqNetworking
import UIKit

final class StoryDetailTextCell: UICollectionViewCell {

    
    @IBOutlet weak final var highlightedView: UIView?
    @IBOutlet weak final var textLabel: UILabel?
    
    weak var imageView: PoqAsyncImageView? {
        get {return nil}
        set {}
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textLabel?.font = AppTheme.sharedInstance.brandTextCategoryFont
    }
    
    override var isHighlighted: Bool {
        didSet {
            highlightedView?.isHidden = !isHighlighted
        }
    }
}


extension StoryDetailTextCell: StoryDetailBlockCell {

    static func sizeForItem(_ item: PoqBlock) -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.size.width

        let height: CGFloat = CGFloat(AppSettings.sharedInstance.brandedTextCategoryCellHeight)
        return CGSize(width: width, height: height)
    }

    func updateUI(_ item: PoqBlock) {

        textLabel?.text = item.title
    }
}
