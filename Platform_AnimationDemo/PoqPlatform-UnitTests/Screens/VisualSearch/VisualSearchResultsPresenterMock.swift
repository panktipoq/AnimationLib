//
//  VisualSearchResultsPresenterMock.swift
//  PoqPlatform-UnitTests
//
//  Created by Manuel Marcos Regalado on 20/04/2018.
//

import Foundation
import XCTest
@testable import PoqPlatform
@testable import PoqNetworking

class VisualSearchResultsPresenterMock: NSObject, VisualSearchResultsPresenter, ViewOwner {
    
    var collectionView: UICollectionView?
    var viewControllerForProductPeek: UIViewController?
    lazy public var viewModel: VisualSearchResultsService = VisualSearchResultsViewModel(presenter: self)
    let expectation: XCTestExpectation
    var view: UIView! = UIView()

    func viewAllProducts(for category: PoqVisualSearchItem) {
        // This is method is to adhere protocol. It is defined by `VisualSearchResultsPresenter`
    }
    
    init(withExpectation expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        XCTAssert(Thread.isMainThread, "Should be called only on main thread, since will make some UI work")
        if networkTaskType == PoqNetworkTaskType.productsVisualSearch {
            expectation.fulfill()
        }
    }
    
    func showErrorMessage(_ networkError: NSError?) {
        XCTFail("We had an error in the request")
    }
    
    func setCellRegistration() {
        // This is method is to adhere protocol. It is defined by `VisualSearchResultsPresenter`
    }

    func initNavigationBar() {
        // This is method is to adhere protocol. It is defined by `VisualSearchResultsPresenter`
    }
    
    func setNavigationBarTitle(_ title: String) {
        // This is method is to adhere protocol. It is defined by `VisualSearchResultsPresenter`
    }
    
    func shouldShowNoSearchResultViews(_ show: Bool) {
        // This is method is to adhere protocol. It is defined by `VisualSearchResultsPresenter`
    }
    
    func displayResults(for mode: ResultsMode) {
        // This is method is to adhere protocol. It is defined by `VisualSearchResultsPresenter`
    }
    
    func cell(for mode: ResultsMode, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // This is method is to adhere protocol. It is defined by `VisualSearchResultsPresenter`
        return UICollectionViewCell()
    }
}
