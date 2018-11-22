//
//  ProductDeliveryViewCell.swift
//  Poq.iOS.HollandAndBarrett
//
//  Created by GabrielMassana on 24/01/2017.
//
//

import UIKit

public class ProductDeliveryViewCell: UITableViewCell {

    //MARK - Properties
    @IBOutlet public weak var deliveryLabel: UILabel?

    //MARK - AwakeFromNib
    public override func awakeFromNib() {
        
        super.awakeFromNib()
        
        deliveryLabel?.text = AppLocalization.sharedInstance.deliveryPageOnPDPTitle
        deliveryLabel?.font = AppTheme.sharedInstance.pdpDeliveryLabelFont
        
        //use the customised disclosure indicator
        createAccessoryView()
    }
    
    //MARK: - Setup
    
    public func setup() {
        
    }
}
