//
//  BagView.swift
//  PoqCart
//
//  Created by Balaji Reddy on 24/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import UIKit
import PoqUtilities

/**
    This protocol represents a type that presents a Bag View
 */
public protocol CartViewPresentable: ViewEditable {
    
    var cartViewDelegate: CartPresenter? { get set }
    var isCheckoutEnabled: Bool { get set }
    var isUserLoggedIn: Bool { get set }
    func updateView(with cartViewData: CartViewDataRepresentable?)
    func showErrorView()
    func viewWillDisappear()
}

/**
    This is the concrete platform implementation of the BagViewPresentable protocol
    It presents the Bag View as a TableView to present the Bag items and custom CheckoutPanelView to present the Checkout button, Total and Number of Bag Items
 */
public class CartView: UIView, CartViewPresentable {

    public static let cartContentTableAccessibilityId = "CartContentTable"
    
    var cartContentTable: UITableView
    lazy public var checkoutPanel: (CheckoutPanelViewPresentable & UIView) = CheckoutPanelView(frame: .zero, decorator: CheckoutPanelDecorator())
    lazy public var emptyCartView: (EmptyCartViewPresentable & UIView) = EmptyCartView(frame: .zero)
    
    var cartContentTableDataSource: CartContentTableDataProvidable
    var cartContentTableDelegate: UITableViewDelegate
    
    var refreshControl = UIRefreshControl()
    
    var cartViewData: CartViewDataRepresentable? {
        didSet {
            
            cartContentTableDataSource.content = cartViewData?.contentBlocks
        }
    }
    
    var decorator: CartViewDecoratable?
    
    public var cartViewDelegate: CartPresenter? {
        didSet {
            
            checkoutPanel.delegate = cartViewDelegate
            emptyCartView.delegate = cartViewDelegate
        }
    }
    
    open var isCheckoutEnabled: Bool = false {
        didSet {
            checkoutPanel.isCheckoutEnabled = isCheckoutEnabled
        }
    }
    
    open var isUserLoggedIn: Bool = false {
        didSet {
            checkoutPanel.isUserLoggedIn = isUserLoggedIn
        }
    }
    
    open var inEditMode: Bool = false
    
    fileprivate func setupCartContentTable() {

        cartContentTable.accessibilityIdentifier = CartView.cartContentTableAccessibilityId
        
        cartContentTable.rowHeight = UITableViewAutomaticDimension
        
        // We instantiate an empty view and set it as the table footer view to eliminate separators on empty cells
        // https://stackoverflow.com/questions/1369831/eliminate-extra-separators-below-uitableview
        cartContentTable.tableFooterView = UIView(frame: CGRect.zero)
        
        cartContentTable.rowHeight = UITableViewAutomaticDimension
        cartContentTable.estimatedRowHeight = 190
        cartContentTable.estimatedSectionFooterHeight = 0
        cartContentTable.estimatedSectionHeaderHeight = 0
        cartContentTable.contentInsetAdjustmentBehavior = .never
    }
    
    /// This is the required initialiser for the BagView
    ///
    /// - Parameters:
    ///   - frame: The frame of the UIView
    ///   - decorator: The BagViewDecoratable object the will layout the view
    ///   - cartContentTableDelegate: The UIViewTableDelegate instance for the Bag content table view in Bag View
    ///   - cartContentTableDataSource: The BagContentTableDataProvidable (UITableViewDataSource) instance for the table view in Bag View
    public required init(frame: CGRect, decorator: CartViewDecoratable = CartViewDecorator(), cartContentTableDelegate: UITableViewDelegate, cartContentTableDataSource: CartContentTableDataProvidable) {
        
        cartContentTable = UITableView(frame: CGRect.zero)
        
        self.cartContentTableDelegate = cartContentTableDelegate
        self.cartContentTableDataSource = cartContentTableDataSource
        
        cartContentTable.dataSource = self.cartContentTableDataSource
        cartContentTable.delegate = self.cartContentTableDelegate
    
        self.decorator = decorator
        
        super.init(frame: frame)
        
        setupCartContentTable()
        
        cartContentTable.backgroundView = emptyCartView
        
        hideSubviews()
        
        backgroundColor = UIColor.white
        
        addSubview(cartContentTable)
        addSubview(checkoutPanel)
        
        setupRefresh()
        
        decorator.layout(cartView: self)
    }
    
    private func hideSubviews() {
        
        checkoutPanel.isHidden = true
        cartContentTable.isHidden = true
    }
    
    private func toggleCheckoutPanelVisibility(show: Bool) {
        
        // When showing the checkoutViewPanel, we first want to toggle the constraints of the checkoutPanel to eiter collapse or expand to original height and then adjust internal constraints.
        // And vice-versa. Not doing so will result in Unsatisfiable Constraint error warning
        show ? decorator?.toggleCheckoutPanelHeight(checkoutPanelView: self.checkoutPanel, collapse: !show) : checkoutPanel.toggleInternalHeightConstraints(collapse: !show)
        
        show ? checkoutPanel.toggleInternalHeightConstraints(collapse: !show) : decorator?.toggleCheckoutPanelHeight(checkoutPanelView: self.checkoutPanel, collapse: !show)
        
        checkoutPanel.isHidden = !show
       
    }
    
    open func viewWillDisappear() {
        
        // View has gone to the background. Hide all subviews so we show only the right view on being updated.
        hideSubviews()
        
        // Swipe-To-Delete in progress. Reset.
        if cartContentTable.isEditing, !inEditMode {
            
            cartContentTable.setEditing(false, animated: false)
        }
    }
    
    /// This method sets the view data for the Bag View and updates the view based on it
    ///
    /// - Parameter cartViewData: The view data instance to setup this view
    open func updateView(with cartViewData: CartViewDataRepresentable?) {
        
        cartContentTable.isHidden = false
        
        // We recevied data. End refreshing.
        refreshControl.endRefreshing()
        
        // If Cart is empty and not in edit mode then show empty cart view
        if cartViewData?.contentBlocks.isEmpty != false, !inEditMode {
            
            self.cartViewData = cartViewData
            cartContentTable.reloadData()
            showEmptyCartView(state: .empty)
            return
        }
    
        // Cart is not empty hide emptyCartView and show the other subViews
        emptyCartView.isHidden =  true
        toggleCheckoutPanelVisibility(show: true)
        
        if let numberOfItems = cartViewData?.numberOfCartItems, let total = cartViewData?.total {
            checkoutPanel.setup(numOfItems: numberOfItems, totalPrice: total)
        }
        
        // We don't want to relod the content table if the contentBlocks have not changed
        guard cartViewData?.contentBlocks != self.cartViewData?.contentBlocks else {
            
            return
        }
        
        self.cartViewData = cartViewData
        
        // We don't want to reload the cart when editing is in progress
        if !cartContentTable.isEditing {
            cartContentTableDataSource.registerCells(with: cartContentTable)
            cartContentTable.reloadData()
        }
    }
    
    /// This method updates the edit mode on the Bag View
    ///
    /// - Parameters:
    ///   - editing: A boolean that indicates that the Bag screen is currently in edit mode
    ///   - animate: A boolean that indicates whether the transition to/from edit mode is to be animated
    open func setEditMode(to editing: Bool, animate: Bool) {
        
        // Swipe-to-delete in progress. Toggle back and then set.
        if cartContentTable.isEditing, !inEditMode {
        
            cartContentTable.setEditing(false, animated: false)
        }
        
        inEditMode = editing
        
        checkoutPanel.setEditMode(to: editing, animate: animate)
        
        cartContentTable.setEditing(editing, animated: animate)
        
        cartContentTable.visibleCells.forEach { cell in

            if let editableCell = cell as? ViewEditable {

                editableCell.setEditMode(to: editing, animate: animate)
            }
        }
    }
    
    private func showEmptyCartView(state: EmptyCartState) {
        
        emptyCartView.state = state
        
        toggleCheckoutPanelVisibility(show: false)
        
        emptyCartView.isHidden = false
        emptyCartView.alpha = 0.0
        
        UIView.animate(withDuration: 0.3) {
            
            self.setNeedsLayout()
            self.emptyCartView.alpha = 1.0
        }
    }
    
    open func showErrorView() {
        
        // Set to nil so no cart items are shown and backgroundView(emptyCartView) is visible
        cartViewData = nil
        
        // Reload data to remove any existing cells
        cartContentTable.reloadData()
        
        cartContentTable.isHidden = false
        
        // We recevied data. End refreshing.
        refreshControl.endRefreshing()
        
        showEmptyCartView(state: .error)
    }
    
    open func setupRefresh() {
       
        refreshControl.addTarget(self, action: #selector(refreshCart), for: .valueChanged)
        cartContentTable.refreshControl = refreshControl
    }
    
    @objc open func refreshCart() {
        
        cartViewDelegate?.refresh()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
