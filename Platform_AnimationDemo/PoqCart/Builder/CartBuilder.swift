//
//  CartBuilder.swift
//  PoqCart
//
//  Created by Balaji Reddy on 26/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//
import UIKit
import ReSwift

/**
 
    This class is the Builder for a Cart screen.
 
    It provides the default platform dependencies for the Cart screen and constructs the CartViewController.
    It also provides convenience methods to override any of the dependencies to provide a custom implementation
 */
public class CartBuilder {
    
    public typealias CartReducerType = (Action, CartState?) -> CartState
    
    var router: Routable = CartRouter()
    var service: CartDataServiceable = CartDataService(apiClient: PoqCartApiClient(), domainModelMapper: CartDomainModelMapper())
    var viewDataMapper: CartViewDataMappable = CartViewDataMapper()
    var cartReducer: CartReducerType = CartStateReducer.reduceCartState
    lazy var dataSource: CartContentTableDataProvidable = {
            let dataSource = CartContentTableViewDataSource(cellBuilder: cellBuilder)
            dataSource.cellBuilder = cellBuilder
            return dataSource
    }()
    var cellBuilder: CartTableViewCellBuildable = CartTableViewCellBuilder()
    lazy var delegate = CartTableViewDelegate(dataSource: dataSource)
    lazy var cartView: CartViewController.CartViewType = CartView(frame: UIScreen.main.bounds, cartContentTableDelegate: delegate, cartContentTableDataSource: dataSource)
    
    public init() { }
    
    public func withRouter(_ router: Routable) -> Self {
        self.router = router
        return self
    }
    
    public func withService(_ service: CartDataServiceable) -> Self {
        self.service = service
        return self
    }
    
    public func withViewDataMapper(_ viewDataMapper: CartViewDataMappable) -> Self {
        self.viewDataMapper = viewDataMapper
        return self
    }
    
    public func withCartReducer(_ cartReducer: @escaping CartReducerType) -> Self {
        self.cartReducer = cartReducer
        return self
    }
    
    public func withDataSource(_ dataSource: CartContentTableDataProvidable) -> Self {
        self.dataSource = dataSource
        return self
    }
    
    public func withDelegate(_ delegate: CartTableViewDelegate) -> Self {
        self.delegate = delegate
        return self
    }
    
    public func withCellBuilder(_ cellBuilder: CartTableViewCellBuildable) -> Self {
        self.cellBuilder = cellBuilder
        return self
    }

    ///  This method builds the CartViewController with all it's dependencies
    ///
    /// - Parameter shouldShowMoveToWishlistAction: A flag that indicates whether the "Move To Wishlist" action is to be shown when a cart item is swiped
    /// - Returns: The CartViewController instance
    public func build(shouldShowMoveToWishlistAction: Bool = false) -> UIViewController {
        
        delegate.shouldShowMoveToWishlistAction = shouldShowMoveToWishlistAction
        
        let store = Store<CartState>(reducer: cartReducer, state: nil, middleware: [CartAnalyticsMiddleware.trackCartAnalytics])
       
        let cartViewController = CartViewController(store: store, service: service, router: router, viewDataMapper: viewDataMapper, cartView: cartView)
      
        dataSource.delegate = cartViewController
        
        return cartViewController
    }
}
