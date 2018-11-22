//
//  VisualSearchResultsTests.swift
//  PoqDemoApp-EGTests
//
//  Created by Manuel Marcos Regalado on 05/04/2018.
//

import EarlGrey
import XCTest

@testable import PoqPlatform
@testable import PoqAnalytics

class VisualSearchResultsTests: EGTestCase {
    var visualSearchResultsListViewController: VisualSearchResultsListViewController?
    var viewModel: VisualSearchResultsViewModel?
    
    func insertVisualSearchResultsListViewController() {
        let bundle = Bundle(for: type(of: self)).path(forResource: "VisualSearchResultsTests", ofType: "bundle").flatMap({ Bundle(path: $0) })
        guard let image = UIImage(named: "uiTestRedDress.jpg", in: bundle, compatibleWith: nil) else {
            XCTFail("Couldn't get image")
            return
        }
        let poqVisualSearchImageAnalyticsData = PoqVisualSearchImageAnalyticsData(source: VisualSearchImageSource.camera, crop: true)
        visualSearchResultsListViewController = VisualSearchResultsListViewController(image: image, imageAnalyticsData: poqVisualSearchImageAnalyticsData)
        guard let visualSearchResultsListViewControllerUnwrapped = visualSearchResultsListViewController else {
            XCTFail("Couldn't get Visual Search View Controller")
            return
        }
        let visualSearchResultsViewModel = VisualSearchResultsViewModel(presenter: visualSearchResultsListViewControllerUnwrapped)
        visualSearchResultsListViewControllerUnwrapped.viewModel = visualSearchResultsViewModel
        insertNavigationController(withViewController: visualSearchResultsListViewControllerUnwrapped)
        viewModel = visualSearchResultsViewModel
        
        // Wait for animations to complete
        wait(forDuration: 4)
    }
    
    func testFirstProductExistsInProductList() {
        MockServer.shared["visually_similar_products/by_image_upload/*"] = response(forJson: "singleCategoryResults")
        insertVisualSearchResultsListViewController()
        guard let viewModelUnwrapped = viewModel,
            let firstProductTitle = viewModelUnwrapped.products.first?.title else {
            GREYFail("Could not get the title of the first product from response. Check Mock")
            return
        }
        GREYAssert(assertViewModel(forProducts: 20))
        GREYAssert(assertViewControllerCollectionView(forCellsCount: 20))
        EarlGrey.elementExists(with: grey_text(firstProductTitle))
    }
    
    func testLastProductExistsInProductList() {
        MockServer.shared["visually_similar_products/by_image_upload/*"] = response(forJson: "singleCategoryResults")
        insertVisualSearchResultsListViewController()
        EarlGrey.selectElement(with: grey_kindOfClass(ProductListViewCell.self)).atIndex(2).perform(grey_swipeFastInDirection(.up))
        wait(forDuration: 0.4)
        
        guard let viewModelUnwrapped = viewModel,
            let lastProductTitle = viewModelUnwrapped.products.last?.title else {
                GREYFail("Could not get the title of the last product from response. Check Mock")
                return
        }
        GREYAssert(assertViewModel(forProducts: 20))
        GREYAssert(assertViewControllerCollectionView(forCellsCount: 20))
        EarlGrey.elementExists(with: grey_text(lastProductTitle))
    }
    
    func testNoResults() {
        MockServer.shared["visually_similar_products/by_image_upload/*"] = response(forJson: "noResults")
        insertVisualSearchResultsListViewController()
        
        GREYAssert(assertViewModel(forProducts: 0))
        GREYAssert(assertViewControllerCollectionView(forCellsCount: 0))
        let noResultsView = GREYMatchers.matcher(forAccessibilityID: productListNoSearchResultsViewAccessibilityId)
        EarlGrey.elementExists(with: noResultsView)
    }
    
    func testFirstCategoryExistsInCategoryList() {
        MockServer.shared["visually_similar_products/by_image_upload/*"] = response(forJson: "multiCategoryResults")
        insertVisualSearchResultsListViewController()
        guard let viewModelUnwrapped = viewModel,
            let firstCategoryProductTitle = viewModelUnwrapped.categories.first?.products?.first?.title else {
                GREYFail("Could not get the title of the first product from response. Check Mock")
                return
        }
        GREYAssert(assertViewModel(forCategories: 5))
        GREYAssert(assertViewControllerCollectionView(forCellsCount: 5))
        EarlGrey.elementExists(with: grey_text(firstCategoryProductTitle))
    }
    
    func testLastProductExistsInCategoryList() {
        MockServer.shared["visually_similar_products/by_image_upload/*"] = response(forJson: "multiCategoryResults")
        insertVisualSearchResultsListViewController()
        let scrollViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchResultsListViewController.visualSearchResultsCollectionViewAccessibilityId)
        EarlGrey.elementExists(with: scrollViewMatcher)
        EarlGrey.selectElement(with: scrollViewMatcher).perform(grey_swipeFastInDirection(.up))
        
        guard let viewModelUnwrapped = viewModel,
            let lastCategoryTitle = viewModelUnwrapped.categories.last?.categoryTitle else {
                GREYFail("Could not get the title of the last product from response. Check Mock")
                return
        }
        GREYAssert(lastCategoryTitle == "female/shoes")
        GREYAssert(assertViewModel(forCategories: 5))
        GREYAssert(assertViewControllerCollectionView(forCellsCount: 5))
        EarlGrey.elementExists(with: grey_text(lastCategoryTitle))
    }
    
    func testCategoryTitle() {
        MockServer.shared["visually_similar_products/by_image_upload/*"] = response(forJson: "singleCategoryResults")
        insertVisualSearchResultsListViewController()
        guard let visualSearchResultsListViewControllerUnwrapped = visualSearchResultsListViewController else {
            GREYFail("Could not get the View Controller")
            return
        }
        GREYAssert(visualSearchResultsListViewControllerUnwrapped.navigationItem.title == "female/dresses")        
    }

    // MARK: - Helper
    
    func assertViewModel(forProducts productsCount: Int) -> Bool {
        guard let viewModelUnwrapped = viewModel,
            viewModelUnwrapped.products.count == productsCount else {
                return false
        }
        return true
    }
    
    func assertViewModel(forCategories categoriesCount: Int) -> Bool {
        guard let viewModelUnwrapped = viewModel,
            viewModelUnwrapped.categories.count == categoriesCount else {
                return false
        }
        return true
    }
    
    func assertViewControllerCollectionView(forCellsCount: Int) -> Bool {
        guard let visualSearchResultsListViewControllerUnwrapped = visualSearchResultsListViewController,
        visualSearchResultsListViewControllerUnwrapped.collectionView?.numberOfItems(inSection: 0) == forCellsCount else {
            return false
        }
        return true
    }
}
