//
//  StoreDetailTableViewNameCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 17/08/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation



open class StoreDetailTableViewNameCell: UITableViewCell {
    
    // MARK: - Class attributes
    // _____________________________
    
    // Custom view XIB, Identifier and custom Height

    static let CellXib:String = "StoreDetailTableViewNameCell"
    public static var CellHeight:CGFloat = CGFloat(AppSettings.sharedInstance.storeDetailNameCellHeight)
    
    @IBOutlet public weak var storeAddressLabel: UILabel? {
        
        didSet {
            // FIXME: When we migrate to AppStyling the related font here should be AppTheme.sharedInstance.storeContactFont
            /*
             The cell height is calculated with that AppTheme.sharedInstance.storeContactFont, but we set AppTheme.sharedInstance.storeAddressFont,
             also I asume that .storeContactFont is prepared only for that label and curretly it's used only for calculation of StoreDetailTableViewNameCell height.
             let nameCellHeight = heightForView(fullAddress, font: AppTheme.sharedInstance.storeContactFont, width: cellWidth)
             content.append(TableViewContent(identifier: StoreDetailTableViewNameCell.poqReuseIdentifier, height: nameCellHeight))
             */
            storeAddressLabel?.font = AppTheme.sharedInstance.storeAddressFont
        }
    }
    
    @IBOutlet weak var storeNameLabel: UILabel?
    
    // MARK: - UI Business Logic
    
    // _____________________________
    
    override open func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Initialization code
        resetLabels()
       
    }
    
    func resetLabels() {
        
         // Reset any value from XIB
        storeAddressLabel?.text = ""
        storeNameLabel?.text = ""
    }
    
    
    
    func setFullStoreAddress(_ fullStoreAddress:String) {
        
        storeAddressLabel?.text = fullStoreAddress

        
    }
    
    
    func setStoreName(_ storeName: String?) {
        
        storeNameLabel?.text = storeName
    }
    

    
    
}
