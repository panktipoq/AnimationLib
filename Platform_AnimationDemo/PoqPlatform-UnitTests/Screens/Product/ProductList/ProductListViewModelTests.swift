//
//  ProductListViewModelTests.swift
//  PoqPlatform-UnitTests
//
//  Created by Rokas Jovaisa on 25/10/2018.
//

import XCTest

@testable import PoqNetworking
@testable import PoqPlatform

class MockProductListViewController: ProductListViewController {
    
    private let expectation: XCTestExpectation
    
    init(with expectation: XCTestExpectation) {
        self.expectation = expectation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        if networkTaskType == PoqNetworkTaskType.productsByCategory ||
            networkTaskType == PoqNetworkTaskType.productsByFilters ||
            networkTaskType == PoqNetworkTaskType.productsByBundle ||
            networkTaskType == PoqNetworkTaskType.productsByQuery {
            
            expectation.fulfill()
        }
    }
    
    override func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        XCTFail("Something wrong with the test setup")
    }
}

class ProductListViewModelTests: XCTestCase {
    
    override var resourcesBundleName: String {
        return "ProductListTests"
    }
    
    func testNonEmptyProducts() {
        MockServer.shared["/products/filter/*"] = response(forJson: "Products")
        
        let productListExpectation = expectation(description: "ProductListExpectation")
        let mockProductListViewController = MockProductListViewController(with: productListExpectation)
        let productListViewModel = ProductListViewModel(viewControllerDelegate: mockProductListViewController)
        
        productListViewModel.getProductsByFilter()
        
        waitForExpectations(timeout: 3) {
            (error: Error?) in
            if error != nil {
                XCTFail("We didn't got response")
            }
        }
        
        XCTAssertEqual(productListViewModel.products.count, 3)
    }
    
    func testEmptyProducts() {
        MockServer.shared["/products/filter/*"] = response(forJson: "Products.Empty")
        
        let productListExpectation = expectation(description: "ProductListExpectation")
        let mockProductListViewController = MockProductListViewController(with: productListExpectation)
        let productListViewModel = ProductListViewModel(viewControllerDelegate: mockProductListViewController)
        
        productListViewModel.getProductsByFilter()
        
        waitForExpectations(timeout: 3) {
            (error: Error?) in
            if error != nil {
                XCTFail("We didn't got response")
            }
        }
        
        XCTAssertEqual(productListViewModel.products.count, 0)
    }
}
