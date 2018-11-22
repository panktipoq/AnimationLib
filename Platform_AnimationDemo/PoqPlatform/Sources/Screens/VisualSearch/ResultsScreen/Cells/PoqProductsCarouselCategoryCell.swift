//
//  PoqProductsCarouselCategoryCell.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 12/04/2018.
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics

/**
 `PoqProductsCarouselCategoryCell` will be just a cell container that displays the PoqProductsCarouselView.
 1.- This first thing that this cell will do is to set up the PoqProductsCarouselView inside the cell view
 2.- The setup function will be triggered from the `cellForItemAt` presenter and it will populate the cell's info
 */
open class PoqProductsCarouselCategoryCell: FullWidthAutoresizedCollectionCell {
    
    weak var poqProductsCarouselView: PoqProductsCarouselView?
    weak var presenter: VisualSearchResultsPresenter?
    var category: PoqVisualSearchItem?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initPoqProductsCarouselView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initPoqProductsCarouselView()
    }
    
    open func initPoqProductsCarouselView() {
        if poqProductsCarouselView == nil,
            let carouselView: PoqProductsCarouselView = NibInjectionResolver.loadViewFromNib("PoqProductsCarouselView", owner: self) {
            // 1.- Add the view
            addSubview(carouselView)
            // 2.- Add the constraints
            carouselView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
            carouselView.heightAnchor.constraint(equalToConstant: carouselView.intrinsicContentSize.height).isActive = true
            carouselView.translatesAutoresizingMaskIntoConstraints = false
            carouselView.setContentHuggingPriority(UILayoutPriority.defaultHigh + 1, for: .vertical)
            carouselView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh + 1, for: .vertical)
            // 3.- Remove ALL previous targets that might have been added through Interface builder etc etc
            carouselView.rightDetailButton?.removeTarget(nil, action: nil, for: .allEvents)
            // 4.- Add our own target
            carouselView.rightDetailButton?.addTarget(self, action: #selector(viewAllProducts), for: UIControlEvents.touchUpInside)
            // 5.- Set the source to be the carousel from visual search
            carouselView.viewProductAnalyticsSource = ViewProductSource.visualSearch.rawValue
            poqProductsCarouselView = carouselView
        }
    }
    
    open func setup(with category: PoqVisualSearchItem) {
        self.category = category
        if let products = category.products,
            poqProductsCarouselView?.viewModel == nil {
            poqProductsCarouselView?.viewModel = PoqProductsCarouselViewModel(products: products)
            poqProductsCarouselView?.titleLabel?.text = category.categoryTitle
            poqProductsCarouselView?.rightDetailButton?.setTitle(AppLocalization.sharedInstance.productCarousselRightButtonText, for: .normal)
            poqProductsCarouselView?.viewControllerForProductPeek = presenter as? UIViewController
            poqProductsCarouselView?.createPeekView()
        }
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        category = nil
        poqProductsCarouselView?.viewModel = nil
        poqProductsCarouselView?.peekViewDelegate = nil
    }
    
    /// This function will be triggered when the user taps on the `viewAll` button on top of the category
    @objc open func viewAllProducts() {
        guard let categoryUnwrapped = category else {
            Log.error("Could not load all products because there isn't a category")
            return
        }
        presenter?.viewAllProducts(for: categoryUnwrapped)
    }
        
    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        var frame = attributes.frame
        frame.size.width = UIScreen.main.bounds.width
        frame.size.height = poqProductsCarouselView?.intrinsicContentSize.height ?? 0
        attributes.frame = frame
        return attributes
    }
}
