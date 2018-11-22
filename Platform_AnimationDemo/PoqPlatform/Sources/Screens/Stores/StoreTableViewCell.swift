//
//  StoreTableViewCell.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 2/18/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

open class StoreTableViewCell: UITableViewCell {

    @IBOutlet open var name: UILabel?
    @IBOutlet open var addressLabel: UILabel?
    @IBOutlet open var cityCountyPostCode: UILabel?
    @IBOutlet open var distance: UILabel?
    @IBOutlet open var unit: UILabel?
    
    open var store: PoqStore?
    
    open func setUpStore(_ store: PoqStore) {
        self.store = store
        updateNameAndAddress()
        updateDistanceAndUnit()
    }
    
    open func updateNameAndAddress() {
        name?.font = AppTheme.sharedInstance.storeNameFont
        name?.text = store?.city
        
        addressLabel?.font = AppTheme.sharedInstance.storeAddressFont
        
        if let storeName = store?.name, let storeAddress = store?.address {
            let address = String(format: "%@, %@", arguments: [storeName, storeAddress])
            addressLabel?.text = address
        }
        
        guard let cityCountyPostCodeLabel = cityCountyPostCode else { return }
        guard let city = store?.city, !city.isEmpty else { return }
        guard let county = store?.county, !county.isEmpty else { return }
        guard let postCode = store?.postCode, !postCode.isEmpty else { return }
        
        cityCountyPostCodeLabel.font = AppTheme.sharedInstance.storeAddressFont
        let cityCountyPostCodeString = String(format: "%@, %@ %@", arguments: [city, county, postCode])
        cityCountyPostCodeLabel.text = cityCountyPostCodeString
        name?.text = store?.name
        addressLabel?.text = store?.address
    }
    
    open func updateDistanceAndUnit() {
        distance?.font = AppTheme.sharedInstance.storeDistanceFont
        distance?.text = store?.distance.flatMap({ StoreSettings.distanceFormatter.formattedDistance($0) })
        
        unit?.font = AppTheme.sharedInstance.storeAddressFont
        unit?.text = store?.distance.flatMap({ StoreSettings.distanceFormatter.formattedUnit(forDistance: $0) })
    }
}
