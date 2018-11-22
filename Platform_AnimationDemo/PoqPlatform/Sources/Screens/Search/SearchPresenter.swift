//
//  SearchPresenter.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/23/17.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics

public protocol SearchCell {
    func update(using contentItem: SearchContent)
}

public protocol SearchPresenter: PoqPresenter, SearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    
    var viewModel: SearchService { get }
    weak var collectionView: UICollectionView? { get }
    
    // Header view
    weak var headerview: SearchHeaderView? { get }
    
    /// Register all needed cell classes with collectionView
    func setupCollectionView()
    
    /// This func won't setaup action, in default implementation. Do it in nib
    func setupClearButton()
    
    /// Open detail, after item selection of 'Search button pressed'
    func openDetails(for searchContent: SearchContent)
    func registerCells()
}

extension SearchPresenter where Self: PoqBaseViewController {
    
    // Override 'error' and 'timeout' funcs, to prevent alerts on search
    public func error(_ networkError: NSError?) {
        removeSpinnerView()
    }
    
    public func setupCollectionView() {
        registerCells()
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        }
    }
    
    public func setupClearButton() {
        
        let height: CGFloat = 24
        let heightConstraint = headerview?.clearButton?.heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.priority = UILayoutPriority(rawValue: 999.0)
        heightConstraint?.isActive = true
        
        if let borderedButton = headerview?.clearButton as? BorderedButton {
            
            borderedButton.tintColor = AppTheme.sharedInstance.searchHistoryClearButtonSelectedBackgroundColor
            
            let colorPerState: [UIControlState: UIColor] = [.normal: AppTheme.sharedInstance.searchHistoryClearButtonColor,
                                                            .highlighted: AppTheme.sharedInstance.searchHistoryClearButtonSelectedColor]
            borderedButton.colorPerState = colorPerState
            
            borderedButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0.2 * height, bottom: 0, right: 0.2 * height)
            
            borderedButton.sizeToFit()
        }
    }
}
