//
//  StoryDetailBlockCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 15/06/2016.
//
//

import Foundation
import PoqNetworking
import UIKit

protocol StoryDetailBlockCell {
    
    /// Declare vars for default behaviour
    var textLabel: UILabel? { get set }
    var imageView: PoqAsyncImageView? { get set }
    
    static func sizeForItem(_ item: PoqBlock) -> CGSize
    
    func updateUI(_ item: PoqBlock)
}

extension StoryDetailBlockCell where Self: UICollectionViewCell {
    
    func updateUI(_ item: PoqBlock) {
        textLabel?.text = item.title
        
        if let pictureURL: String = item.pictureURL, let url = URL(string: pictureURL) {
            imageView?.getImageFromURL(url, isAnimated: false, showLoadingIndicator: true, resetConstraints: false, completion: { [weak self] (image: UIImage?) in
                // We need scale it
                if let cgImage: CGImage = image?.cgImage {
                    // Here we assume logo is 2 scaled
                    let scaledImage = UIImage(cgImage: cgImage, scale: 2.0, orientation: UIImageOrientation.up)
                    self?.imageView?.image = scaledImage
                }
            })
        } else {
            imageView?.image = nil
        }
    }
}
