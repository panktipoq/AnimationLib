//
//  VisualSearchResultsService.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 17/03/2018.
//

import Foundation
import PoqNetworking
import PoqAnalytics

/// This is the different modes that this component can adopt
///
/// - singleCategory: This mode indicates that there is only one category in the results
/// - multipleCategory: This mode indicates that there are more than one category in the results
/// - noResults: This mode indicates that there is no results to show
public enum ResultsMode {
    case singleCategory
    case multipleCategory
    case noResults
}

public protocol VisualSearchResultsService: PoqNetworkTaskDelegate, PeekProductsProvider {
    
    var presenter: PoqPresenter? { get set }
    var products: [PoqProduct] { get set }
    var categories: [PoqVisualSearchItem] { get set }
    var resultsMode: ResultsMode { get set }
    var poqVisualSearchItem: PoqVisualSearchItem? { get set }
    
    /// This function will make a request to the API to fetch all similar products for a given image
    ///
    /// - Parameter forImage: The image that will be used to find similar products
    func fetchVisualSearchResults(forImage: UIImage)
    
    /// This function will return a the title of the category if there is one available
    ///
    /// - Returns: The title text of the category
    func categoryTitle() -> String?
    
    /// This function will return the number of items that the model stores depending on the `resultsMode`
    ///
    /// - Returns: This is the number of items
    func numberOfItems() -> Int
}

extension VisualSearchResultsService {
   
    // MARK: - Network Task Callbacks
    
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        presenter?.update(state: .loading, networkTaskType: networkTaskType)
    }
    
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        // Give initial value to `resultsMode`
        resultsMode = .noResults
        var visualSearchResult = VisualSearchResult.unsuccessful
        var numberOfCategories: Int = 0
        if let results = result as? [PoqVisualSearchResult],
            let resultCategories = results.first?.items,
            resultCategories.count > 0 {
            numberOfCategories = resultCategories.count
            if resultCategories.count > 1 {
                visualSearchResult = .successful
                resultsMode = .multipleCategory
                categories = resultCategories
            } else if let category = resultCategories.first,
                let resultProducts = category.products {
                visualSearchResult = .successful
                resultsMode = .singleCategory
                poqVisualSearchItem = category
                products = resultProducts
            }
        }
        PoqTrackerHelper.trackVisualSearchResults(forNumberOfCategories: String(numberOfCategories))
        PoqTrackerV2.shared.visualSearchResults(forResult: visualSearchResult.rawValue, numberOfCategories: numberOfCategories)
        presenter?.update(state: .completed, networkTaskType: networkTaskType)
    }
    
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        PoqTrackerV2.shared.visualSearchResults(forResult: VisualSearchResult.unsuccessful.rawValue, numberOfCategories: 0)
        PoqTrackerHelper.trackVisualSearchResults(forNumberOfCategories: "0")
        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
    }
    
    public func numberOfItems() -> Int {
        switch resultsMode {
        case .singleCategory:
            return products.count
        case .multipleCategory:
            return categories.count
        case .noResults:
            return 0
        }
    }
}
