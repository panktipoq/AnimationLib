//
//  SearchHeaderView.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 2/2/17.
//
//

import UIKit

open class SearchHeaderView: UIView {
    
    @IBOutlet weak public var headerTitleLabel: UILabel?
    @IBOutlet weak public var clearButton: UIButton?

    var searchHeader: SearchHeader = SearchHeader.searchHistoryHeader {
        didSet {
            update()
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = AppTheme.sharedInstance.searchHeaderBackground
        headerTitleLabel?.textColor = AppTheme.sharedInstance.searchHeaderTextColor
        
        headerTitleLabel?.font = AppTheme.sharedInstance.searchHeaderTextFont
        
        clearButton?.titleLabel?.font = AppTheme.sharedInstance.searchHistoryClearButtonFont
        
        clearButton?.setTitle(AppLocalization.sharedInstance.searchClearHistoryButtonText, for: .normal)
        
        update()
    }

    fileprivate func update() {
        headerTitleLabel?.text = searchHeader.text
        clearButton?.isHidden = !searchHeader.showClearButton
    }
}
