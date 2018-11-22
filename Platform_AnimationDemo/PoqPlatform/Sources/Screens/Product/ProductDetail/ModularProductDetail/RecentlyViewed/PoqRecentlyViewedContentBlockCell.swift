//
//  PoqRecentlyViewedContentBlockCell.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 3/31/17.
//
//

import Foundation
import PoqNetworking
import UIKit

open class PoqRecentlyViewedContentBlockCell: FullWidthAutoresizedCollectionCell, PoqProductDetailCell, PoqProductsCarouselViewDelegate {

    weak public var presenter: PoqProductBlockPresenter? {
        didSet {
            viewController = presenter as? UIViewController
        }
    }

    open weak var productsCarouselView: PoqProductsCarouselView?
    @IBOutlet weak public var separator: SolidLine?

    weak var viewController: UIViewController? {
        didSet {
            setupPeekView()
        }
    }

    // this constraint will define: collapsed view or not
    fileprivate var constraint: NSLayoutConstraint?

    fileprivate var contentItem: PoqProductDetailContentItem?

    override open func awakeFromNib() {

        super.awakeFromNib()

        guard let productsCarouselView: PoqProductsCarouselView = NibInjectionResolver.loadViewFromNib("PoqProductsCarouselView", owner: self),
            AppSettings.sharedInstance.isProductsCarouselOnPdpEnabled else {
            return
        }

        contentView.addSubview(productsCarouselView)
        productsCarouselView.translatesAutoresizingMaskIntoConstraints = false
        productsCarouselView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        productsCarouselView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        productsCarouselView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

        productsCarouselView.titleLabel?.text = AppLocalization.sharedInstance.productCarousselTitleText
        productsCarouselView.titleLabel?.font = AppTheme.sharedInstance.recentlyViewedCarouselTitleFont
        productsCarouselView.rightDetailButton?.titleLabel?.font = AppTheme.sharedInstance.recentlyViewCarouselDetailTitleFont
        productsCarouselView.rightDetailButton?.setTitle(AppLocalization.sharedInstance.productCarousselRightButtonText, for: .normal)
        productsCarouselView.rightDetailButton?.setTitleColor(AppTheme.sharedInstance.recentlyViewedCarouselDetailTitleColor, for: .normal)

        self.productsCarouselView = productsCarouselView
        self.productsCarouselView?.delegate = self

        updateContentViewConstraint(collapsed: false)

        if let separatorUnwrapped = separator {
            contentView.bringSubview(toFront: separatorUnwrapped)
        }

    }

    // MARK: PoqProductDetailCell

    public func setup(using content: PoqProductDetailContentItem, with product: PoqProduct?) {
        guard let viewModel = (content.cellType as? RecentlyViewedCellTypeProvider)?.service else {
            productsCarouselView?.viewModel = nil
            updateContentViewConstraint(collapsed: true)
            return
        }

        contentItem = content

        if !viewModel.isLoading && viewModel.products.count == 0 {
            updateContentViewConstraint(collapsed: true)
            return
        }

        updateContentViewConstraint(collapsed: false)

        if !isSizingCell {
            productsCarouselView?.viewModel = viewModel
        }

        if let peekDelegate = productsCarouselView?.peekViewDelegate as? ProductPeekViewDelegate {
            peekDelegate.viewModel = viewModel
        }
    }

    // MARK : PoqProductsCarouselDelegate

    public func productsCarouselViewDidClearItems(_ view: PoqProductsCarouselView) {
        updateContentViewConstraint(collapsed: true)
        presenter?.reloadView()

        if !isSizingCell {
            contentItem?.invalidateCellBlock?()
        }

    }

    // MARK: Private
    fileprivate func updateContentViewConstraint(collapsed: Bool) {
        constraint?.isActive = false
        if collapsed {
            constraint = contentView.heightAnchor.constraint(equalToConstant: 0)
        } else {
            constraint = productsCarouselView?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        }
        constraint?.priority = UILayoutPriority(rawValue: 999.0)
        constraint?.isActive = true
        productsCarouselView?.isHidden = collapsed

    }

    fileprivate func setupPeekView() {
        guard let existedViewController = viewController, productsCarouselView?.viewControllerForProductPeek != existedViewController else {
            return
        }
        productsCarouselView?.viewControllerForProductPeek = existedViewController
        productsCarouselView?.createPeekView()
    }
}
