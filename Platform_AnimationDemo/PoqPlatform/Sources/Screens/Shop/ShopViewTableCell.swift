//
//  ShopViewTableCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 27/05/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

public enum ShopCategoryNameCaseType:String{
    case Default = "Default"
    case Upper = "Upper"
    case Lower = "Lower"
}

public enum ShopViewTableCellType{
    case `default`
    case parent
    case children
}
open class ShopViewTableCell : AccordionTableViewCell {
    
//    static let CellIdentifier:String = "ShopViewTableCellIdentifier"
//    static let XibName:String = "ShopViewTableCellView"

    // IBOutlets
    @IBOutlet public weak var label: UILabel!
    @IBOutlet public weak var categoryImageView: PoqAsyncImageView?
    @IBOutlet public weak var categoryImageViewWidth: NSLayoutConstraint?
    
    // Used for indenting the view content
    // Used to support bottom line of the row and adding padding at the same time
    @IBOutlet public  weak var indentView: NSLayoutConstraint!
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    open func updateData(_ category:ShopViewCategory){
        self.isEnabled = AppSettings.sharedInstance.isDisclosureIndicatorEnabledOnShop
        
        //switiching cases
        label.text = LabelStyleHelper.checkCases(category.name)
        
        label.textColor = AppTheme.sharedInstance.shopTabDefaultCategoryTextColor
        label.font = AppTheme.sharedInstance.shopTabDefaultCategoryFont
        
        // Show if category has an image and first level and enabled by client
        if !category.picture.isEmpty && category.cellType.level == 0 && AppSettings.sharedInstance.isCategoryImageEnabled {
            
            categoryImageViewWidth?.constant = 60
            categoryImageView?.getImageFromURL(URL(string: category.picture)!, isAnimated: false)
        }
        else {
            
            categoryImageViewWidth?.constant = 0
        }
        

    }
    
    open func changeLabelColor(_ type: ShopViewTableCellType){
        switch type{
        case .parent:
            backgroundColor = AppTheme.sharedInstance.shopTabParentCategoryBackgroundColor
            label.textColor = AppTheme.sharedInstance.shopTabParentCategoryTextColor
            label.font = AppTheme.sharedInstance.shopTabParentCategoryFont
            break
        case .children:
            backgroundColor = AppTheme.sharedInstance.shopTabChildrenCategoryBackgroundColor
            label.textColor = AppTheme.sharedInstance.shopTabChildrenCategoryTextColor
            label.font = AppTheme.sharedInstance.shopTabChildrenCategoryFont
            break
        case .default:
            backgroundColor = AppTheme.sharedInstance.shopTabDefaultCategoryBackgroundColor
            label.textColor = AppTheme.sharedInstance.shopTabDefaultCategoryTextColor
            label.font = AppTheme.sharedInstance.shopTabDefaultCategoryFont
            break
        }
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        changeLabelColor(.default)
        categoryImageView?.prepareForReuse()
    }
}


