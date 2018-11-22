//
//  ShopViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 27/05/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

public class ShopViewModel: BaseViewModel {
    
    // ______________________________________________________
    
    // MARK: - Initializers
    var categories: [PoqCategory]
    
    var firstRun = true
    
    override init(viewControllerDelegate: PoqBaseViewController) {
        
        self.categories = []
        
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network tasks
    public func getCategories(_ isRefresh: Bool = false) {
        
        firstRun = isRefresh
        PoqNetworkService(networkTaskDelegate: self).getMainCategories(isRefresh)
    }
    
    public func getSubCategories(_ categoryId: Int) {
        
        PoqNetworkService(networkTaskDelegate: self).getSubCategories(categoryId)
        
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
    Callback before start of the async network task
    */
    override public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if firstRun {
            
            // Call super to show activity indicator
            super.networkTaskWillStart(networkTaskType)
            firstRun = false
        }
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /**
    Callback after async network task is completed
    */
    override public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Call super to hide activity indicator
        // Send empty result list for avoind memory issues
        super.networkTaskDidComplete(networkTaskType, result:[])
        
        if result != nil {
            
            if networkTaskType == PoqNetworkTaskType.categories {
                
                categories = result! as! [PoqCategory]
            }
        }
        
        // Send back network request result to view controller
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
        
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    override public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }

}

// Different states of the cell
public enum AccordionTableCellStatus {
    case `init`
    case open
    case closed
    case detail
    case loading
}

public class AccordionTableViewCategory {
    public var level: Int = 0
    public var status: AccordionTableCellStatus = .init
    public var levelChildren: [AccordionTableViewCategory] = []
    
    required public init() {}
    
    /// Cenvenience function to set the category to open.
    public func open() {
        status = .open
    }
    
    /// Cenvenience function to set the category and all subcategories to closed.
    public func close() {
        if status == .open {
            status = .closed
        }
        
        levelChildren.forEach({ $0.close() })
    }
}

public class ShopViewCategory {
    
    public var id: Int = 0
    public var name: String = ""
    public var picture: String = ""
    public var deeplinkUrl: String?
    public var parentCategoryId: Int?
    
    public var isHeader = false
    public var type = ShopViewTableCellType.default
    public var cellType = AccordionTableViewCategory()
    
    public var hasSubCategories = false {
        didSet {
            if hasSubCategories {
                cellType.status = .closed
            }
        }
    }
    
    public var children: [ShopViewCategory] = []
    
    public init(id: Int, name: String, hasSubCategories: Bool, picture: String = "", deeplinkUrl: String?, parentCategoryId: Int? = 0) {
        self.id = id
        self.name = name
        self.picture = picture
        self.parentCategoryId = parentCategoryId
        self.deeplinkUrl = deeplinkUrl
        self.hasSubCategories = hasSubCategories
    }
    
    public convenience init?(category: PoqCategory) {
        guard let id = category.id, let name = category.title, let hasSubCategories = category.hasSubCategory else {
            return nil
        }
        
        self.init(id: id, name: name, hasSubCategories: hasSubCategories, picture: category.thumbnailUrl ?? "", deeplinkUrl: category.deeplinkUrl, parentCategoryId: category.parentCategoryId)
    }
    
}
