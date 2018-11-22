//
//  SheetContainerViewController.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 9/8/17.
//
//

import Foundation
import PoqUtilities
import UIKit

public let SheetScreenEdgeIndent: CGFloat = 8.0
public let SheetActionButtonIndent: CGFloat = 12.0
public let iphoneXBottomAreaPadding: CGFloat = 10.0
public let iphoneXTopAreaPadding: CGFloat = 44.0
public let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

let SheetContainerViewAccessibilityIdentifier = "SheetContainerViewAccessibilityIdentifier"
let SheetNavigationControllerViewAccessibilityIdentifier = "SheetNavigationControllerViewAccessibilityIdentifier"

public protocol SheetContentViewController: AnyObject {

    var containerViewController: SheetContainerViewController? { get set }

    /// Return array of action, will be located under sheet
    var action: SheetContainerViewController.ActionButton? { get }

    /// Should return size of sheet for this view controller
    func calculateSize(for maxSize: CGSize) -> CGSize
}

/// Container view controller. Will have UINavigationCOntoller on it and contolr its sizes
/// Sheet size will depends on result of SheetContentViewController. calculateSize(for:)
/// Every view controller MUST be confirmed to SheetContentViewController
public final class SheetContainerViewController: UIViewController, UIGestureRecognizerDelegate,
                                                 UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {

    public struct ActionButton {
        let text: String
        let action: () -> Void
    }

    public let blurEffect = UIBlurEffect(style: .dark)
    public let blurEffectView = UIVisualEffectView(effect: nil)

    // TODO: with Swift 4 put UIViewController & SheetContentViewController
    public let rootViewController: UIViewController

    public var inSheetNavigationController: UINavigationController?
    public var inSheetNavigationControllerHeightConstraint: NSLayoutConstraint?

    public var inSheetNavigationControllerTopConstraint: NSLayoutConstraint?

    /// Constrains, which applied to sheet when it not presented yet, or for dismissal animation
    public var hiddenStateConstraints = [NSLayoutConstraint]()

    public var actionButtonTopConstraint: NSLayoutConstraint?

    public var tapGestureRecognizer: UITapGestureRecognizer?

    public var sheetCornerRadius = CGFloat(5)

    // TODO: with Swift 4 put UIViewController & SheetContentViewController
    public init(rootViewController: UIViewController) {
        assert(rootViewController is SheetContentViewController, "For proper work every view controller MUST be SheetContentViewController")
        self.rootViewController = rootViewController

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        transitioningDelegate = self
        
        (rootViewController as? SheetContentViewController)?.containerViewController = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        let view = UIView()
        self.view = view

        blurEffectView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(blurEffectView)
        let constraints = NSLayoutConstraint.constraintsForView(blurEffectView, withInsetsInContainer: UIEdgeInsets.zero)
        NSLayoutConstraint.activate(constraints)

        addNavigationController()

        view.accessibilityIdentifier = SheetContainerViewAccessibilityIdentifier
        inSheetNavigationController?.view.accessibilityIdentifier = SheetNavigationControllerViewAccessibilityIdentifier

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerAction(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        self.tapGestureRecognizer = tapGestureRecognizer
    }

    // MARK: - UIViewControllerTransitioningDelegate
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SheetNavigationControllerAnimatedTransition(presenting: true)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SheetNavigationControllerAnimatedTransition(presenting: false)
    }

    // MARK: - UINavigationControllerDelegate

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        guard let sheetContentViewController = viewController as? SheetContentViewController else {
            assert(false, "For proper work every view controller MUST be SheetContentViewController")
            return
        }
        
        sheetContentViewController.containerViewController = self

        if navigationController.viewControllers.count == 1 && !animated {
            /// Looks like initial presentation
            return
        }

        updateUIElements(for: sheetContentViewController)

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        guard let navigationControllerFrame = inSheetNavigationController?.view.frame else {
            Log.error("We have touch, but don't have navigatoin controller")
            return true
        }

        let tapLocation = gestureRecognizer.location(in: view)

        // To avaoid random touch in screen edge area, we detect only tocuhes inside magrings also we will detect touches only on top of navigation controller

        let bottomMargin = view.bounds.size.height - navigationControllerFrame.minY
        let edgesInsets = UIEdgeInsets(top: 0, left: SheetScreenEdgeIndent, bottom: bottomMargin, right: SheetScreenEdgeIndent)
        let validTouchArea = view.bounds.insetRect(with: edgesInsets)
        let res = validTouchArea.contains(tapLocation)

        return res
    }

    /// MARK: - Private

    fileprivate var actionButton: SheetActionButton?

    fileprivate func addNavigationController() {

        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.delegate = self
        navigationController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationController.view)

        navigationController.view.backgroundColor = UIColor.white
        navigationController.view.layer.cornerRadius = sheetCornerRadius
        navigationController.view.layer.masksToBounds = true

        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.backgroundColor = UIColor.clear
        navigationController.isNavigationBarHidden = true

        inSheetNavigationController = navigationController

        // Add action button
        let button = SheetActionButton(frame: CGRect.zero, cornerRadius: sheetCornerRadius)
        view.addSubview(button)

        var buttonTopInset = SheetActionButtonIndent

        // Add padding so button top constraint iphone x displays below edge of screen
        if DeviceType.IS_IPHONE_X {
            buttonTopInset += iphoneXBottomAreaPadding
        }

        actionButtonTopConstraint = navigationController.view.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -buttonTopInset)
        actionButtonTopConstraint?.isActive = true
        view.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        actionButton = button
        actionButton?.accessibilityIdentifier = AccessibilityLabels.lookBookGoToProduct

        // Set initial state and constraints
        if let sheetContentViewController = rootViewController as? SheetContentViewController {
            updateUIElements(for: sheetContentViewController)
        }

        navigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SheetScreenEdgeIndent).isActive = true
        navigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SheetScreenEdgeIndent).isActive = true

        /// Pre-appearence animation constraint

        inSheetNavigationControllerTopConstraint?.isActive = false

        let constraint = navigationController.view.topAnchor.constraint(equalTo: view.bottomAnchor)
        hiddenStateConstraints = [constraint]
        NSLayoutConstraint.activate(hiddenStateConstraints)
    }

    /// Calculate height and top constraints of navigationController
    /// Update buttons for `sheetContentViewController`
    fileprivate func updateUIElements(for sheetContentViewController: SheetContentViewController) {

        let horizontalPadding = 2 * SheetScreenEdgeIndent
        var bottomPadding = SheetScreenEdgeIndent

        if sheetContentViewController.action != nil {
            bottomPadding += (2 * SheetActionButtonIndent) + SheetActionButton.SheetActionButtonHeight
        }
        
        var topPadding: CGFloat = SheetScreenEdgeIndent
        
        // Add 10.0 to bottom padding to avoid home indicator, and add status bar height (44.0) to top padding to avoid notch, just for iPhone X
        if DeviceType.IS_IPHONE_X {
            bottomPadding += iphoneXBottomAreaPadding
            topPadding += iphoneXTopAreaPadding
        }
        
        let verticalPadding = bottomPadding + topPadding

        actionButton?.action = sheetContentViewController.action

        let maxSheetSize = CGSize(width: UIScreen.main.bounds.size.width - horizontalPadding,
                                  height: UIScreen.main.bounds.size.height - verticalPadding)

        var contentSize = sheetContentViewController.calculateSize(for: maxSheetSize)

        // Validate just in case
        if contentSize.height > maxSheetSize.height {
            contentSize.height = maxSheetSize.height
        }

        inSheetNavigationControllerHeightConstraint?.isActive = false
        inSheetNavigationControllerHeightConstraint = inSheetNavigationController?.view.heightAnchor.constraint(equalToConstant: contentSize.height)
        inSheetNavigationControllerHeightConstraint?.isActive = true

        inSheetNavigationControllerTopConstraint?.isActive = false
        let topInset = UIScreen.main.bounds.size.height - contentSize.height - bottomPadding
        inSheetNavigationControllerTopConstraint = inSheetNavigationController?.view.topAnchor.constraint(equalTo: view.topAnchor, constant: topInset)
        inSheetNavigationControllerTopConstraint?.isActive = true
    }

    @objc
    fileprivate func tapGestureRecognizerAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
}
