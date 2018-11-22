//
//  CheckoutDeliveryOptionsViewModel.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 10/2/15.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities

open class CheckoutDeliveryOptionsViewModel: BaseViewModel {
    
    open var deliveryOptions: [PoqDeliveryOption] = []
    
    public let cellReuseIdentifier: String = "deliveryOptionReuseIdentifier"
    
    open var networkResultValidation:(isValid: Bool, message: String) = (isValid:true, message: "")
    
    // MARK: - Init
    // ________________________
    
    // Used for avoiding optional checks in viewController
    public override init() {
        super.init()
    }
    
    public override init(viewControllerDelegate: PoqBaseViewController) {
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {

        // Reset to avoid multiple alerts
        networkResultValidation = (isValid:true, message: "")
        super.networkTaskWillStart(networkTaskType)
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Reset to avoid multiple alerts
        networkResultValidation = (isValid:true, message: "")
        super.networkTaskDidFail(networkTaskType, error: error)
    }

    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
    
        if let networkResult = result as? [PoqDeliveryOption], networkResult.count > 0 {
            
            deliveryOptions = networkResult
            
            networkResultValidation = isValidNetworkResult(networkResult)
        }
        
        super.networkTaskDidComplete(networkTaskType, result: nil)
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
    
    open func createPostAddress(_ address: PoqAddress?) -> PoqPostAddress? {
        guard let country = address?.country else {
            Log.error("We need country  to create address")
            return nil
        }
        
        let postAddress = PoqPostAddress()
        postAddress.billingAddress = address
        postAddress.shippingAddress = address
        
        let countries = Countries.allValues
        let countryId: String? = countries.filter({ $0.name == country })[0].isoCode
        
        guard let validCountryId: String = countryId else {
            Log.error("Unable to find countri id for country name: \(country)")
            return nil
        }
        
        postAddress.billingAddress?.countryId = validCountryId
        postAddress.shippingAddress?.countryId = validCountryId
        
        return postAddress
    }
    
    open func isValidNetworkResult(_ result: [PoqDeliveryOption]?) -> (isValid: Bool, message: String) {
        
        guard let networkResult = result else {
            
            return (isValid:false, message:"")
        }
        
        guard networkResult.count > 0 else {
            
            return (isValid:false, message:"")
        }

        let option = networkResult[0]
        
        guard let message = option.message else {
            
            return (isValid:true, message:"")
        }
        
        if message.isNullOrEmpty() {
            
            return (isValid:true, message:"")
        } else {
         
            return (isValid:false, message:message)
        }
    }
    
    open func loadDeliveryOption(_ postAddress: PoqPostAddress) {
        
        guard let validOrderId = BagHelper().getOrderId() else {
            return
        }
        PoqNetworkService(networkTaskDelegate: self).postCheckoutAddress(String(validOrderId), postAddress: postAddress)
    }
    
    open func postDeliverySelection(_ deliveryOption: PoqDeliveryOption) {
        
        deliveryOption.orderId = BagHelper().getOrderId()
        PoqNetworkService(networkTaskDelegate: self).postDeliveryOption(deliveryOption)
    }
    
    open func getCellForRowAtIndexPath(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, withAccessoriType: Bool = false) -> UITableViewCell {
        
        guard let title = deliveryOptions[indexPath.row].title, let price = deliveryOptions[indexPath.row].price else {
            
            return UITableViewCell()
        }
        
        let cell: CheckoutDeliveryOptionsCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        setupDeliveryOptionTitle(cell.titleLabel, title: title)
        cell.priceLabel.text = LabelStyleHelper.showFreeForPriceZero(price)
        if withAccessoriType {
            cell.accessoryType = .checkmark
            cell.tintColor = AppTheme.sharedInstance.checkoutDeliveryOptionsAccessoryTypeColor
        }
        return cell
    }
}

// MARK: - TableView Operations
// ____________________________

extension CheckoutDeliveryOptionsViewModel {
    
    open func getNumberOfRowsForTableView(_ section: Int) -> Int {
        
        return deliveryOptions.count
    }
    
    open func setupDeliveryOptionTitle(_ titleLabel: UILabel, title: String) {
        
        titleLabel.text = title
    }
    
    open func getDeliverySelection(_ indexPath: IndexPath) -> PoqDeliveryOption {
        
        return deliveryOptions[indexPath.row]
    }
    
}
