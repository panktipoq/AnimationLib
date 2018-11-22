//
//  ProductInfoViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 03/06/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

open class ProductInfoViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AddToBagButtonDelegate {
    
    // IB Outlets
    @IBOutlet weak var ratingView: UIView?
    @IBOutlet public weak var priceLabel: UILabel?
    @IBOutlet public weak var titleLabel: UILabel?
    @IBOutlet public weak var swipeView: UICollectionView?
    @IBOutlet public weak var addToBagButton: AddToBagButton? {
        didSet {
            if let fontName = addToBagButton?.titleLabel?.font.fontName {
                addToBagButton?.titleLabel?.font = UIFont(name: fontName, size: CGFloat(AppSettings.sharedInstance.pdpAddToBagLabelFontSize))
            }
            addToBagButton?.accessibilityIdentifier = AccessibilityLabels.pdpAddToBag
        }
    }
    // Promotion Label
    @IBOutlet public weak var promotionLabel: UILabel?

    // TODO: we need move all like buttons creation in one place
    @IBOutlet public weak var likeButton: UIButton? {
        didSet {
            likeButton?.setImage(ResourceProvider.sharedInstance.clientStyle?.pdpWishlistButtonImageDefault, for: UIControlState())
            likeButton?.setImage(ResourceProvider.sharedInstance.clientStyle?.pdpWishlistButtonImagePressed, for: UIControlState.selected)
        }
    }

    @IBOutlet public var likeButtonConstraints: [NSLayoutConstraint] = []
    
    @IBOutlet public weak var pageControl: UIPageControl?
    
    // Class variables
    public var product: PoqProduct?
    
    // Callback delegates
    public weak var productDetailDelegate: ProductDetailViewDelegate?
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        accessibilityIdentifier = AccessibilityLabels.productBasicDetail
        likeButton?.accessibilityIdentifier = AccessibilityLabels.likeButton
    }
    
    // MARK: - Setup
    
    open func setup(using product: PoqProduct) {
        
        self.product = product
        
        // Set up swipe view
        swipeView?.dataSource = self
        swipeView?.delegate = self
        swipeView?.isPagingEnabled = true
        swipeView?.registerPoqCells(cellClasses: [ProductImageCell.self])
        swipeView?.showsHorizontalScrollIndicator = false
        
        //Set up pagecontrol
        if let imagePageControl = pageControl {
            imagePageControl.isHidden = !AppSettings.sharedInstance.enablePageControl
            if let imageCount = product.productPictures?.count {
                imagePageControl.numberOfPages = imageCount
            }
            imagePageControl.tintColor = AppTheme.sharedInstance.pdpPageControlTintColor
            imagePageControl.currentPageIndicatorTintColor = AppTheme.sharedInstance.pdpPageControlCurrentTintColor
        }
        
        // set product title
        titleLabel?.attributedText = LabelStyleHelper.setupProductTitleLable(brand: product.brand,
                                                                             title: product.title)
        
        if let priceLabelUnwrapped = priceLabel {
            
            priceLabelUnwrapped.attributedText = LabelStyleHelper.initPriceLabel(product.price,
                                                                                 specialPrice: product.specialPrice,
                                                                                 priceFormat: AppSettings.sharedInstance.pdpPriceFormat,
                                                                                 priceFontStyle: AppTheme.sharedInstance.pdpPriceFont,
                                                                                 specialPriceFontStyle: AppTheme.sharedInstance.pdpSpecialPriceFont)
 
        }
        
        if let numberOfReviews = product.numberOfReviews, numberOfReviews > 0 {
            
            // TODO: Setup star rating
        } else {
            
            // Remove star rating view
            // so title label occupies the whole space
            if let ratingView = ratingView {
                ratingView.removeFromSuperview()
            }
        }
        
        //handle out of stock
        if let sizes = product.productSizes {
            addToBagButton?.isEnabled = !sizes.isEmpty
        }

        // Handle Promotion text
        if let promotion = product.promotion {
            promotionLabel?.text = promotion
        } else {
            promotionLabel?.text = ""
        }
        swipeView?.reloadData()
    }

    @IBAction open func likeButtonClicked(_ sender: UIButton) {
        
        if let likeDelegate = productDetailDelegate {
            
            likeDelegate.likeButtonClicked()
        }
    }

    @IBAction open func addToBagButtonClicked(_ sender: Any?) {
        if let addToBagDelegate = productDetailDelegate {
            addToBagDelegate.addToBagButtonClicked()
        }
    }
    
    @IBAction open func reviewsButtonClicked(_ sender: UIButton) {
        
        Log.verbose("Open Reviews clicked")
        
        productDetailDelegate?.reviewsButtonClicked()
    }
    
    // MARK: Swipe view delegates
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return product?.productPictures?.count ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ProductImageCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        let productPicture = product?.productPictures?[indexPath.row]
        
        guard let urlString = productPicture?.url, let imageUrl = URL(string: urlString),
            let imageView = cell.imageView else {
                    
            return cell
        }
        
        imageView.getImageFromURL(imageUrl, isAnimated: true) {
            [weak weakSelf = self]
            (image: UIImage?) in
            
            // we want put like button im properposition, if it is first image
            guard let existedImage = image, indexPath.row == 0 else {
                return
            }
            
            weakSelf?.placeLikeButton(imageView, image: existedImage)
        }
        
        imageView.contentMode = ImageHelper.returnImageScalingMode(fromString: AppSettings.sharedInstance.pdpProductImageContentMode)
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.bounds.size
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            imageCarouselDidEndDragging(collectionView)
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate, let collectionView = scrollView as? UICollectionView {
            imageCarouselDidEndDragging(collectionView)
        }
    }
    
    open func imageCarouselDidEndDragging(_ swipeView: UICollectionView) {
        
        let row = Int(swipeView.contentOffset.x / swipeView.bounds.width)
        Log.verbose("Swipe view: Index \(row)")
        
        if let imagePageControl = pageControl {
            imagePageControl.currentPage = row
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        Log.verbose("Swipe view: Selected \(index)")
        
        if let imageClickDelegate = productDetailDelegate,
            let cell = collectionView.cellForItem(at: indexPath) as? ProductImageCell,
            let imageView = cell.imageView {
            
            imageClickDelegate.imageViewClicked(indexPath.row, imageView: imageView)
        }
    }
    
    /**
     For some apps we need put heart correcpond to image position
     Here we assume scaleMode is AspectFit
     All position will be calculated with assumption, imaview.bounds == swipeView.bounds.
     
     - parameter view: first view in swipe view
     
     - parameter image: image, which is in UIImageView, or will be shortly(after animation)
     */
    fileprivate func placeLikeButton(_ view: UIView, image: UIImage) {
        
        guard let validLikeButton = likeButton, AppSettings.sharedInstance.pdpLikePositionBasedOnImageFrame else {
            return
        }
        
        var likeButtonFrame: CGRect = validLikeButton.frame

        if likeButtonConstraints.count > 0 {
            NSLayoutConstraint.deactivate(likeButtonConstraints)
        }
        
        likeButtonConstraints.removeAll()
        validLikeButton.translatesAutoresizingMaskIntoConstraints = true
        
        let indent: CGFloat = 5.0
        
        guard let validBounds = swipeView?.bounds else {
            return
        }
        
        // calculate real image frame
        let scale = fmin(validBounds.width / image.size.width,
         
                         validBounds.height / image.size.height)
        
        let scaledImageSize: CGSize = CGSize( width: scale * image.size.width, height: scale * image.size.height)
        
        let frameWidth  = validBounds.width
        let frameHeight = validBounds.height
        
        let imageFrame: CGRect = CGRect(x: 0.5 * (frameWidth - scaledImageSize.width),
                                        y: 0.5 * (frameHeight - scaledImageSize.height),
                                        width: scaledImageSize.width, height: scaledImageSize.height)
        
        let globalImageFrame: CGRect = self.convert(imageFrame, to: validLikeButton.superview)
        
        likeButtonFrame.origin.x = globalImageFrame.maxX - likeButtonFrame.size.width - indent
        likeButtonFrame.origin.y = globalImageFrame.minY + indent
        
        validLikeButton.frame = likeButtonFrame
    }
}
