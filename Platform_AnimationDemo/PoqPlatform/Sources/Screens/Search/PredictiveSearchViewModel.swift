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

public class PredictiveSearchViewModel: SearchService {
    
    weak public var presenter: SearchPresenter?
    
    public var historyFetchingTaskSource: TaskCompletionSource<SearchHistoryTaskResult>?
    
    public var contents = [SearchContent]() {
        didSet {
            presenter?.collectionView?.reloadData()
            presenter?.collectionView?.collectionViewLayout.invalidateLayout()
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
}
