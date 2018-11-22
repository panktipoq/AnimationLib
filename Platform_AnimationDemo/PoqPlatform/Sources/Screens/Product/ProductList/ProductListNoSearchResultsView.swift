//
//  ProductListNoSearchResultsView.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 2/20/17.
//
//

import Foundation
import PoqUtilities
import UIKit

let productListNoSearchResultsViewAccessibilityId = "productListNoSearchResultsViewAccessibilityId"

/// This view will show sad smile and some text
/// While creation it load its content
open class ProductListNoSearchResultsView: UIView, PoqProductsCarouselViewDelegate {
    
    @IBOutlet weak var contentView: UIView?
    
    @IBOutlet weak open var iconImageView: UIImageView?
    @IBOutlet var iconImageViewHeight: NSLayoutConstraint?
    @IBOutlet weak open var noResultsTextLabel: UILabel?
    @IBOutlet weak var separator: SolidLine?

    fileprivate var productsCarouselView: PoqProductsCarouselView?
    
    weak public var productPeekOwnerViewController: UIViewController? {
        didSet {
            productsCarouselView?.viewControllerForProductPeek = productPeekOwnerViewController
            productsCarouselView?.createPeekView()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    // MARK: - API
    
    open func update(withQuery query: String) {
        
        let resString = String(format: AppLocalization.sharedInstance.noSearchResultsFormat, query)
        
        PoqTrackerHelper.trackSearchAction(PoqTrackerActionType.SearchNoResults, label: query)
        
        let attributedText = NSMutableAttributedString(string: resString,
                                                       attributes: [NSAttributedStringKey.font: AppTheme.sharedInstance.plpNoSearchResultsNormalFont])
        
        let format = AppLocalization.sharedInstance.noSearchResultsFormat
        // We won't make formated string, so search for "%@"
        if let range = format.range(of: "\"%@\"") {
            
            let start = format.distance(from: resString.startIndex, to: range.lowerBound)
            var length = format.distance(from: range.lowerBound, to: range.upperBound)
            
            length += query.count - 2
            
            let nsRange = NSRange(location: start, length: length)
            
            attributedText.addAttribute(NSAttributedStringKey.font,
                                        value: AppTheme.sharedInstance.plpNoSearchResultsBoldFont,
                                        range: nsRange)
        }
        
        noResultsTextLabel?.attributedText = attributedText
    }
    
    open func update(withString string: String) {
        // TODO: Track this. It will be in the next product task as part of visual search
        noResultsTextLabel?.text = string
        noResultsTextLabel?.font = AppTheme.sharedInstance.plpNoSearchResultsBoldFont
    }
    
    // MARK: - Private
    fileprivate func commonInit() {
        
        // Assume after this cont view will be populated
        _ = NibInjectionResolver.loadViewFromNib("ProductListNoSearchResultsView", owner: self)
        guard let existedContentView = contentView else {
            Log.error("After loading from nib we must have populated 'contentView'")
            return
        }
        
        self.addSubview(existedContentView)
        
        existedContentView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        existedContentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        existedContentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        existedContentView.translatesAutoresizingMaskIntoConstraints = false
        
        if AppSettings.sharedInstance.showNoSearchResultsIcon {
            iconImageView?.image = ImageInjectionResolver.loadImage(named: "NoSearchResultsIcon")
        } else {
            iconImageViewHeight?.constant = 0
        }
        noResultsTextLabel?.text = nil
        
        var carouselHidden = true
        if AppSettings.sharedInstance.isProductsCarouselOnSearchEnabled, 
            let carouselView: PoqProductsCarouselView = NibInjectionResolver.loadViewFromNib("PoqProductsCarouselView", owner: self) {
            
            addSubview(carouselView)
            
            carouselView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
            
            carouselView.heightAnchor.constraint(equalToConstant: carouselView.intrinsicContentSize.height).isActive = true
            carouselView.translatesAutoresizingMaskIntoConstraints = false
                        
            carouselView.titleLabel?.text = AppLocalization.sharedInstance.productCarousselTitleText
            carouselView.rightDetailButton?.setTitle(AppLocalization.sharedInstance.productCarousselRightButtonText, for: .normal)
            
            carouselView.viewModel = PoqProductsCarouselViewModel(viewedProduct: nil)
            /// Avoid size compression if possible
            carouselView.setContentHuggingPriority(UILayoutPriority.defaultHigh + 1, for: .vertical)
            carouselView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh + 1, for: .vertical)
            
            productsCarouselView = carouselView
            productsCarouselView?.delegate = self
            
            carouselHidden = false
        }
        
        updateConstraints(showRecentlyViewed: !carouselHidden)
        isAccessibilityElement = true
        accessibilityIdentifier = productListNoSearchResultsViewAccessibilityId
    }
    
    // MARK: - Caroussel Delegate
    
    public func productsCarouselViewDidClearItems(_ view: PoqProductsCarouselView) {
        
        view.removeFromSuperview()
        updateConstraints(showRecentlyViewed: false)
    }
    
    // MARK: - Private
    fileprivate func updateConstraints(showRecentlyViewed: Bool) {
        
        guard let contentViewUnwrapped = contentView else {
            return
        }
        
        productsCarouselView?.isHidden = !showRecentlyViewed
        separator?.isHidden = !showRecentlyViewed
        
        if showRecentlyViewed {
            productsCarouselView?.topAnchor.constraint(equalTo: contentViewUnwrapped.bottomAnchor).isActive = true
        } else {
            contentViewUnwrapped.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
}
