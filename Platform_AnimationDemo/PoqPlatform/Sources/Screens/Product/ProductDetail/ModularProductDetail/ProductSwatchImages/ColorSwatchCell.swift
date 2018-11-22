//
//  ColorSwatchCell.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 7/10/17.
//
//

import Foundation
import PoqNetworking
import UIKit

public class ColorSwatchCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: PoqAsyncImageView?
    
    @IBOutlet weak var selectionView: ColorSwatchSelectionView?
    
    func setup(using color: PoqProductColor, selected: Bool) {
        guard let urlString = color.imageUrl, let url = URL(string: urlString) else {
            imageView?.image = nil
            selectionView?.isHidden = true
            return
        }
        
        imageView?.fetchImage(from: url, isAnimated: false, showLoading: false)
        selectionView?.isHidden = !selected
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView?.prepareForReuse()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        /// Problem that sizes of imageView might be updated after this function
        /// Possible reason: when function called contentView has correct size and it won't rearrange subviews  
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

        imageView?.layer.borderColor = UIColor.black.cgColor
        imageView?.layer.borderWidth = 1/UIScreen.main.scale
        imageView?.layer.masksToBounds = true
        if let imageViewUnwrapped = imageView {
            imageViewUnwrapped.layer.cornerRadius = imageViewUnwrapped.bounds.height/2
        }
         
    }

}

class ColorSwatchSelectionView: UIView {
    
    override func draw(_ rect: CGRect) {
        
        UIColor.black.setStroke()
        
        let rect = CGRect(origin: CGPoint(x: 1, y: 1), size: CGSize(width: bounds.size.width - 2, height: bounds.size.height - 2))
        let path = UIBezierPath(ovalIn: rect)
        path.lineWidth = 1
        path.stroke()
    }
}


