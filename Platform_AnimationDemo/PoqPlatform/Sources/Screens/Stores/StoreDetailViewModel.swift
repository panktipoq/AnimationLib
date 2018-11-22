//
//  StoreDetailViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 05/08/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import MapKit
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

open class StoreDetailViewModel: BaseViewModel, StoreDetailTableViewCallButtonClickDelegate {
    
    // MARK: - Class Attributes
    // ________________________
    
    public final var store = PoqStore()
    public final var content = [TableViewContent]()
    
    // Default table cell width
    open var cellWidth: CGFloat = 320
    open var fullAddress: String = ""
    
    // MARK: - Init
    // ________________________
    
    // Used for avoiding optional checks in viewController
    override init() {
        
        super.init()
    }
    
    public override init(viewControllerDelegate: PoqBaseViewController) {
        
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    // MARK: - UI Business Logic
    // ________________________
    
    /**
    Initializes tableView's content array for cells (rows)
    */
    open func initTableViewContentCells() {
        
        // Reset the content first
        content = []
        
        // Insert Map Cell
        content.append(TableViewContent(identifier: StoreDetailTableViewMapCell.poqReuseIdentifier, height: StoreDetailTableViewMapCell.CellHeight))
        
        // Insert Call Cell if there is a phone number
        if let phoneNumber = store.phone, !phoneNumber.isNullOrEmpty() {
            content.append(TableViewContent(identifier: StoreDetailTableViewCallCell.poqReuseIdentifier, height: StoreDetailTableViewCallCell.CellHeight))
        }
        
        // Insert Name Cell

        // Init for resizing later
        let nameCellHeight = heightForView(fullAddress, font: AppTheme.sharedInstance.storeContactFont, width: cellWidth)
        content.append(TableViewContent(identifier: StoreDetailTableViewNameCell.poqReuseIdentifier, height: nameCellHeight))
        
        // Insert Hours Cell
        content.append(TableViewContent(identifier: StoreDetailTableViewHoursCell.poqReuseIdentifier, height: StoreDetailTableViewHoursCell.CellHeight))
    }
    
    /**
    Get height for the row
    
    - parameter row:  Current row in tableView
    */
    func getTableCellHeightForRow(_ row: Int) -> CGFloat {
        
        if row < content.count {
            
            return content[row].height
        } else {
            
            Log.verbose("Content array doesn't include row: \(row), so the cell will be hidden")
            return 0
        }
    }

    /**
    Get custom tableView cell implementation for the indexPath
    */
    open func getTableCellForIndexPath(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < content.count {
            
            let storeContentCell = content[indexPath.row]
            
            switch storeContentCell.identifier {
                
            case StoreDetailTableViewMapCell.poqReuseIdentifier:
                return getTableCellForMap(tableView, indexPath: indexPath)
                
            case StoreDetailTableViewCallCell.poqReuseIdentifier:
                return getTableCellForCall(tableView, indexPath: indexPath)
                
            case StoreDetailTableViewNameCell.poqReuseIdentifier:
                return getTableCellForName(tableView, indexPath: indexPath)
                
            case StoreDetailTableViewHoursCell.poqReuseIdentifier:
                return getTableCellForOpeningHours(tableView, indexPath: indexPath)
                
            default:
                return tableCellNotFoundForIndexPath(indexPath)
            }
        } else {
            return tableCellNotFoundForIndexPath(indexPath)
        }
    }
    
    /**
    Returns empty UITableViewCell for not found indexPath in contents array
    */
    open func tableCellNotFoundForIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        
        Log.error("Content array doesn't include row: \(indexPath.row), so the cell will be hidden")
        return UITableViewCell()
    }
    
    /**
    Returns custom cell for the StoreDetailTableViewMapCell
    */
    open func getTableCellForMap(_ tableView: UITableView, indexPath: IndexPath) -> StoreDetailTableViewMapCell {
    
        let mapCell: StoreDetailTableViewMapCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        mapCell.addStoreLocationPointOnMap(store)

        if let existedStoreDetail: StoreDetailViewController = viewControllerDelegate as? StoreDetailViewController {
            existedStoreDetail.mapCellDelegate = mapCell
        }
        return mapCell
    }
    
    /**
    Returns custom cell for the StoreDetailTableViewCallCell
    */
    open func getTableCellForCall(_ tableView: UITableView, indexPath: IndexPath) -> StoreDetailTableViewCallCell {
        
        let callButtonCell: StoreDetailTableViewCallCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        callButtonCell.setCallButton(store)
        callButtonCell.callButtonClickDelegate = self
        return callButtonCell
    }
    
    /**
    Returns custom cell for the StoreDetailTableViewNameCell
    */
    open func getTableCellForName(_ tableView: UITableView, indexPath: IndexPath) -> StoreDetailTableViewNameCell {
        
        let nameCell: StoreDetailTableViewNameCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        nameCell.setFullStoreAddress(fullAddress)
        nameCell.setStoreName(store.name)
        return nameCell
    }
    
    /**
    Returns custom cell for the StoreDetailTableViewHoursCell
    */
    open func getTableCellForOpeningHours(_ tableView: UITableView, indexPath: IndexPath) -> StoreDetailTableViewHoursCell {
        
        let hoursCell: StoreDetailTableViewHoursCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        hoursCell.setOpeningHours(store)
        return hoursCell
    }
    
    /**
    Handles call button click event from Name cell
    */
    func callButtonClicked() {
        
        if let phone = store.phone, let _ = store.name, !phone.isEmpty && !DeviceType.IS_IPAD {
            
            CallButtonHelper.launchPhoneCall(phone)
        }
        
        PoqTrackerV2.shared.storeFinder(action: StoreFinderAction.phoneCall.rawValue, storeName: store.name ?? "")
    }

    /**
    Handles direction button click event from Name cell
    */
    func directionButtonClicked() {
        
        let title = "LEAVING_THE_APP".localizedPoqString
        let message = "LEAVING_THE_APP_GETTING_DIRECTIONS".localizedPoqString
        
        let cancelText = "CANCEL".localizedPoqString
        let okText = "GET_DIRECTIONS".localizedPoqString
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction.init(title: cancelText, style: UIAlertActionStyle.cancel, handler: { (_: UIAlertAction) in
            
        }))
        
        alertController.addAction(UIAlertAction.init(title: okText, style: UIAlertActionStyle.destructive, handler: { (_: UIAlertAction) in
            PoqTrackerV2.shared.storeFinder(action: StoreFinderAction.directions.rawValue, storeName: self.store.name ?? "")
            let items = [self.getDirectionDestionation(self.store)]
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            MKMapItem.openMaps(with: items, launchOptions: options)
        }))
        
        viewControllerDelegate?.present(alertController, animated: true, completion: { 
           // Completion handler once everything is dismissed
        })
    }
    
    func getDirectionDestionation(_ store: PoqStore) -> MKMapItem {
        
        let coordinates: CLLocationCoordinate2D = getStoreCLLocationCoordinate2D(store)
        let place = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let destination = MKMapItem(placemark: place)
        destination.name = store.name ?? ""
        return destination
    }
    
    open func getStoreCLLocationCoordinate2D(_ store: PoqStore) -> CLLocationCoordinate2D {
        
        if let longtitude: String = store.longitude, let latitude: String = store.latitude, !longtitude.isEmpty && !latitude.isEmpty {
            
            // Longtitude.toDouble doesn't work well with minus string values.
            let longtitudeValue: Double = (longtitude as NSString).doubleValue
            let latitudeValue: Double = (latitude as NSString).doubleValue
            
            return CLLocationCoordinate2D(latitude: latitudeValue, longitude: longtitudeValue)
        } else {
            
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
    
    // MARK: - Networking
    // ________________________
    
    open func getStoreDetail(_ storeId: Int, isRefresh: Bool = false) {
        
        PoqNetworkService(networkTaskDelegate: self).getStoreDetail(storeId, isRefresh: isRefresh)
    }

    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        
        // Update UI
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /**
    Hides activity indicator
    */
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Call super to hide activity indicator
        // Send empty result list for avoind memory issues
        super.networkTaskDidComplete(networkTaskType, result: [])
        
        if networkTaskType == PoqNetworkTaskType.storeDetail {
            
            if let networkTaskResult = result as? [PoqStore], networkTaskResult.count > 0 {
                
                store = networkTaskResult[0]
                
                // Form full address
                populateFullAddress()
                // Update UI
                initTableViewContentCells()
                
                viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
            }
        }
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }

    // MARK: - form the full store address.
    
    open func populateFullAddress() {
        appendAddress1()
        appendAddress2()
        appendCity()
        appendCounty()
        appendPostCode()
        appendCountry()
    }
    
    func appendAddress1() {
            if let storeAddress = store.address, !storeAddress.isNullOrEmpty() {
                fullAddress = storeAddress + "\n"
            }
    }
    
    func appendAddress2() {
        if let storeAddress2 = store.address2, !storeAddress2.isNullOrEmpty() {
            fullAddress += storeAddress2 + "\n"
        }
    }
    func appendCity() {
        if let storeCity = store.city, !storeCity.isNullOrEmpty() {
            fullAddress += storeCity + ", "
        }
    }
    
    func appendCounty() {
        if let storeCounty = store.county, !storeCounty.isNullOrEmpty() {
            fullAddress += storeCounty + ", "
        }
    }
    
    func appendPostCode() {
        if let storePostCode = store.postCode, !storePostCode.isNullOrEmpty() {
            fullAddress += storePostCode + "\n"
        }
    }
    
    func appendCountry() {
        if let storeCountry = store.country, !storeCountry.isNullOrEmpty() {
            fullAddress += storeCountry
        }
    }
}
