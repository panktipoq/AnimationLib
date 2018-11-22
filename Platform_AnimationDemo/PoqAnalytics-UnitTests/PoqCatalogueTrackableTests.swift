//
//  PoqCatalogueTrackableTests.swift
//  PoqAnalytics-UnitTests
//
//  Created by Rachel McGreevy on 1/23/18.
//

import XCTest
import PoqPlatform
import PoqNetworking
@testable import PoqAnalytics
@testable import PoqPlatform

class PoqCatalogueTrackableTests: EventTrackingTestCase {
    
    func testViewProductTracking() {
        
        PoqTrackerV2.shared.viewProduct(productId: 12345, productTitle: "Blue Jeans", source: "PLP")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testViewProductListTracking() {
        
        PoqTrackerV2.shared.viewProductList(categoryId: 12345, categoryTitle: "New In", parentCategoryId: 23456)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testViewSearchResultsTracking() {
        
        PoqTrackerV2.shared.viewSearchResults(keyword: "Dress", type: "predictive", result: "successful")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAddToBagTracking() {
        
        PoqTrackerV2.shared.addToBag(quantity: 1, productId: 12345, productTitle: "Blue Jeans", productPrice: 14.99, currency: "USD")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAddToWishlistTracking() {
        
        PoqTrackerV2.shared.addToWishlist(quantity: 1, productTitle: "Blue Jeans", productId: 12345, productPrice: 14.99, currency: "USD")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testShareTracking() {
        
        PoqTrackerV2.shared.share(productId: 12345, productTitle: "Blue Jeans")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testBarcodeScanTracking() {
        
        PoqTrackerV2.shared.barcodeScan(type: "scan", result: "successful", ean: "12345", productId: 12345, productTitle: "Blue Jeans")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testSortProductsTracking() {
        
        PoqTrackerV2.shared.sortProducts(type: "featured")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testFilterProductsTracking() {
        
        PoqTrackerV2.shared.filterProducts(type: "static", colors: "Black;Blue", categories: "Dresses", sizes: "10;12;14", brands: "brandName", styles: "styleName", minPrice: 10, maxPrice: 50)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testPeekAndPopTracking() {
        
        PoqTrackerV2.shared.peekAndPop(action: "viewDetails", productId: 12345, productTitle: "Blue Jeans")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testFullScreenImageViewTracking() {
        
        PoqTrackerV2.shared.fullScreenImageView(productId: 12345, productTitle: "Blue Jeans")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testReadReviewsTracking() {
        
        PoqTrackerV2.shared.readReviews(productId: 12345, numberOfReviews: 16)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testVideoPlayTracking() {
        
        PoqTrackerV2.shared.videoPlay(productId: 12345, productTitle: "Blue Jeans")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    /// MARK: - Tests to confirm custom provider recieves calls from code
    
    func testViewProductEventTracked() {
        
        NavigationHelper.sharedInstance.loadProduct(12345, externalId: "23456", source: "PDP", productTitle: "Blue Jeans")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testViewProductListEventTracked() {
        
        NavigationHelper.sharedInstance.loadProductsInCategory(123, categoryTitle: "New In", parentCategoryId: 345)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testViewSearchResultsEventTracked() {
        
        let predictiveSearchView = SearchViewController(nibName: "SearchView", bundle: nil)
        let searchContent = SearchContent(result: PoqSearchResult())
        searchContent.result?.title = "testQuery"
        predictiveSearchView.openDetails(for: searchContent)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAddToBagEventTracked() {
        
        let product = PoqProductSize()
        product.id = 12345
        BagHelper.logAddToBag("Blue Jeans", productSize: product)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testShareEventTracked() {
        
        let pdp = ProductDetailViewController(nibName: "ProductDetailView", bundle: nil)
        pdp.shareDidComplete(.postToFacebook, completed: true, returnedItems: nil, error: nil)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testFilterProductsEventTracked() {
        
        let filtersViewController = ProductListFiltersController(nibName: "ProductsListFiltersView", bundle: nil)
        filtersViewController.logAppliedFilters()
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testPeekAndPopEventTracked() {
        let peekViewController = ProductListViewPeek(nibName: "ProductListViewPeek", bundle: nil)
        peekViewController.product = PoqProduct()
        peekViewController.product?.id = 12345
        peekViewController.product?.title = "Blue Jeans"
        _ = peekViewController.view
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testFullScreenImageViewEventTracked() {
        
        let modularPDP = ModularProductDetailViewController(nibName: "ModularProductDetailView", bundle: nil)
        modularPDP.service.product = PoqProduct()
        let productPicture = PoqProductPicture()
        productPicture.url = "www.testImageUrl.com"
        modularPDP.service.product?.productPictures = [productPicture, productPicture]
        modularPDP.service.product?.title = "Blue Jeans"
        modularPDP.imageDidTap(at: IndexPath(row: 0, section: 0), forImageView: PoqAsyncImageView(frame: CGRect.zero))
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testReadReviewsEventTracked() {
        
        let reviewController = ReviewsViewController(nibName: "ReviewsViewController", bundle: nil)
        reviewController.productId = 12345
        _ = reviewController.view
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testVideoPlayEventTracked() {
        let modularPDP = ModularProductDetailViewController(nibName: "ModularProductDetailView", bundle: nil)
        modularPDP.service.product = PoqProduct()
        modularPDP.service.product?.videoURL = "www.testvideourl.com/video.mp4"
        modularPDP.videoDidTap()
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
