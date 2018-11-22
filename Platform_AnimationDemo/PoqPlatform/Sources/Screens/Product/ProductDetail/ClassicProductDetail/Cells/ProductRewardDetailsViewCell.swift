//
//  ProductRewardDetailsViewCell.swift
//  Poq.iOS.HollandAndBarrett
//
//  Created by GabrielMassana on 09/01/2017.
//
//

import PoqNetworking
import UIKit

public class ProductRewardDetailsViewCell: UITableViewCell {

    //MARK: - IBOutlet

    @IBOutlet public weak var rewardLabel: UILabel?
    @IBOutlet public weak var ppuLabel: UILabel?
    @IBOutlet public weak var codeLabel: UILabel?

    //MARK: - ClassVariables
    
    public var product: PoqProduct?

    //MARK: - Setup
    
    public func setup(using product: PoqProduct) {
        
        self.product = product

        selectionStyle = .none

        /*---------------*/
        
        rewardLabel?.font = AppTheme.sharedInstance.pdpProductRewardDetailsCellRewardFont
        
        rewardLabel?.textColor = AppTheme.sharedInstance.pdpProductRewardDetailsCellRewardColor
        
        ppuLabel?.font = AppTheme.sharedInstance.pdpProductRewardDetailsCellPPUFont
        ppuLabel?.textColor = AppTheme.sharedInstance.pdpProductRewardDetailsCellPPUColor
        
        codeLabel?.font = AppTheme.sharedInstance.pdpProductRewardDetailsCellCodeFont
        codeLabel?.textColor = AppTheme.sharedInstance.pdpProductRewardDetailsCellCodeColor
        
        /*---------------*/

        if let productRewardDetails = product.productRewardDetails {
            
            rewardLabel?.text = productRewardDetails.title
            ppuLabel?.text = productRewardDetails.pricePerUnit
            codeLabel?.text = productRewardDetails.code
        }
        else {
            
            rewardLabel?.text = ""
            ppuLabel?.text = ""
            codeLabel?.text = ""
        }
    }
}
