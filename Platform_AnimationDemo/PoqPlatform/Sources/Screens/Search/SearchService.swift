//
//  SearchService.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/27/17.
//
//

import BoltsSwift
import Foundation
import PoqNetworking
import PoqUtilities

public typealias SearchHistoryTaskResult = [SearchHistoryItem]

private let classicSearchHistoryAlreadyMigratedKey = "HistoryAlreadyMigrated"

public enum SearchContentType {
    case searchHistory
    case suggestedSearch
    case typedSearch
}

public struct SearchContent {
    
    public let type: SearchContentType
    
    // It MUST be a thread detached
    public let result: PoqSearchResult?
    
    public let historyItem: SearchHistoryItem?
    
    public init(result: PoqSearchResult) {
        self.type = .suggestedSearch
        self.result = result
        self.historyItem = nil
    }
    
    public init(historyItem: SearchHistoryItem, type: SearchContentType = .searchHistory) {
        self.type = type
        self.result = nil
        self.historyItem = historyItem
    }
}

public struct SearchHeader {
    
    let text: String?
    let showClearButton: Bool // Clear search history, not result

    static let emptySearchHistory = SearchHeader(text: AppLocalization.sharedInstance.noSearchHistoryText, showClearButton: false)
    
    static let searchHistoryHeader = SearchHeader(text: AppLocalization.sharedInstance.searchHistoryText, showClearButton: true)
    
    static let searchResultsHeader = SearchHeader(text: AppLocalization.sharedInstance.searchResultHeaderText, showClearButton: false)
}

public protocol SearchService: PoqNetworkTaskDelegate {
    
    weak var presenter: SearchPresenter? { get }
    
    var contents: [SearchContent] { get set }
    
    var queryOperation: PoqOperation? { get set }

    /// We will asynchronously request history, so we need chance to close it
    /// Modify this varable only on main thread
    var historyFetchingTaskSource: TaskCompletionSource<SearchHistoryTaskResult>? { get set }
    
    /// Start network task  ot fetch data, if other task in progress - it will be cancelled
    func fetchSuggestions(for query: String)
    
    /// Generate 'contents' with history or 'No result' content
    func generateEmptyQueryContents()
    
    /// Parse response from API and convert to 'contents'
    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?)
    
    /// If this is search result, than we will save it as category id type
    /// If this is existed history, we will update it in order of items
    func save(searchContent: SearchContent)

    /// If user press 'Search' button and we need save query, create 'SearchContent' as with query
    func save(query: String) -> SearchHistoryItem
    
    /// Clear search history, triggered reset contents to empty
    func clearSearchHistory()
}

extension SearchService {
    
    public func fetchSuggestions(for query: String) {
        cancelFetch()
        
        contents = contents.filter { !($0.historyItem != nil && $0.type == .typedSearch) }
        var searchHistoryItem = SearchHistoryItem()
        searchHistoryItem.keyword = query
        searchHistoryItem.typeRawValue = SearcHistoryItemType.keyword.rawValue
        contents.insert(SearchContent(historyItem: searchHistoryItem, type: .typedSearch), at: 0)
        
        queryOperation = PoqNetworkService(networkTaskDelegate: self).predictiveSerch(query)
    }
    
    func cancelFetch() {
        queryOperation?.cancel()
        queryOperation = nil

        presenter?.update(state: .completed, networkTaskType: PoqNetworkTaskType.getPredictiveSearch)
    }
    
    public func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        guard let searchResponse = result?.first as? PoqSearchResponse else {
            Log.error("")
            return
        }
        
        historyFetchingTaskSource?.tryCancel()
        var newContents = [SearchContent]()
        
        if let existedResults = searchResponse.results {
            for result in existedResults {
                newContents.append(SearchContent(result: result))
            }
        }
        
        presenter?.headerview?.searchHeader = SearchHeader.searchResultsHeader
        
        contents = contents.filter { $0.historyItem != nil && $0.type == .typedSearch }
        contents.append(contentsOf: newContents)
    }
    
    public func generateEmptyQueryContents() {

        historyFetchingTaskSource?.tryCancel()
        historyFetchingTaskSource = fetchExistedHistory()
        
        historyFetchingTaskSource?.task.continueOnSuccessWith(Executor.mainThread, continuation: { [weak self] (history: SearchHistoryTaskResult) in
            
            var newContents = [SearchContent]()
            
            for result in history {
                newContents.append(SearchContent(historyItem: result))
            }
            
            self?.presenter?.headerview?.searchHeader = newContents.count > 0 ? SearchHeader.searchHistoryHeader : SearchHeader.emptySearchHistory
            self?.contents = newContents
        })
    }
    
    public func save(searchContent: SearchContent) {
        
        var historyItem: SearchHistoryItem?
        
        switch searchContent.type {
        case .searchHistory, .typedSearch:
            historyItem = searchContent.historyItem
            
        case .suggestedSearch:
            guard let categoryIdString = searchContent.result?.categoryId, let categoryId = Int(categoryIdString) else {
                Log.error("Can't save SearchContent with type .searchResult without string with int in SearchContent.result?.categoryId")
                break
            }
            historyItem = SearchHistoryItem()
            historyItem?.typeRawValue = SearcHistoryItemType.categoryId.rawValue
            historyItem?.categoryId = categoryId
            historyItem?.title = searchContent.result?.title
            historyItem?.parentCategoryId = searchContent.result?.parentCategoryId
            historyItem?.parentCategoryTitle = searchContent.result?.parentCategoryTitle
        }
        
        saveIfNotExisting(newSearchItem: historyItem)
    }

    public func save(query: String) -> SearchHistoryItem {

        var res = SearchHistoryItem()
        res.keyword = query
        saveIfNotExisting(newSearchItem: res)
        return res
    }
    
    func saveIfNotExisting(newSearchItem: SearchHistoryItem?) {
        let currentSearchHistory = fetchExistedHistory()
        
        currentSearchHistory.task.continueOnSuccessWith(Executor.mainThread, continuation: { (history: SearchHistoryTaskResult) in
            
            guard let newSearchItem = newSearchItem else {
                return
            }
            
            var searchHistoryItem = history.first(where: { self.itemsMatch(newSearchItem, historicalItem: $0) }) ?? newSearchItem
            // Update the date of saving so it will appear at the top of the previuos searches
            searchHistoryItem.date = Date()
            self.asyncSave(historyItem: searchHistoryItem)
        })
    }
    
    func itemsMatch(_ newSearchItem: SearchHistoryItem, historicalItem: SearchHistoryItem) -> Bool {
        if let newItemCategory = newSearchItem.categoryId, newItemCategory == historicalItem.categoryId, newSearchItem.parentCategoryId == historicalItem.parentCategoryId {
            return true
        }
        
        if let newSearchKeyword = newSearchItem.keyword, let historicalSearchKeyword = historicalItem.keyword {
            return newSearchKeyword == historicalSearchKeyword
        }
        
        return false
    }
    
    // MARK: - PoqNetworkTaskDelegate

    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        presenter?.update(state: .loading, networkTaskType: networkTaskType)
    }
    
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {

        parseResponse(networkTaskType, result: result)
        presenter?.update(state: .completed, networkTaskType: networkTaskType)
        queryOperation = nil
    }

    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
        queryOperation = nil
    }

    public func clearSearchHistory() {

        historyFetchingTaskSource?.tryCancel()
        historyFetchingTaskSource = createClearSearchHistoryTask()
        
        historyFetchingTaskSource?.task.continueOnSuccessWith(Executor.mainThread, continuation: {
            [weak self]
            (history: SearchHistoryTaskResult) in
            
            self?.presenter?.headerview?.searchHeader = SearchHeader.emptySearchHistory
            self?.contents = [SearchContent]()
        })
    }
    
    /// We will try keep hostory from classic search. We will take all existed history and push it into new storage/format
    func migrateClassicHistoryIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: classicSearchHistoryAlreadyMigratedKey) else {
            // We won't migrate twice
            return
        }
        
        let existedKeywords = SearchHelper.getSearchKeywordHistory()
        for keyword in existedKeywords {
            _ = save(query: keyword)
        }
        
        UserDefaults.standard.set(true, forKey: classicSearchHistoryAlreadyMigratedKey)
    }

    // MARK: - Private
    
    fileprivate func asyncSave(historyItem: SearchHistoryItem?) {
        guard let existedHistoryItem = historyItem else {
            Log.error("Unable to get/create item for saving")
            return
        }
        PoqDataStore.store?.create(existedHistoryItem, maxCount: maxNumberOfHistoryItems, completion: nil)
    }
    
    fileprivate func fetchExistedHistory() -> TaskCompletionSource<SearchHistoryTaskResult> {
        let taskSource = TaskCompletionSource<SearchHistoryTaskResult>()
        PoqDataStore.store?.getAll { (results: [SearchHistoryItem]) in
            var taskResult = SearchHistoryTaskResult()
            let maxItems = results.count > maxNumberOfHistoryItems ? maxNumberOfHistoryItems : results.count
            for index in 0..<maxItems {
                taskResult.append(results[index])
            }
            taskSource.trySet(result: taskResult)
        }
        return taskSource
    }
    
    fileprivate func createClearSearchHistoryTask() -> TaskCompletionSource<SearchHistoryTaskResult> {
        let taskSource = TaskCompletionSource<SearchHistoryTaskResult>()
        PoqDataStore.store?.deleteAll(forObjectType: SearchHistoryItem(), completion: nil)
        taskSource.trySet(result: [])
        return taskSource
    }
}
