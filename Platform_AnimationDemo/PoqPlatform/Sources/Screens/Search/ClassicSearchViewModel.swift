//
//  SearchViewModel.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/27/17.
//
//

import BoltsSwift
import Foundation
import PoqNetworking

public class ClassicSearchViewModel: SearchService {
    
    public weak var presenter: SearchPresenter?
    
    public var historyFetchingTaskSource: TaskCompletionSource<SearchHistoryTaskResult>?
    
    private var filteredContents = [SearchContent]() {
        didSet {
            presenter?.collectionView?.reloadData()
            presenter?.collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    public var contents: [SearchContent] {
        get {
            return filteredContents
        }
        set {
            filteredContents = newValue.filter({ $0.historyItem?.type == .keyword })
        }
    }

    public var queryOperation: PoqOperation?
    
    public convenience init(presenter: SearchPresenter) {
        self.init()
        self.presenter = presenter
    }
    
    init() {
        migrateClassicHistoryIfNeeded()
    }
    
    public func fetchSuggestions(for query: String) {
        // Nothing in the classic search scenario to do
    }
}
