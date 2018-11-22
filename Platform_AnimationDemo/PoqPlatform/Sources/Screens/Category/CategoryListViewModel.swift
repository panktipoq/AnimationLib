//
//  CategoryListViewModel.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/19/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

/// The category list view model is one
open class CategoryListViewModel: BaseViewModel {
   
    // ______________________________________________________
    
    // MARK: - Initializers
    
    /// The category objects
    open var categories: [PoqCategory]
    
    /// The selected categoryu
    open var selectedCategory:PoqCategory?

    
    /// Initializes the view model with the views controller delegate TODO: Move this to the presenter approach in future versions
    ///
    /// - Parameter viewControllerDelegate: The view controller delegate used as a presenter for the resulted operations
    override init(viewControllerDelegate:PoqBaseViewController) {
        
        self.categories = []
        
        super.init(viewControllerDelegate: viewControllerDelegate)
    }

    // ______________________________________________________
    
    // MARK: - Basic network tasks\
    
    /// Retrieves the category objects via a network request
    func getCategories(){
        
        PoqNetworkService(networkTaskDelegate: self).getMainCategories()
    }
    
    /// Returns the subcategories
    ///
    /// - Parameters:
    ///   - categoryId: The category id of the parent category
    ///   - isRefresh: Wether this request should kill the cache and request updated data
    func getSubCategories(_ categoryId: Int, isRefresh: Bool = false){
        
        let brandName: String? = viewControllerDelegate?.poqNavigationController?.brandStory?.brandName
        PoqNetworkService(networkTaskDelegate: self).getSubCategories(categoryId, isRefresh: isRefresh, brandName: brandName)
        
    }
    
    // MARK: - get brands
    
    /// Returns the brands data
    ///
    /// - Parameter isRefresh: Wether this request should kill the cache and request updated data
    func getBrands(isRefresh: Bool = false) {
        
        PoqNetworkService(networkTaskDelegate: self).getBrands(isRefresh)
        
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
    Callback before start of the async network task
    */
    
    /// Called when a network task type starts
    ///
    /// - Parameter networkTaskType: The type of the network task that started
    override open func networkTaskWillStart(_ networkTaskType:PoqNetworkTaskTypeProvider) {

        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /**
    Callback after async network task is completed
    */
    
    /// Called when a network task type has completed
    ///
    /// - Parameters:
    ///   - networkTaskType: The network task type that completed
    ///   - result: The result from the request completion
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {

        
        // Call super to hide activity indicator
        // Send empty result list for avoind memory issues
        super.networkTaskDidComplete(networkTaskType,result:[])
        
        let isCategoriesResponse: Bool = networkTaskType == PoqNetworkTaskType.categories ||  networkTaskType == PoqNetworkTaskType.brands

        if let existedResults: [PoqCategory] = result as? [PoqCategory], isCategoriesResponse {
            categories = existedResults
        }
        
        // Send back network request result to view controller
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
        
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    
    /// Called when a network request failed
    ///
    /// - Parameters:
    ///   - networkTaskType: The network task type that failed
    ///   - error: The acompanying error of the request failure
    override open func networkTaskDidFail(_ networkTaskType:PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
    
    // MARK: - Brands
    
    /// Returns an array of the category letters used for quick navigation
    ///
    /// - Returns: The array of letters for quick navigation
    func getCategoryLetters() ->  [String]{
        
        var letters:[String] = []
        for i in 0 ..< categories.count {
            let category = categories[i]
            let title:String =  category.title! as String
            let titleLetter:String = title[0]
            if !letters.contains(titleLetter.lowercased()) {
                
                letters.append(titleLetter.lowercased())
                
            }
        }
        
        // alphabetize
        letters.sort(by: { $0 < $1 })
        
        return letters
    }
    
    /// Adds a category object containing a header
    func addHeaderImage() {
        let category = PoqCategory()
        category.title = ShopViewTableHeaderCell.poqReuseIdentifier
        categories.insert(category, at: 0)
    }
}
