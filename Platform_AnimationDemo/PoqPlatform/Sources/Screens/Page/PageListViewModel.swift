//
//  PageListViewModel.swift
//  Poq.iOS
//
//  Created by Huishan Loh on 06/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

public typealias PagesSection = (header: PoqPage?, pages: [PoqPage], separator: PoqPage?)

open class PageListViewModel : BaseViewModel {
   
    // ______________________________________________________
    
    // MARK: - Initializers
    var pages: [PoqPage] = [] {
        didSet {
            _groupedPages = PageListViewModel.createSectionsFromPages(pages)
        }
    }
    
    // we use tuple to present pages section. Usual section is header, pages, separator
    // always synced with _groupedPages
    fileprivate var _groupedPages: [PagesSection] = []
    open var groupedPages: [PagesSection] {
        return _groupedPages
    }
    
    override init(viewControllerDelegate: PoqBaseViewController) {
        
        super.init(viewControllerDelegate: viewControllerDelegate)
    }

    // ______________________________________________________
    
    // MARK: - Basic network tasks
    
    func getPages(_ pageId: Int, isRefresh: Bool = false) {
 
        PoqNetworkService(networkTaskDelegate: self).getPages(pageId, isRefresh: isRefresh)

    }
    
    // ______________________________________________________
    
    // MARK: - Grouping tables
    class func createSectionsFromPages(_ pages: [PoqPage]) -> [PagesSection] {
        var res: [PagesSection] = []
        // sections can be separated by header or by separator
        let separatorTypes: [PoqPageType] = [PoqPageType.Header, PoqPageType.Separator]
        var queue: [PoqPage] = pages
        repeat {
            var separator: PoqPage?
            var section: [PoqPage]
            
            var header: PoqPage?
            if queue.first?.pageType == PoqPageType.Header {
                header = queue[0]
                queue = Array<PoqPage>(queue[1..<queue.count])
            }
            
            let deviderIndex: Int? = queue.index(where: {
                (page: PoqPage) -> Bool in
                guard let type: PoqPageType = page.pageType else {
                    return false
                }
                
                return separatorTypes.contains(type)
            })
            
            if let index = deviderIndex {
                let deviderPage: PoqPage = queue[index]
                
                // nwxt header should be excluded from this section, it will start next one
                if deviderPage.pageType == PoqPageType.Header {
                    section = Array<PoqPage>(queue[0..<index])
                    queue = index == (queue.count - 1) ? [] :
                        //we have to go till queue, count
                        Array<PoqPage>(queue[index ..< queue.count])
                    
                } else {
                    // separator
                    section = Array<PoqPage>(queue[0 ..< index])
                    separator = queue[index]
                    queue = index == queue.count - 1 ? [] : Array<PoqPage>(queue[index+1 ..< queue.count])
                }
            } else {
                // we didn't any devider, so rest of queue is section
                section = Array<PoqPage>(queue[0 ..< queue.count])
                queue = []
            }
            
            res.append(PagesSection(header: header, pages:section, separator: separator))
            
        } while(queue.count > 0)
        
        return res
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
    Callback before start of the async network task
    */
    override open func networkTaskWillStart(_ networkTaskType:PoqNetworkTaskTypeProvider){
        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /**
    Callback after async network task is completed
    */
    override open func networkTaskDidComplete(_ networkTaskType:PoqNetworkTaskTypeProvider, result: [Any]?){
        
        // Call super to hide activity indicator
        // Send empty result list for avoiding memory issues
        super.networkTaskDidComplete(networkTaskType,result:[])
        
        if let existedPages: [PoqPage] = result as? [PoqPage], networkTaskType == PoqNetworkTaskType.pageDetails || networkTaskType == PoqNetworkTaskType.pages {
            
            self.pages = existedPages
            
            if self.pages.count == 1 {
                
                if let subpages = self.pages[0].subPages {
                    if subpages.count != 0 {
                        self.pages = subpages
                    }
                }
            }
        }

        // Send back network request result to view controller
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    override open func networkTaskDidFail(_ networkTaskType:PoqNetworkTaskTypeProvider, error: NSError?){
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }

}


