//
//  VisualSearchResultsUnitTests.swift
//  PoqPlatform-UnitTests
//
//  Created by Manuel Marcos Regalado on 03/04/2018.
//

import XCTest
import Foundation
@testable import PoqPlatform

class VisualSearchResultsUnitTests: XCTestCase {
    
    override var resourcesBundleName: String {
        return "VisualSearchResultsUnitTests"
    }
    
    override func setUp() {
        super.setUp()
    }
    
    func testVisualSearchResults() {
        MockServer.shared["visually_similar_products/by_image_upload/*"] = response(forJson: "singleCategoryResults")
        let visualSearchResultsExpectation = expectation(description: "visualSearchResultsExpectation")
        let mockPresenter = VisualSearchResultsPresenterMock(withExpectation: visualSearchResultsExpectation)
        let visualSearchResultsViewModel = VisualSearchResultsViewModel(presenter: mockPresenter)
        
        let bundle = Bundle(for: type(of: self)).path(forResource: resourcesBundleName, ofType: "bundle").flatMap({ Bundle(path: $0) })

        guard let image = UIImage(named: "unitTestRedDress.jpg", in: bundle, compatibleWith: nil) else {
            XCTFail("Couldn't get image")
            return
        }
        visualSearchResultsViewModel.fetchVisualSearchResults(forImage: image)
       
        waitForExpectations(timeout: 3) { (error: Error?) in
            if error != nil {
                XCTFail("We didn't get a response")
            }
        }
        
        print("Products count = \(visualSearchResultsViewModel.products.count)")
        XCTAssertEqual(visualSearchResultsViewModel.products.count, 20)
        XCTAssertEqual(visualSearchResultsViewModel.resultsMode, .singleCategory)
    }
    
    func testVisualSearchMultiCategoryResults() {
        MockServer.shared["visually_similar_products/by_image_upload/*"] = response(forJson: "multiCategoryResults")
        let visualSearchResultsExpectation = expectation(description: "visualSearchResultsExpectation")
        let mockPresenter = VisualSearchResultsPresenterMock(withExpectation: visualSearchResultsExpectation)
        let visualSearchResultsViewModel = VisualSearchResultsViewModel(presenter: mockPresenter)
        
        let bundle = Bundle(for: type(of: self)).path(forResource: resourcesBundleName, ofType: "bundle").flatMap({ Bundle(path: $0) })
        
        guard let image = UIImage(named: "unitTestRedDress.jpg", in: bundle, compatibleWith: nil) else {
            XCTFail("Couldn't get image")
            return
        }
        visualSearchResultsViewModel.fetchVisualSearchResults(forImage: image)
        
        waitForExpectations(timeout: 3) { (error: Error?) in
            if error != nil {
                XCTFail("We didn't get a response")
            }
        }
        
        print("Products count = \(visualSearchResultsViewModel.products.count)")
        XCTAssertEqual(visualSearchResultsViewModel.products.count, 0)
        XCTAssertEqual(visualSearchResultsViewModel.categories.count, 5)
        XCTAssertEqual(visualSearchResultsViewModel.resultsMode, .multipleCategory)
    }
    
    func testVisualSearchNoResults() {
        MockServer.shared["visually_similar_products/by_image_upload/*"] = response(forJson: "noResults")
        let visualSearchResultsExpectation = expectation(description: "noResults")
        let mockPresenter = VisualSearchResultsPresenterMock(withExpectation: visualSearchResultsExpectation)
        let visualSearchResultsViewModel = VisualSearchResultsViewModel(presenter: mockPresenter)
        
        let bundle = Bundle(for: type(of: self)).path(forResource: resourcesBundleName, ofType: "bundle").flatMap({ Bundle(path: $0) })
        
        guard let image = UIImage(named: "unitTestRedDress.jpg", in: bundle, compatibleWith: nil) else {
            XCTFail("Couldn't get image")
            return
        }
        visualSearchResultsViewModel.fetchVisualSearchResults(forImage: image)
        
        waitForExpectations(timeout: 3) { (error: Error?) in
            if error != nil {
                XCTFail("We didn't get a response")
            }
        }
        
        print("Products count = \(visualSearchResultsViewModel.products.count)")
        XCTAssertEqual(visualSearchResultsViewModel.products.count, 0)
        XCTAssertEqual(visualSearchResultsViewModel.resultsMode, .noResults)
    }
    
}
