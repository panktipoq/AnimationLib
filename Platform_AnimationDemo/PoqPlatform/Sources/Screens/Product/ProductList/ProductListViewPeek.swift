//
//  ProductListViewPeek.swift
//  Poq.iOS.Platform
//
//  Created by Rachel McGreevy on 24/05/2017.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

open class ProductListViewPeek: PoqBaseViewController {
    
    open var product: PoqProduct?
    open var parentProductListViewController: PoqBaseViewController?
    open var parentProductCellViewLikeButton: UIButton?
    var detailsAction, wishlistAction, shareAction: UIPreviewAction?
    let labelHeight: CGFloat = 40
    
    @IBOutlet weak var productImageView: PoqAsyncImageView?
    @IBOutlet weak public var productPriceLabel: UILabel?
    
    @IBOutlet var productVideoView: PoqVideoView?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        guard let product = product else {
            Log.error("No product to peek")
            return
        }
        
        if let priceLabel = productPriceLabel {
            if AppSettings.sharedInstance.peekShowsProductPrice {
                
                priceLabel.isHidden = false
                
                productPriceLabel?.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true

                priceLabel.attributedText = LabelStyleHelper.initPriceLabel(
                    product.price,
                    specialPrice: product.specialPrice,
                    isGroupedPLP: product.isGroupedProduct,
                    priceFormat: AppSettings.sharedInstance.pdpPriceFormat,
                    priceFontStyle: AppTheme.sharedInstance.peekPriceFont,
                    specialPriceFontStyle: AppTheme.sharedInstance.peekSpecialPriceFont)
                
            } else {
                
                priceLabel.isHidden = true
                priceLabel.frame.size.height = CGFloat(0)
            }
        }
                
        if AppSettings.sharedInstance.isVideoEnabledOnPeek, let videoUrlValue = product.videoURL, !videoUrlValue.isEmpty, let videoUrl = URL(string: videoUrlValue), let videoView = productVideoView {
            
            videoView.isHidden = false
            productImageView?.isHidden = true
            
            videoView.fetchVideo(from: videoUrl) { (videoTrack) in
                if let video = videoTrack {
                    DispatchQueue.main.async {
                        self.setPeekContentSize(with: video.naturalSize)
                    }
                }
            }
            
        } else if let productImageView = productImageView, let peekImageUrlString = product.thumbnailUrl, !peekImageUrlString.isEmpty, let peekImageUrl = URL(string: peekImageUrlString) {
            productImageView.fetchImage(from: peekImageUrl) { (image) in
                if image != nil {
                    self.setPeekContentSize(with: productImageView.intrinsicContentSize)
                }
            }
        }
        
        if let title = product.title, let id = product.id {
            PoqTrackerHelper.trackOpenPeek(title, skuLabel: String(describing: id))
            PoqTrackerV2.shared.peekAndPop(action: PeekAndPopAction.peek.rawValue, productId: id, productTitle: title)
        }
        
        instantiateQuickActions()

    }
    
    func setPeekContentSize(with naturalPeekViewSize: CGSize) {
        self.preferredContentSize = naturalPeekViewSize
        if AppSettings.sharedInstance.peekShowsProductPrice {
            self.preferredContentSize.height += labelHeight
        }
    }
    
    func instantiateQuickActions() {
        
        detailsAction = UIPreviewAction(title: AppLocalization.sharedInstance.peekQuickActionViewDetails, style: .default) {
            [weak self] (action, viewController) in
            
            guard let product = self?.product else {
                Log.error("No product to view detils")
                return
            }
            
            if let title = product.title, let id = product.id {
                PoqTrackerHelper.trackPeekLoadPDP(title, skuLabel: String(describing: id))
                PoqTrackerV2.shared.peekAndPop(action: PeekAndPopAction.details.rawValue, productId: id, productTitle: title)
            }
            
            guard let relatedProductIds = product.relatedProductIDs, relatedProductIds.count > 0 else {
                if let productId = product.id {
                    NavigationHelper.sharedInstance.loadProduct(productId, externalId: product.externalID, source: ViewProductSource.peekViewDetails.rawValue, productTitle: product.title)
                }
                return
            }
            
            if let bundleId = product.bundleId, !bundleId.isEmpty {
                NavigationHelper.sharedInstance.loadBundledProduct(using: product)
            } else {
                NavigationHelper.sharedInstance.loadGroupedProduct(with: product)
            }
            
        }
        
        shareAction = UIPreviewAction(title: AppLocalization.sharedInstance.peekQuickActionShare, style: .default) {
            [weak self] (action, viewController) in
            
            if let parentProductListViewController = self?.parentProductListViewController, let productUrlString = self?.product?.productURL, !productUrlString.isEmpty, let productUrl = URL(string: productUrlString) {
                
                let activityViewController = UIActivityViewController(activityItems: [productUrl], applicationActivities: nil)
                activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                activityViewController.popoverPresentationController?.sourceView = self?.view
                activityViewController.completionWithItemsHandler = self?.shareDidFinish
                parentProductListViewController.present(activityViewController, animated: true, completion: nil)
            }
        }
        
        wishlistAction = UIPreviewAction(title: AppLocalization.sharedInstance.peekQuickActionWishlist, style: .default) {
            [weak self] (action, viewController) in
            
            guard let product = self?.product else {
                Log.error("No product to add to wishlist")
                return
            }
            
            WishlistController.shared.add(product: product)
            self?.parentProductCellViewLikeButton?.isSelected = true
            
            if let title = product.title, let id = product.id {
                PoqTrackerHelper.trackPeekAddToWishlist(title, skuLabel: String(describing: id))
            }
        }

    }
    
    func shareDidFinish(_ activity: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) {
        
        if !completed {
            return
        }
        
        Log.verbose("Product Share: \(activity?.rawValue ?? "nil")")
        PoqShareTracking.trackShareEvent(activity?.rawValue)
        
        if let title = product?.title, let id = product?.id {
            PoqTrackerHelper.trackPeekShare(title, skuLabel: String(describing: id))
            PoqTrackerV2.shared.share(productId: id, productTitle: title)
        }
    }
    
    override open var previewActionItems: [UIPreviewActionItem] {
        
        guard let detailsAction = detailsAction, let shareAction = shareAction, let wishlistAction = wishlistAction else {
            return []
        }
        
        guard let product = product, !product.isGroupedProduct else {
            return [detailsAction, shareAction]
        }

        return [detailsAction, wishlistAction, shareAction]
        
    }
}
