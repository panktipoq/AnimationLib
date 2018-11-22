//
//  VisualSearchResultsPresenter.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 11/04/2018.
//

import Foundation
import PoqNetworking

/**
 `VisualSearchResultsPresenter` defines the design of the View Controller. These are the functions that a controller should implement in order to support the results screen. The main responsabilities of this delegate are:
 * PoqPresenter: This is the main presenter for our view controllers. It mainly containts logic for triggering updates from the networking layer
 * ProductListPresenter: This presenter brings us the posibility of updating the favorite button if somewhere else was favorited/unfavorited.
 * ProductPeekPresenter: This presenter gives us the logic for peek and pop gesture on products
 */
public protocol VisualSearchResultsPresenter: PoqPresenter, ProductListPresenter, ProductPeekPresenter {
    
    var collectionView: UICollectionView? { get }
    var viewModel: VisualSearchResultsService { get }
    
    func initNavigationBar()
    
    /// Registers the cells with the collection view.
    func setCellRegistration()
    
    /// This function sets the navigation bar title text with a given title
    ///
    /// - Parameter title: The title to be used in the navigation bar title text
    func setNavigationBarTitle(_ title: String)
    
    /// This function will hidde or show the no results view depending on a Boolean parameters given
    ///
    /// - Parameter show: This Boolean will determine whether to show the no results view or not
    func shouldShowNoSearchResultViews(_ show: Bool)
    
    /// This function will display whatever results we received from the network with a given mode
    ///
    /// - Parameter mode: The given results display mode
    func displayResults(for mode: ResultsMode)
    
    /// This function will return the appropiate cell depending on a result display mode for a given collection view and indexpath
    ///
    /// - Parameters:
    ///   - mode: The given results display mode
    ///   - collectionView: The presenter collection view
    ///   - indexPath: The indexpath for the item
    /// - Returns: It will return a different cel depending on the Mode that this function is given
    func cell(for mode: ResultsMode, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    
    /// This function will display all products from a given category and will navigate to a PLP screen
    ///
    /// - Parameter category: The given category with its title and its products
    func viewAllProducts(for category: PoqVisualSearchItem)
}
