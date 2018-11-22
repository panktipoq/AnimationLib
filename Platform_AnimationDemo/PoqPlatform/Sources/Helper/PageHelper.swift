//
//  PageHelper.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 19/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities

open class PageHelper {

    final public class func openBanner(_ banner: PoqHomeBanner, viewController: UIViewController?) {
        guard let actionType: PoqPageType = banner.actionType else {
            Log.error("banner.actionType can't be nil")
            return
        }
        // Translate home banner into page
        let page = PoqPage()
        page.id = banner.id
        
        page.pageType = banner.actionType
        page.pageParameter = banner.actionParameter

        if let pageTitle = banner.title, !pageTitle.isNullOrEmpty() {
            page.title = pageTitle
        } else {
            page.title = "None"
        }

        // If banner is a subpage then we need to use actionparameter as page id to load subpages of targeted page
        let pagesRelated: Bool = [PoqPageType.Subpages, PoqPageType.Page].contains(actionType)
        if pagesRelated {
            if let pageParameter = page.pageParameter {
                if let pageId = Int(pageParameter) {
                    page.id = pageId
                }
            }
        }
        
        // IsFrom parameter decides to present as modal
        openPage(page, optionalViewController: viewController, isFromHome: AppSettings.sharedInstance.isSubCategoriesModalPresent)
        
        // Log home action (banner click)
        page.title.flatMap {
            PoqTrackerHelper.trackHomeAction($0)
        }
    }
    
    private class func navigateToStoreList(optionalViewController: UIViewController?) {
        dismissCurrentView(optionalViewController)
        NavigationHelper.sharedInstance.loadStoreList()
    }
    
    private class func navigateToMyStore(optionalViewController: UIViewController?) {
        dismissCurrentView(optionalViewController)
        NavigationHelper.sharedInstance.loadMyStore()
    }
    
    private class func navigateToShop(optionalViewController: UIViewController?) {
        dismissCurrentView(optionalViewController)
        NavigationHelper.sharedInstance.loadShop()
    }
    
    private class func navigateToExternalLink(page: PoqPage, optionalViewController: UIViewController?) {
        page.pageParameter.flatMap { pageParameter in
            optionalViewController.flatMap { viewController in
                if isModal(viewController) {
                    // If the viewController is modal then, dismiss it first.
                    viewController.dismiss(animated: true, completion: {
                        loadExternalLink(urlString: pageParameter)
                    })
                } else {
                    // If it's not modal, then launch the view directly.
                    loadExternalLink(urlString: pageParameter)
                }
            }
        }
    }
    
    private class func navigateToWishList(optionalViewController: UIViewController?) {
        dismissCurrentView(optionalViewController)
        NavigationHelper.sharedInstance.loadWishlist()
    }
    
    private class func navigateToMySizes(optionalViewController: UIViewController?) {
        dismissCurrentView(optionalViewController)
        if let gender = LoginHelper.getAccounDetails()?.gender {
            if gender == GenderType.F.rawValue {
                // User is female, the title will be "My sizes"
                NavigationHelper.sharedInstance.loadMySizes(MySizeType.WOMAN)
            } else {
                // User is male, the title will be "My sizes"
                NavigationHelper.sharedInstance.loadMySizes(MySizeType.MAN)
            }
        } else {
            // User gender is unknown. Default is female
            NavigationHelper.sharedInstance.loadMySizes(MySizeType.WOMAN)
        }
    }
    
    private class func navigateToProductsInCategory(page: PoqPage, optionalViewController: UIViewController?) {
        if let pageParameter = page.pageParameter {
            if let categoryId = Int(pageParameter) {
                // PLP
                dismissCurrentView(optionalViewController)
                NavigationHelper.sharedInstance.loadProductsInCategory(categoryId, categoryTitle: page.title ?? "", brandId: page.brandId, parentCategoryId: page.parentID)
            }
        }
    }
    
    private class func navigateToProductsInBrandedCategory(page: PoqPage, optionalViewController: UIViewController?) {
        if let pageParameter = page.pageParameter {
            if let categoryId = Int(pageParameter) {
                // PLP
                dismissCurrentView(optionalViewController)
                page.title.flatMap {
                    NavigationHelper.sharedInstance.loadProductsInBrandedCategory(categoryId, categoryTitle: $0)
                }
            }
        }
    }

    private class func navigateToCategory(page: PoqPage, optionalViewController: UIViewController?, isFromHome: Bool) {
        if let pageParameter = page.pageParameter {
            if let categoryId = Int(pageParameter) {
                // Push on the top of the modal navigation controller
                page.title.flatMap {
                    NavigationHelper.sharedInstance.loadCategory(categoryId, categoryTitle: $0, topViewController: optionalViewController, isModal: isFromHome)
                }
            }
        }
    }
    
    private class func navigateToLookbook(page: PoqPage, optionalViewController: UIViewController?) {
        if let pageParameter = page.pageParameter {
            if let lookbookId = Int(pageParameter) {
                dismissCurrentView(optionalViewController)
                let title = page.title ?? "Lookbook"
                NavigationHelper.sharedInstance.loadLookbook(lookbookId, title: title)
            }
        }
    }

    private class func navigateToScan(page: PoqPage, optionalViewController: UIViewController?) {
            if let viewController = optionalViewController {
                if isModal(viewController) {
                    // If the viewController is modal then, dismiss it first.
                    viewController.dismiss(animated: true, completion: {
                        NavigationHelper.sharedInstance.loadScan()
                    })
                } else {
                    // If it's not modal, then launch the view directly.
                    NavigationHelper.sharedInstance.loadScan()
                }
            }
    }
    
    final class func openPage(_ page: PoqPage, optionalViewController: UIViewController?, isFromHome: Bool = false) {

        guard let pageType: PoqPageType = page.pageType else {
            Log.error("PageHelper: Page type is missing")
            return
        }
        
        Log.verbose("PageHelper: pageType = \(pageType.rawValue)")
        
        switch pageType {

        case PoqPageType.StoreFinder:
            navigateToStoreList(optionalViewController: optionalViewController)
            
        case PoqPageType.MyStore:
            navigateToMyStore(optionalViewController: optionalViewController)
            
        case PoqPageType.Shop:
            navigateToShop(optionalViewController: optionalViewController)

        case PoqPageType.Link:
            navigateToExternalLink(page: page, optionalViewController: optionalViewController)
            
        case PoqPageType.Wishlist:
            navigateToWishList(optionalViewController: optionalViewController)

        case PoqPageType.MySizes:
            navigateToMySizes(optionalViewController: optionalViewController)
            
        case PoqPageType.Category:
            navigateToProductsInCategory(page: page, optionalViewController: optionalViewController)
            
        case PoqPageType.BrandedCategory:
            navigateToProductsInBrandedCategory(page: page, optionalViewController: optionalViewController)
            
        case PoqPageType.Subcategory:
            navigateToCategory(page: page, optionalViewController: optionalViewController, isFromHome: isFromHome)
            
        case PoqPageType.Lookbook:
            navigateToLookbook(page: page, optionalViewController: optionalViewController)
            
        case PoqPageType.RecentProducts:
            dismissCurrentView(optionalViewController)
            NavigationHelper.sharedInstance.loadRecentlyViewedProducts()
            
        case PoqPageType.Scan:
            navigateToScan(page: page, optionalViewController: optionalViewController)
            
        case PoqPageType.Brands:
            NavigationHelper.sharedInstance.loadBrands(optionalViewController, isModal: isFromHome)
            
        case PoqPageType.Subpages:
            if let identifier = page.id, let title = page.title {
                NavigationHelper.sharedInstance.loadPageList(identifier, parentPageTitle: title, topViewController: optionalViewController, isModal: isFromHome)
            }
            
        case PoqPageType.Page:
            if let identifier = page.id, let title = page.title {
                NavigationHelper.sharedInstance.loadPageDetail(identifier, pageTitle: title)
            }
            
        case PoqPageType.Layar:
            dismissCurrentView(optionalViewController)
            NavigationHelper.sharedInstance.loadLayarViewController(isFromHome)

        default:
            Log.error("Unknown pageTpe = \(pageType)")
        }
    }
    
    open class func loadExternalLink(urlString: String) {
        NavigationHelper.sharedInstance.loadExternalLink(urlString)
    }
    
    final class func dismissCurrentView(_ optionalViewController: UIViewController?) {
        guard let viewController = optionalViewController else {
            Log.warning("optionalViewController is required")
            return
        }
        
        viewController.navigationController?.dismiss(animated: true, completion: nil)
        NavigationHelper.sharedInstance.clearTopMostViewController()
        
        if AppSettings.sharedInstance.showNavMenu && AppSettings.sharedInstance.sideMenuPosition == "right" {
            // NEW HOF requirements switch back to HOME tab
            NavigationHelper.sharedInstance.defaultTabBar?.selectedIndex = Int(AppSettings.sharedInstance.homeTabIndex)
        }
    }
    
    // MARK: - CHECK IF A VIEW IS MODAL
    // http://stackoverflow.com/questions/23620276/check-if-view-controller-is-presented-modally-or-pushed-on-a-navigation-stack
    final class func isModal(_ viewController: UIViewController) -> Bool {
        if viewController.presentingViewController != nil {
            return true
        }
        if viewController.presentingViewController?.presentedViewController == viewController {
            return true
        }
        if viewController.navigationController?.presentingViewController?.presentedViewController == viewController.navigationController {
            return true
        }
        return false
    }
}
