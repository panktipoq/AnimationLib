//
//  ProductAvailabilityViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 01/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

open class ProductAvailabilityTableViewCell : UITableViewCell, PoqNetworkTaskDelegate {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var spinner: PoqSpinner!
    
    open var isNetworkTaskRunning = false
    open var product:PoqProduct?
    open var storeStock:PoqStoreStock?
    open var unknownSize = "Select size"
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
        if selected {
            
            Log.verbose("Open store stock check")
            // Product data and store stock data should be transferred to VC
            // This looks the best options for now
            NavigationHelper.sharedInstance.loadProductAvailability(self.product, storeStock: self.storeStock)
        }
    }
    
    open func updateView(_ product:PoqProduct) {
        
        self.product = product
        
        if !isNetworkTaskRunning {
            
            // Set the tint color of the spinner
            self.spinner?.tintColor = AppTheme.sharedInstance.mainColor
            self.imageView?.alpha = 0
            self.availabilityLabel?.text = ""
            
            // Set table label font
            self.availabilityLabel?.font = AppTheme.sharedInstance.availabilityFont
            
            // Check in store availability
            if let isAvailableInStore = product.isAvailableInStore {
                
                if isAvailableInStore {
                    
                    if StoreHelper.getFavoriteStoreId() != 0 {
                        
                        if self.storeStock == nil {
                            
                            // Product available to store check
                            // Check store stock with poq user id
                            // Equivalent size will be returned from api
                            checkAvailability()
                            
                        }
                        else {
                            
                            showAvailabilityResult()
                        }
                        
                    }
                    else {
                        
                        // Product available to store check
                        // but user doesn't have favorite store
                        showCheckAvailability()
                    }
                }
                else {
                    
                    // Product unavailable to store check
                    showAvailabilityOff()
                }
            }
            else {
                
                // Product unavailable to store check
                showAvailabilityOff()
            }
        }
    }
    
    open func checkAvailability() {
        
        if let product = self.product {
            
            PoqNetworkService(networkTaskDelegate: self).getStoreStock(product.id!, productSizeId: 0, lat: 0, lng: 0, storeId: StoreHelper.getFavoriteStoreId(), poqUserId: User.getUserId(), isRefresh: false)
        }
        
    }
    
    open func showAvailabilityResult() {
        
        if let storeStock = self.storeStock {
            
            if storeStock.selectedSizeName != nil && storeStock.name != nil && storeStock.isInStock != nil {
                
                if storeStock.selectedSizeName! == self.unknownSize {
                    
                    print("Store Stock: Select size for the size. Show Check in-store availability")
                    showCheckAvailability()
                }
                else {
                    
                    if storeStock.isInStock! {
                        
                        Log.verbose("Store Stock: Product is available")
                        
                        // Product is available
                        self.availabilityLabel?.textColor = AppTheme.sharedInstance.availabilityInStoreTextColor
                        
                        // API doesn't return size name for
                        // products that doesn't have product size (i.e. frying pan)
                        if storeStock.selectedSizeName!.isEmpty {
                            
                            self.availabilityLabel?.text = String(format: AppLocalization.sharedInstance.availableAtStore, arguments: [storeStock.name!])
                        }
                        else {
                            
                            self.availabilityLabel?.text = String(format: AppLocalization.sharedInstance.sizeAvailableAtStore, arguments: [storeStock.selectedSizeName!, storeStock.name!])
                        }
                        
                        showTicker()
                        
                    }
                    else {
                        
                        Log.verbose("Store Stock: Product is not available")
                        
                        // Not available
                        self.availabilityLabel?.textColor = AppTheme.sharedInstance.availabilityNotInStoreTextColor
                        
                        // API doesn't return size name for
                        // products that doesn't have product size (i.e. frying pan)
                        if storeStock.selectedSizeName!.isEmpty {
                            
                            self.availabilityLabel?.text = String(format: AppLocalization.sharedInstance.unavailableAtStore, arguments: [storeStock.name!])
                        }
                        else {
                            //println(storeStock.selectedSizeName)
                            self.availabilityLabel?.text = String(format: AppLocalization.sharedInstance.sizeUnavailableAtStore, arguments: [storeStock.selectedSizeName!, storeStock.name!])
                        }
                        
                        showHungerOn()
                    }
                }
            }
            else {
                
                // Missing some data
                showAvailabilityOff()
            }
        }
        else {
            
            // Incoming data is nil
            showAvailabilityOff()
        }
    }
    
    open func showCheckAvailability() {
        
        Log.verbose("Store Stock: check in store availabilty")
        self.availabilityLabel?.textColor = AppTheme.sharedInstance.availabilityOffTextColor
        self.availabilityLabel?.text = AppLocalization.sharedInstance.checkInStoreAvailability
        showHungerOn()
    }
    
    open func showAvailabilityOff() {
        
        Log.verbose("Store Stock: availabilty is off")
        
        // Availability is off
        self.availabilityLabel?.textColor = AppTheme.sharedInstance.availabilityOffTextColor
        self.availabilityLabel?.text = AppLocalization.sharedInstance.storeAvailabilityOff
        showHungerOff()
    }
    
    open func showHungerOff() {
        
        self.imageView?.image = UIImage(named: "ico-sizes-disabled")
        self.imageView?.alpha = 0.5
        self.imageView?.setNeedsDisplay()
    }
    
    open func showHungerOn() {
        
        self.imageView?.image = UIImage(named: "ico-sizes-disabled")
        self.imageView?.alpha = 1
        self.imageView?.setNeedsDisplay()
    }
    
    open func showTicker() {
        
        self.imageView?.image = UIImage(named: "ico-sizes")
        self.imageView?.alpha = 1
        self.imageView?.setNeedsDisplay()
    }
    
    // MARK: - Basic network task callbacks
    
    /**
    Callback before start of the async network task
    */
    open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        isNetworkTaskRunning = true
        self.spinner?.startAnimating()
    }
    
    // TODO:
    //  Result is always carried as array of AnyObject. This bit is open to discussion
    //  I realised, almost all of our api endpoints are array of JSON objects except product detail
    //  So this approached looked OK for me in the first instance.
    //  However, any improvements are highly appreciated
    
    /**
    Callback after async network task is completed successfully
    */
    open func networkTaskDidComplete(_ networkTaskType:PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        isNetworkTaskRunning = false
        self.spinner?.stopAnimating()
        
        if networkTaskType == PoqNetworkTaskType.storeStock {
            
            if let result = result as? [PoqStoreStock] {
                
                if result.count > 0 {
                    
                    self.storeStock = result[0]
                    showAvailabilityResult()
                }
                else {
                    
                    // API couldn't find store stock data
                    showAvailabilityOff()
                }
            }
            else {
                
                // API returned error etc.
                showAvailabilityOff()
            }
        }
    }
    
    /**
    Callback when task fails due to lack of responded data, connectivity etc.
    */
    open func networkTaskDidFail(_ networkTaskType:PoqNetworkTaskTypeProvider, error: NSError?) {
        
        isNetworkTaskRunning = false
        spinner?.stopAnimating()
    }
    
}
