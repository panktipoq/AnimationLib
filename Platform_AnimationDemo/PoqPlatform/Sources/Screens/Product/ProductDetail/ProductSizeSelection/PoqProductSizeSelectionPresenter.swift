//
//  PoqProductSizeSelectionPresenter.swift
//  Poq.iOS.Platform
//
//  Created by Balaji Reddy on 18/05/2017.
//
//

import Foundation
import PoqNetworking

public protocol PoqProductSizeSelectionPresenter: AnyObject {
    var sizeSelectionTransitioningDelegate: UIViewControllerTransitioningDelegate? { get set }
    func showSizeSelector(using product: PoqProduct)
    var sizeSelectionDelegate: SizeSelectionDelegate? { get }
}

public protocol SizeSelectionDelegate: AnyObject {
    func handleSizeSelection(for size: PoqProductSize)
}

extension PoqProductSizeSelectionPresenter where Self: UIViewController {

    public func showSizeSelector(using product: PoqProduct) {

        switch AppSettings.sharedInstance.pdpSizeSelectorType {

        case ProductSizeSelectorType.sheet.rawValue:

            NavigationHelper.sharedInstance.displaySizeSelector(for: product, delegate: sizeSelectionDelegate)

        case ProductSizeSelectorType.classic.rawValue:

            let productSizeSelectionViewController = ProductSizeSelectionViewController(nibName: "ProductSizeSelectionViewController", bundle: nil)

            productSizeSelectionViewController.sizeSelectionDelegate = sizeSelectionDelegate
            productSizeSelectionViewController.sizes = product.productSizes

            productSizeSelectionViewController.modalPresentationStyle = .custom
            sizeSelectionTransitioningDelegate = ModalTransitionAnimator(withModalViewController: productSizeSelectionViewController)

            if let modalTransitionDelegate = sizeSelectionTransitioningDelegate as? ModalTransitionAnimator {
                modalTransitionDelegate.isDragable = true
                modalTransitionDelegate.behindViewAlpha = AppSettings.sharedInstance.pdpSizeSelectorBehindViewAlpha
                modalTransitionDelegate.behindViewScale = 0.9
                modalTransitionDelegate.transitionDuration = 0.3
                modalTransitionDelegate.direction = .bottom
                modalTransitionDelegate.setContentScrollView(productSizeSelectionViewController.sizeSelectorTable)
            }

            productSizeSelectionViewController.transitioningDelegate = sizeSelectionTransitioningDelegate

            self.present(productSizeSelectionViewController, animated: true, completion: nil)

        default:
            break

        }
    }
}
