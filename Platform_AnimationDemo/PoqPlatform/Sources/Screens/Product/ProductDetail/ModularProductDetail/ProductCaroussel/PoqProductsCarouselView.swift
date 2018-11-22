//
//  PoqCarrousselProductView .swift
//  Poq.iOS.Platform
//
//  Created by Mohamed Arradi on 15/05/2017.
//
//

import Foundation
import PoqNetworking
import PoqAnalytics
import UIKit

open class PoqProductsCarouselView: UIView, PoqProductsCarouselPresenter, ViewOwner, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ProductPeekPresenter {
    public func peekViewDelegate(parentProductViewController: PoqBaseViewController, collectionView: UICollectionView, viewModel: PeekProductsProvider) -> ProductPeekViewDelegate? {
        return ProductPeekViewDelegate(parentProductViewController: parentProductViewController, collectionView: collectionView, viewModel: viewModel)
    }
    
    @IBOutlet weak public var collectionView: UICollectionView?
    
    @IBOutlet weak public var rightDetailButton: UIButton? {
        didSet {
            rightDetailButton?.titleLabel?.font = AppTheme.sharedInstance.recentlyViewCarouselDetailTitleFont
            rightDetailButton?.setTitleColor(AppTheme.sharedInstance.recentlyViewedCarouselDetailTitleColor, for: .normal)
        }
    }
    
    @IBOutlet weak public var titleLabel: UILabel? {
        didSet {
            titleLabel?.text = AppLocalization.sharedInstance.productCarousselTitleText
            titleLabel?.font = AppTheme.sharedInstance.recentlyViewedCarouselTitleFont
        }
    }
    
    weak var presenter: PoqProductDetailPresenter?
    
    open weak var delegate: PoqProductsCarouselViewDelegate?

    var content: PoqProductDetailContentItem?
    
    weak public var viewControllerForProductPeek: UIViewController?
    
    var peekViewDelegate: UIViewControllerPreviewingDelegate?
    
    public var viewModel: PoqProductsCarouselService? {
        didSet {
            guard let viewModelUnwrapped = viewModel else {
                return
            }
            viewModelUnwrapped.presenter = self
            collectionView?.reloadData()
            if viewModelUnwrapped.isLoading && viewModelUnwrapped.products.count == 0 {
                createSpinnerView()
            }
        }
    }
    var viewProductAnalyticsSource = ViewProductSource.productsCarousel.rawValue
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView?.registerPoqCells(cellClasses: [PoqProductsCarouselCell.self])
    }
   
    override open var intrinsicContentSize: CGSize {
        
        return CGSize(width: UIScreen.main.bounds.size.width, height: (titleLabel?.frame.size.height ?? 0) + collectionItemSize.height)
    }
    
    // MARK: IBAction
    
    @IBAction func rightButtonAction(sender: AnyObject?) {
        NavigationHelper.sharedInstance.loadRecentlyViewedProducts()
    }
    
    // MARK: ViewOwner
    
    public var view: UIView! {
        get {
            return self
        }
    }
    
    // MARK: PoqPresenter
    
    public func showErrorMessage(_ networkError: NSError?) {}
    
    public func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        notifyProductsChanges()
        
        collectionView?.reloadData()
    }
    
    public func empty() {
        notifyProductsChanges()
    }

    public func error(_ networkError: NSError?) {
        notifyProductsChanges()
    }
    
    public func updateProductCarousel() {
        
        notifyProductsChanges()
    
        collectionView?.reloadData()
    }
    
    fileprivate func notifyProductsChanges() {
        
        if let viewModelUnwrapped = viewModel, viewModelUnwrapped.products.count == 0 {
            delegate?.productsCarouselViewDidClearItems(self)
        }
        
    }
    
    public func createPeekView() {
        peekViewDelegate = registerForPeekPreview(collectionView: collectionView, viewModel: viewModel)
    }
        
    // MARK: UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let productsCount = viewModel?.products.count else {
            return 0
        }
        return min(productsCount, Int(AppSettings.sharedInstance.maxProductsOnProductsCarousel))
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PoqProductsCarouselCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        if let product = viewModel?.products[indexPath.row] {
            cell.setup(using: product)
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let product = viewModel?.products[indexPath.row], let productId = product.id else {
            return
        }
        
        NavigationHelper.sharedInstance.loadProduct(productId, externalId: product.externalID, source: viewProductAnalyticsSource, productTitle: product.title)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionItemSize
    }
    fileprivate var collectionItemSize: CGSize {
        let width = UIScreen.main.bounds.size.width/CGFloat(AppSettings.sharedInstance.productsPerScreenOnProductsCarousel)
        let imageIndent: CGFloat = 8.0
        let height = (width - 2.0 * imageIndent) / CGFloat(AppSettings.sharedInstance.productsCarouselImageRatio) + imageIndent + CGFloat(AppSettings.sharedInstance.productsCarouselTextAreaHeight)
        
        return CGSize(width: width, height: height)
    }
}
