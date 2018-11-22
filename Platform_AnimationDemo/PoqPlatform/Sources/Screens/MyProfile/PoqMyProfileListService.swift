//
//  PoqMyProfileListService.swift
//  Poq.iOS.HollandAndBarrett
//
//  Created by Gabriel Sabiescu on 20/01/2017.
//
//

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit
import PoqNetworking
import PoqUtilities
import UIKit

public protocol PoqMyProfileListService: PoqNetworkTaskDelegate {
    
    typealias CheckoutItemType = PoqCheckoutItem<PoqBagItem>
   
    //MARK :- properties
    var presenter: PoqMyProfileListPresenter? { get set }
    
    var loggedInContent: [PoqMyProfileListContentItem] { get set }
    var loggedOutContent: [PoqMyProfileListContentItem] { get set }
    var favoriteStoreId: Int? { get set }
    
    func processContent( _ result: [Any]? )
    func getContent( _ isRefresh: Bool )
    func getDetails(_ isRefresh: Bool)
    func getCellForIndex( _ collectionView: UICollectionView, indexPath: IndexPath ) -> UICollectionViewCell
    func authenticateWithFacebook( fromViewController viewController: UIViewController )
    func logout()
    func getContentAtIndexPath( _ indexPath: IndexPath ) -> PoqMyProfileListContentItem
    func processGetAccountResult(_ result: [Any]?)
}

extension PoqMyProfileListService {
    
    public func getContent(_ isRefresh: Bool = false) {
        PoqNetworkService(networkTaskDelegate: self).getMyProfileBlocks(isRefresh)
    }
    
    public func parseBlocksToContentItems(_ blocks: [PoqBlock]) {
        for block in blocks {
            let contentItem = PoqMyProfileListContentItem(block: block)
            
            if block.isAvailableForLoggedIn == true {
                loggedInContent.append(contentItem)
            } else {
                loggedOutContent.append(contentItem)
            }
        }
    }
    
    public func getCellForIndex(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        
        let contentItem = getContentAtIndexPath(indexPath)
        
        guard let cellClass = contentItem.cellClass else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: NotFoundContentCollectionViewCell.poqReuseIdentifier, for: indexPath)
        }
        
        let cellIdentifier = cellClass.poqReuseIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        guard let reusableCell = cell as? PoqMyProfileListReusableView, let validPresenter = presenter else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: NotFoundContentCollectionViewCell.poqReuseIdentifier, for: indexPath)
        }
        
        reusableCell.setup(using: contentItem, cellPresenter: validPresenter)
        
        return cell
    }
    
    public func authenticateWithFacebook(fromViewController viewController: UIViewController) {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: viewController) {
            (result, error) in
            
            guard let result = result else {
                Log.verbose("Facebook login has null result")
                return
            }
            
            if let error = error {
                Log.verbose("Facebook login error: \(error)")
                return
            }
            
            if result.isCancelled {
                Log.verbose("Facebook login cancelled")
                return
            }
            
            guard let accessToken = result.token, let facebookToken = accessToken.tokenString else {
                Log.verbose("Facebook login failed because of missing token")
                return
            }
            
            let postObj = PoqFacebookAccountPost()
            postObj.token = facebookToken
            
            PoqNetworkService(networkTaskDelegate: self).postFacebookAccount(postObj, poqUserId: User.getUserId())
            
            // Store the token after the API call is created
            // to avoid attaching it as Auth Header to the request
            LoginHelper.saveFacebookToken(facebookToken)
        }
    }
    
    public func logout() {
        if let _ = LoginHelper.getFacebookToken() { // if we are fb logged then remove permmissions from fb api
            self.logOutFacebookIfPossible()
        }
        // assume this call as safe, since we will clear all data
        WishlistController.shared.remove()
        BagHelper().saveOrderId(0) // this shouldn’t be needed
        // Remove existing poqUserId on logout
        User.resetUserId()
        BadgeHelper.setBadge(for: Int(AppSettings.sharedInstance.shoppingBagTabIndex), value: 0)
    }
    
    public func getDetails(_ isRefresh: Bool) {
        PoqNetworkService(networkTaskDelegate: self).getAccount(isRefresh)
    }
    
    public func processGetAccountResult(_ result: [Any]?) {
        
        guard let networkResults = result as? [PoqAccount], networkResults.count > 0 else {
            
            return
        }
        
        let account = networkResults[0]
        
        let allowGuestUser = account.statusCode == HTTPResponseCode.UNAUTHORIZED && account.isGuest == true
        guard account.statusCode == HTTPResponseCode.OK || allowGuestUser else {
            
            presenter?.showLoginError()
            return
        }
        
        LoginHelper.saveAccountDetails(account)
    }
    
    func processGetCheckoutDetailsResult(_ result: [Any]?) {
        
        // TODO: move this functionality to some helper/service.May be create BagService
        
        if let checkoutItem = result?.first as? PoqCheckoutItem<PoqBagItem> {
            BadgeHelper.setNumberOfBagItems(checkoutItem.bagItems)
        }
    }
    
    public func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Network Flow:
        // 1. Get content blocks
        // 2. Get account details
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.blocks:
            
            loggedInContent = []
            loggedOutContent = []
            
            processContent(result)
            
            if LoginHelper.isLoggedIn() {
                
                // This doesn't need to update VC so no callback needed
                // Because it triggers the network call for account data
                getDetails(false)
            }
            
        case PoqNetworkTaskType.getAccount:
            processGetAccountResult(result)
            
            // We need to load blocks first and then account details
            // So we don't need to call VC to render collection view
            // Instead we are waiting until everything is received and good to go
            
        case PoqNetworkTaskType.getCheckoutDetails:
            
            // This doesn't need to update VC so no callback needed
            processGetCheckoutDetailsResult(result)
            
        case PoqNetworkTaskType.postFacebookAccount:
            //saveToken
            Log.warning("POST_FACEBOOK_ACCOUNT response came back")
            
            // PostFacebookAccount is returning Account details
            // just like GetAccount and Sign in/up requests, therefore
            // process the response and save the received Account details
            processGetAccountResult(result)
            
            // Get Checkout to update Bag badge number
            getCheckoutDetailsIfNeeded()
            
        case PoqNetworkTaskType.deleteAllWishList:
            Log.info("Deleted all wishlist items")
            
        default:
            Log.warning("Network task type not handled")
            
        }
        
        presenter?.update(state: .completed, networkTaskType: networkTaskType)
    }
    
    public func getContentAtIndexPath(_ indexPath: IndexPath) -> PoqMyProfileListContentItem {
        if LoginHelper.isLoggedIn() {
            return loggedInContent[indexPath.item]
        } else {
            return loggedOutContent[indexPath.item]
        }
    }
    
    // MARK: - Network Task Callbacks
    
    /**
     Callback before start of the async network task
     */
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        presenter?.update(state: .loading, networkTaskType: networkTaskType)
    }
    
    /**
     Callback after async network task is completed successfully
     */
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        parseResponse(networkTaskType, result: result)
    }
    
    /**
     Callback when task fails due to lack of responded data, connectivity etc.
     */
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
    }
    
    // MARK: - Private
    
    fileprivate func logOutFacebookIfPossible() {
        let loginManager = FBSDKGraphRequest(graphPath: "/me/permissions", parameters: nil, httpMethod: "DELETE")
        
        _ = loginManager?.start {
            (connection, result, error) in
            
            if let error = error {
                Log.verbose("Facebook logout error: \(error)")
                return
            }
        }
    }
    
    fileprivate func getCheckoutDetailsIfNeeded() {
        if AppSettings.sharedInstance.checkoutBagType == BagType.native.rawValue {
            let service = PoqNetworkService(networkTaskDelegate: self)
            let orderId = BagHelper().getOrderId()
            typealias TaskType = PoqNetworkTask<JSONResponseParser< PoqMyProfileListService.CheckoutItemType>>
            let _: TaskType = service.getCheckoutDetails(orderId, isRefresh: true)
        }
    }
}
