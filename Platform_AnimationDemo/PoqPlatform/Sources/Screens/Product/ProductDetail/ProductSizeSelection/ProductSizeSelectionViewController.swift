//
//  ProductSizeSelectionViewController.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 2/10/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import PoqUtilities
import UIKit

open class ProductSizeSelectionViewController: PoqBaseViewController, SheetContentViewController {

    public weak var containerViewController: SheetContainerViewController?

    public var action: SheetContainerViewController.ActionButton? {
        return nil
    }

    @IBOutlet public weak var sizeSelectorContainer: UIView?
    @IBOutlet public var sizeSelectorHiddenConstraint: NSLayoutConstraint?
    @IBOutlet var sizeSelectorBottomConstraint: NSLayoutConstraint?
    
    @IBOutlet open weak var sizeSelectorTable: UITableView? {
        didSet {
            sizeSelectorTable?.registerPoqCells(cellClasses: [ProductSizeTableViewCell.self, ProductColorsViewCell.self])
        }
    }

    @IBOutlet public var tableHeightConstraint: NSLayoutConstraint?

    public final var sizes: [PoqProductSize]? = []
    open var product: PoqProduct?
    open weak var sizeSelectionDelegate: SizeSelectionDelegate?

    public let rowHeight: CGFloat = 44.00
    var initialLoad = false

    public var sizeSectionPosition: Int = 1
    public var colorSectionRows: Int = 0

    open var viewModel: ProductDetailViewModel?

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateHeight()

        if let productColors = product?.productColors, productColors.count > 1 {
            sizeSectionPosition = 2
            colorSectionRows = 1
            viewModel = ProductDetailViewModel(viewControllerDelegate: self)
            viewModel?.product = product
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AppSettings.sharedInstance.pdpSizeSelectorType == ProductSizeSelectorType.sheet.rawValue {
            sizeSelectorBottomConstraint?.isActive = false
            sizeSelectorBottomConstraint = sizeSelectorTable?.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            sizeSelectorBottomConstraint?.isActive = true
            sizeSelectorHiddenConstraint?.isActive = false
        } else {
            animateTo(hidden: false)
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.backgroundColor = .clear
        UIApplication.shared.statusBarStyle = .default
    }

    // Tap outside to dismiss the view
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }

    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        if  networkTaskType == PoqNetworkTaskType.productDetails {
            sizes = viewModel?.product?.productSizes
            animateTo(hidden: true)
            sizeSelectorTable?.reloadData()
        }
    }

    public func calculateSize(for maxSize: CGSize) -> CGSize {
        let rows = sizes?.count ?? 0 + sizeSectionPosition + colorSectionRows
        var sizeSelectorHeight = CGFloat(1 + rows)  * rowHeight
        
        // Restrict the size of the selector to be 2/3 of the screen so it can't fill more than a specified amount of the screen allowing users to tap outside the cell to exit without selecting a size.
        // This same component is also used by AppStories, so maxSize.height can not be changed in origin
        let twoThirds = UIScreen.main.bounds.size.height * 0.66
        if sizeSelectorHeight > twoThirds {
            sizeSelectorHeight = twoThirds
        }
        
        return CGSize(width: maxSize.width, height: min(sizeSelectorHeight, maxSize.height))
    }

    open func updateHeight() {
        let rows = sizes?.count ?? 0 + sizeSectionPosition + colorSectionRows
        var height = CGFloat(1 + rows) * rowHeight
        
        if containerViewController == nil {

            // Max height that table view can have
            let validHeight = UIScreen.main.bounds.size.height * 2 / 3

            if height > validHeight {
                height = validHeight
            }
        } else {
            if height > view.bounds.height {
                height = view.bounds.height - topLayoutGuide.length
            }
        }

        tableHeightConstraint?.constant = height
    }

    private func animateTo(hidden: Bool) {
        sizeSelectorHiddenConstraint?.isActive = hidden

        let backgroundColor = UIColor(white: 0, alpha: hidden ? 0.5 : 0)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.view.backgroundColor = backgroundColor
        }
    }
}

// MARK: - TableView Delegate

extension ProductSizeSelectionViewController: UITableViewDelegate {

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let labelText = section == sizeSectionPosition - 1 ? AppLocalization.sharedInstance.pdpSelectSizeHeaderText : AppLocalization.sharedInstance.pdpSelectColorHeaderText
        let sizeSelectorHeader = SizeSelectorHeader(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: rowHeight), headerTitle: labelText)
        sizeSelectorHeader.delegate = self
        sizeSelectorHeader.backgroundColor = UIColor.white
        return sizeSelectorHeader
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return rowHeight
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let selectedSize = sizes?[indexPath.row] else {
            Log.error("Selected size not in size array")
            return
        }

        switch AppSettings.sharedInstance.pdpSizeSelectorType {

        case ProductSizeSelectorType.sheet.rawValue:

            self.containerViewController?.dismiss(animated: true) {
                self.sizeSelectionDelegate?.handleSizeSelection(for: selectedSize)
            }

        case ProductSizeSelectorType.classic.rawValue:

            self.tableHeightConstraint?.constant = 0

            UIView.animate(withDuration: 0.3, animations: {[unowned self] () in

                self.view.layoutIfNeeded()

                }, completion: { [unowned self] (_) in

                    self.dismiss(animated: true, completion: { () in
                        self.sizeSelectionDelegate?.handleSizeSelection(for: selectedSize)
                    })
                    return
                }
            )

        default:
            break
        }
    }

    // Remove the weird animation for view cell labels flying to the middle
    // http://stackoverflow.com/questions/30692417/layoutifneeded-affecting-table-view-cells
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        UIView.performWithoutAnimation { () in
            cell.layoutIfNeeded()
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return rowHeight
    }
}

// MARK: - TableView DataSource
extension ProductSizeSelectionViewController: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return sizeSectionPosition
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section != sizeSectionPosition - 1 {
            return 1
        }

        // Crashlytics fix: https://crashlytics.com/poq-studio/ios/apps/com.poqstudio.houseoffraser-dev/issues/553a64905141dcfd8f90cd01
        if let sizes = self.sizes {
            return sizes.count
        }

        return 0
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == sizeSectionPosition - 1 {

            let cell: ProductSizeTableViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)

            guard let productSize = sizes?[indexPath.row] else {

                return cell
            }

            cell.setup(using: productSize)

            return cell
        }

        return viewModel?.getCellForColor(tableView, indexPath: indexPath, delegate: self) ?? UITableViewCell()
    }
}

// MARK: - Product Colors Delegate
extension ProductSizeSelectionViewController: ProductColorsDelegate {
    
    public func colorSelected(_ selectedColor: String, productId: Int, externalId: String, selectedColorProductId: Int?) {
        viewModel?.product = product
        viewModel?.product?.color = selectedColor
        viewModel?.getProduct(productId, externalId: externalId)
    }
}

// MARK: - SizeSelectorHeaderDelegate

extension ProductSizeSelectionViewController: SizeSelectorHeaderDelegate {
    
    func closeButtonTapped() {
        if let containerViewControllerUnwrapped = containerViewController {
            containerViewControllerUnwrapped.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
