//
//  CartViewController.swift
//  PoqCart
//
//  Created by Balaji Reddy on 21/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import UIKit
import ReSwift
import PoqPlatform
import PoqNetworking
import PoqUtilities

/**
 
    This UIViewController subclass presents the Cart screen
 
    It subscribes to a store the provides communicates updates to the CartState object it stores.
    The view controller reacts to these updates and takes appropriate action.
 
    It relies on protocol abstractions for its dependencies and these can be injected
 */
public class CartViewController: UIViewController, StoreSubscriber, PoqViewStylable {
    
    public typealias CartViewType = (UIView & CartViewPresentable)
    
    public static let cartEditButtonAccessiblityId = "CartEditButton"
    public static let cartCancelEditButtonAccessibilityId = "CartCancelEditButton"
  
    var spinner: PoqSpinner?

    private var store: Store<CartState>
    private var service: CartDataServiceable
    private var router: Routable
    private var viewDataMapper: CartViewDataMappable
    
    public var inEditMode: Bool = false
    
    public var editButton: UIBarButtonItem?
    public var cancelButton: UIBarButtonItem?
    public var testButton: UIButton?
    
    public var cartView: CartViewType
    
    var cartViewData: CartViewDataRepresentable? {
        
        didSet {
            
            // Disable edit button if not in edit mode and cart is empty
            if !inEditMode {
                navigationItem.rightBarButtonItem?.isEnabled = !(cartViewData?.contentBlocks.isEmpty ?? true)
            }
            
            //TODO: We need to fix this BadgeHelper monstrosity
            BadgeHelper.setBadge(for: Int(AppSettings.sharedInstance.shoppingBagTabIndex), value: cartViewData?.numberOfCartItems ?? 0)
            
            cartView.updateView(with: cartViewData)
        }
    }
    
    /// This is a required initialiser for the CartViewController and accepts all its dependencies are parameters
    ///
    /// - Parameters:
    ///   - store: The store object to which this ViewController subscribes to
    ///   - service: The service which provides the ActionCreators to dispatch DataActions to the store
    ///   - router: The router which handles the navigation
    ///   - viewDataMapper: The view data mapper instance which maps the network data to the view data
    ///   - cartView: The cart view instance which acts at the view instance for the view controller
    public required init(store: Store<CartState>, service: CartDataServiceable, router: Routable, viewDataMapper: CartViewDataMappable, cartView: CartViewType) {
        
        self.store = store
        self.service = service
        self.router = router
        self.viewDataMapper = viewDataMapper
        
        self.cartView = cartView
        
        super.init(nibName: nil, bundle: nil)
        
        self.cartView.cartViewDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {

        view = cartView
    }
    
    /// This method sets up the navigation bar by adding the bar buttons, targets and styles the navigation bar
    open func setupNavigationBar() {
        
        editButton = UIBarButtonItem.borderedButtonItem(target: self, selector: #selector(toggleEditMode))
        editButton?.borderedButtonItemTitle = "Edit"
        editButton?.accessibilityIdentifier = CartViewController.cartEditButtonAccessiblityId

        navigationItem.rightBarButtonItem = editButton
        
        cancelButton = UIBarButtonItem.borderedButtonItem(target: self, selector: #selector(cancelEdit))
        cancelButton?.borderedButtonItemTitle = "Cancel"
        cancelButton?.accessibilityIdentifier = CartViewController.cartCancelEditButtonAccessibilityId

        styleNavigationBar()
    }
    
    /// This method displays the loading indicator
    open func displaySpinner() {
        
        if spinner == nil {
            spinner = PoqSpinner()
        }
        
        spinner?.frame.size = CGSize(width: 44, height: 44)
        spinner?.center = view.center
        if let spinner = spinner {
            view.addSubview(spinner)
        }
        spinner?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        spinner?.startAnimating()
    }

    func removeSpinner() {
        
        spinner?.stopAnimating()
        spinner?.removeFromSuperview()
        spinner = nil
    }
    
    // MARK: - Actions
    @objc func toggleEditMode() {
        
        // If in editMode and user taps on "Done" post cart data else enable edit mode
        inEditMode ? store.dispatch(service.postCart) : store.dispatch(CartPresenterAction.toggleEditMode)
    }
    
    @objc func cancelEdit() {
        
        store.dispatch(CartPresenterAction.cancelEdit)
    }

    // MARK: - Presentation
    
    /// This method displays the error alert
    ///
    /// - Parameter errorMessage: The error message to be displayed
    open func showError(errorTitle: String, errorMessage: String, actions: [UIAlertAction]) {
        
        let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
       
        actions.forEach {
            alertController.addAction($0)
        }
        
        present(alertController, animated: true)
    }
    
    open func setEditMode(to editMode: Bool) {
        
        inEditMode = editMode
        
        cartView.setEditMode(to: editMode, animate: true)
        editButton?.borderedButtonItemTitle = editMode ? "Done" : "Edit"

        navigationItem.leftBarButtonItem = editMode ? cancelButton : nil
    }
    
    // MARK: - View Controller Delegates
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        store.subscribe(self)
        
        // Set Login Status
        toggleLoginStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLoginStatus), name: NSNotification.Name(rawValue: PoqUserDidLoginNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLoginStatus), name: NSNotification.Name(rawValue: PoqUserDidLogoutNotification), object: nil)
        
        updateCheckoutType()
        
        setupNavigationBar()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        store.dispatch(service.getCart)
        
        super.viewWillAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        
        store.dispatch(CartPresenterAction.goToBackground)
    }
    
    /// This method displays an appropriate error message on the Cart screen based on the error provided
    ///
    /// - Parameter error: The error value to display a message for
    open func showCartError(_ error: Error) {
        
        switch error {
            
        case is NetworkError:
       
            let errorTitle = inEditMode ? "ERROR_UPDATING_CART".localizedPoqString : "CART_ERROR_TITLE".localizedPoqString
            
            var actions = [UIAlertAction]()
            
            if inEditMode {
                
                let okAction = UIAlertAction(title: "DISMISS".localizedPoqString, style: .default)
                
                actions.append(okAction)
                
                let retryAction = UIAlertAction(title: "RETRY".localizedPoqString, style: .default) { action in
                    
                    self.store.dispatch(self.service.postCart)
                }
                
                actions.append(retryAction)
                
            } else {

                let okAction = UIAlertAction(title: "OK".localizedPoqString, style: .default) { _ in

                    self.cartViewData = nil
                    self.cartView.showErrorView()
                }
                
                actions.append(okAction)
            }
            
            showError(errorTitle: errorTitle, errorMessage: error.localizedDescription, actions: actions)
            
        case is CartError:
            
            if case CartError.outOfStockItemInCart = error {
            
                let okAction = UIAlertAction(title: "OK".localizedPoqString, style: .default)
                showError(errorTitle: "OUT_OF_STOCK_ERROR_TITLE".localizedPoqString, errorMessage: error.localizedDescription, actions: [okAction])
            }
            
        default:
           
            let okAction = UIAlertAction(title: "OK", style: .default)
            showError(errorTitle: "CART_ERROR_TITLE".localizedPoqString, errorMessage: error.localizedDescription, actions: [okAction])
 
        }
        
    }
    
    /// This method reacts to the updates in View state
    ///
    /// - Parameter viewState: the updated view state instance
    open func handle(state: CartState) {

        switch state.viewState.screenState {
            
        case .awaitingInteraction:
            
            cartView.isUserInteractionEnabled = true
            
            if spinner != nil {
                removeSpinner()
            }
            
            // If we have an error. Show error and return.
            if let error = state.dataState.error {
                
                showCartError(error)
                
                return
            }
            
            // If edit mode state has changed then update view accordingly.
            if inEditMode != state.viewState.inEditMode {
                
                setEditMode(to: state.viewState.inEditMode)
            }
            
            // Not in editMode but cart edited. Swipe-To-Delete -> PostCart
            if !inEditMode, state.dataState.editedCart != nil {
                
                store.dispatch(service.postCart)
            }
            
            //TODO: Separate network model and domain model
            cartViewData = viewDataMapper.mapToViewData(state.dataState.editedCart ?? state.dataState.cart)
            
        case .loading:

            cartView.isUserInteractionEnabled = false
            displaySpinner()
            
        case .background:
            
            cartView.viewWillDisappear()
            
        case .navigateTo(let route):
            
            router.route(to: route)
        }
        
        // Enable cancel button if cart has been edited
        cancelButton?.isEnabled = state.dataState.editedCart != nil
        
        cartView.isCheckoutEnabled = state.viewState.isCheckoutEnabled
        cartView.isUserLoggedIn = state.viewState.userLoggedIn
    }
    
    /// This method is called by the Store when ther is a state update
    ///
    /// - Parameter state: The updated state object
    public func newState(state: CartState) {
        
        handle(state: state)
    }
    
    /// This method toggles the user login status
    /// It is called on viewDidLoad and is subscribed to login and logout notification
    @objc public func toggleLoginStatus() {
        
        store.dispatch(CartPresenterAction.setLoginStatus(userLoggedIn: LoginHelper.isLoggedIn()))
    }
    
    public func updateCheckoutType() {
        
        if let checkoutType = CartType(rawValue: Int(AppSettings.sharedInstance.checkoutBagType)) {
        
            store.dispatch(CartPresenterAction.setCheckoutType(checkoutType: checkoutType))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CartViewController: CartCellPresenter {
    
    /// This method dispatches an action to indicate that the quantity of a cart item has been updated
    ///
    /// - Parameters:
    ///   - cartItemId: The id of the cart item that has been updated
    ///   - quantity: The quantity the cart item has been updated to
    open func updateQuantity(of cartItemId: String, to quantity: Int) {
        store.dispatch(CartPresenterAction.updateQuantity(id: cartItemId, quantity: quantity))
    }
    
    /// This method dispatches an action to indicate that a cart item has been deleted
    ///
    /// - Parameter id: The id of the cart item deleted
    open func deleteCartItem(id: String) {
        
        store.dispatch(CartPresenterAction.deleteCartItem(id: id))
    }
    
    /// This method dispatches an intent to the store that the user has tapped on a cart item
    ///
    /// - Parameter id: The id of the cart item that has been tapped on
    open func didTapOnCartItem(id: String) {
        
        store.dispatch({ state, _ in
            
            let cartItem = state.dataState.cart.cartItems.first(where: { $0.id == id })
            
            guard
                let productId = cartItem?.productId
                else {
                    assertionFailure("No product id or external product id in product.")
                    return nil
            }
            
            return CartPresenterAction.tapOnCartItem(productId: productId, externalProductId: cartItem?.externalProductId)
        })
    }
    
    /// This method dispatches an intent to the store that a cart item is to be moved to the wishlist
    ///
    /// - Parameter id: The id of the cart item
    open func wishlistItem(id: String) {
      
        store.dispatch({ state, _ in
        
            let cartItem = state.dataState.cart.cartItems.first(where: { $0.id == id })
            
            guard let productId = cartItem?.productId, let price = cartItem?.price, let productTitle = cartItem?.productTitle  else {
                assertionFailure("No cart data in state")
                return nil
            }
            
            // TODO: Refactor WishlistHelper and provide a better implementation here
            // We shouldn't be sending a nil action here
            let product = PoqProduct()
            product.id = productId.toInt()
            if let wasPrice = cartItem?.wasPrice {
                product.price = Double(truncating: wasPrice as NSNumber)
            }
            product.specialPrice = Double(truncating: price as NSNumber)
            product.title = productTitle
            
            if !(product.id.flatMap { WishlistController.shared.isFavorite(productId: $0) } ?? false) {
                WishlistController.shared.add(product: product)
            }
            
            return nil
        })
    }
}

extension CartViewController: CartPresenter {
    
    public func checkoutButtonTapped() {
        
        store.dispatch(CartPresenterAction.goToCheckout)
    }
    
    public func startShoppingButtonTapped() {
        
        store.dispatch(CartPresenterAction.goToShop)
    }
    
    public func refresh() {
        
        store.dispatch(service.getCart)
    }
}
