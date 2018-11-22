//
//  ProductAddToBagViewCell.swift
//  Poq.iOS
//
//  Created by GabrielMassana on 05/01/2017.
//
//

import PoqNetworking
import UIKit

/**
 Table View Cell to show an independent Add To Bag Button.
 */
public class ProductAddToBagViewCell: UITableViewCell {

    //MARK: - IBOutlet

    @IBOutlet public weak var addToBagButton: AddToBagButton?
    
    //MARK: - ClassVariables
    
    public var product: PoqProduct?
    
    //MARK: - Delegates
    
    weak public var productDetailDelegate: ProductDetailViewDelegate?
    
    //MARK: - AwakeFromNib
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        if let fontName = addToBagButton?.titleLabel?.font.fontName {
            addToBagButton?.titleLabel?.font = UIFont(name: fontName, size: CGFloat(AppSettings.sharedInstance.pdpAddToBagLabelFontSize))
        }
    }
    
    //MARK: - Setup

    public func setup(using product: PoqProduct) {
        
        self.product = product
        
        selectionStyle = .none
        
        // Handle out of stock
        if let sizes = product.productSizes {
            addToBagButton?.isEnabled = !sizes.isEmpty
        }
    }
    
    @IBAction func addToBagButtonClicked(_ sender: Any) {
        productDetailDelegate?.addToBagButtonClicked()
    }
}
