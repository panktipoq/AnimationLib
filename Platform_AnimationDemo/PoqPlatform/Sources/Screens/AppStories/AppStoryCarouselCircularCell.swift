//
//  AppStoryCarouselCircularCell.swift
//  PoqPlatform
//
//  Created by Balaji Reddy on 06/03/2018.
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

let AppStoryCarouselCircularAccessibilityIdBase = "AppStoryCarouselCircular_"
let AppStoryCarouselCircularCellImageContainerViewIdBase = "AppStoryCarouselCircularCellImageContainerView_"
let AppStoryCarouselCircularCellStoryTitleViewIdBase = "AppStoryCarouselCircularCellStoryTitleViewIdBase_"

public class AppStoryCarouselCircularCell: UICollectionViewCell, AppStoryCell {
    
    @IBOutlet weak public var imageView: PoqAsyncImageView?
    
    @IBOutlet var storyTitleLabel: UILabel?
    
    @IBOutlet var imageContainerView: UIView?
    
    // These gradient borders can be customised from the client
    public static var unViewedStoryBorderGradientColors = [UIColor.hexColor("#cb2d3e"), UIColor.hexColor("#ef473a"), UIColor.hexColor("#fe8c00")]
    public static var viewedStoryBorderGradientColors = [UIColor.gray, UIColor.lightGray]
    
    // The border of the imageContainer View
    fileprivate var circularGradientBorder: CAGradientLayer?
    
    fileprivate var hasBeenViewed = true
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        // Make the image container view circular and add a gradient border to it
        imageContainerView?.layer.cornerRadius = (imageContainerView?.bounds.width ?? 2)/2
        imageView?.layer.cornerRadius = (imageView?.bounds.width ?? 2)/2
        addGradientBorderToImageContainerView(highlighted: hasBeenViewed)
    }
    
    public func setup(using storyItem: AppStoryCarouselContentItem) {
        isUserInteractionEnabled = true
        imageView?.contentMode = .scaleAspectFill
        imageView?.fetchImage(from: storyItem.story.imageUrl)
        
        storyHasBeenRead(storyItem.isViewed)
        
        storyTitleLabel?.text = storyItem.story.title
        storyTitleLabel?.accessibilityIdentifier = AppStoryCarouselCircularCellStoryTitleViewIdBase + storyItem.story.identifier
        
        accessibilityIdentifier = AppStoryCarouselCircularAccessibilityIdBase + storyItem.story.identifier
        imageContainerView?.accessibilityIdentifier = AppStoryCarouselCircularCellImageContainerViewIdBase + storyItem.story.identifier
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        imageView?.prepareForReuse()
        
        circularGradientBorder?.removeFromSuperlayer()
        circularGradientBorder = nil
        hasBeenViewed = false
    }
    
    func storyHasBeenRead(_ hasBeenViewed: Bool) {
        
        storyTitleLabel?.textColor = hasBeenViewed ? UIColor.lightGray : UIColor.black
        
        self.hasBeenViewed = hasBeenViewed
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func addGradientBorderToImageContainerView(highlighted: Bool) {
        
        let borderGradientColors = highlighted ? AppStoryCarouselCircularCell.viewedStoryBorderGradientColors : AppStoryCarouselCircularCell.unViewedStoryBorderGradientColors
        let borderGradientWidth: CGFloat = highlighted ? 1.0 : 2.0
        
        circularGradientBorder?.removeFromSuperlayer()
        circularGradientBorder = imageContainerView?.layer.circularGradientBorder(colors: borderGradientColors, width: borderGradientWidth)
        
        guard let circularGradientBorder = circularGradientBorder else {
            
            Log.info("Unable to initialise gradient border.")
            return
        }
        
        imageContainerView?.layer.addSublayer(circularGradientBorder)
    }
}

extension CALayer {
    
    func circularGradientBorder(colors: [UIColor], width: CGFloat = 1) -> CAGradientLayer {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =  CGRect(origin: CGPoint.zero, size: self.bounds.size)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = colors.map({ $0.cgColor })
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = width
        shapeLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: width, dy: width), cornerRadius: bounds.width/2).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        return gradientLayer
    }
}
