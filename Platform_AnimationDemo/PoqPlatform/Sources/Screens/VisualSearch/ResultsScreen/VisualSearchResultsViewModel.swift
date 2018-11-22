//
//  VisualSearchResultsViewModel.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 17/03/2018.
//

import Foundation
import PoqNetworking
import PoqUtilities

public class VisualSearchResultsViewModel: VisualSearchResultsService {
    
    public var resultsMode = ResultsMode.noResults
    weak public var presenter: PoqPresenter?
    public var contentBlocks = [PoqPromotionBlock]()
    public var products = [PoqProduct]()
    public var categories = [PoqVisualSearchItem]()
    public var poqVisualSearchItem: PoqVisualSearchItem?

    public init(presenter: PoqPresenter) {
        self.presenter = presenter
    }
    
    public init(poqVisualSearchItem: PoqVisualSearchItem) {
        guard let products = poqVisualSearchItem.products else {
            Log.error("Couldn't get products")
            return
        }
        self.poqVisualSearchItem = poqVisualSearchItem
        self.products = products
        resultsMode = .singleCategory
    }
    
    public func fetchVisualSearchResults(forImage: UIImage) {
        guard let imageRepresentation = UIImageJPEGRepresentation(forImage, 0.7) else {
            Log.error("Couldn't get representation for image")
            return
        }
        let poqMultipartDataPost: PoqMultipartFormDataPost = (parameters: nil, multipartData: imageRepresentation, mimeType: "image/jpg", fileName: "file")
        PoqNetworkService(networkTaskDelegate: self).visuallySimilarProducts(poqMultipartFormDataPost: poqMultipartDataPost)
    }
        
    public func categoryTitle() -> String? {
        return poqVisualSearchItem?.categoryTitle
    }
}
