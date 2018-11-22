//
//  PredictiveSearchResultCell.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/30/17.
//
//

import PoqNetworking
import UIKit

open class PredictiveSearchResultCell: FullWidthAutoresizedCollectionCell {
    
    @IBOutlet weak open var titleLabel: UILabel? {
        didSet {
            titleLabel?.accessibilityLabel = AccessibilityLabels.searchResultLabel
            accessibilityLabel = AccessibilityLabels.searchResultCell
        }
    }
}

extension PredictiveSearchResultCell: SearchCell {

    public func update(using contentItem: SearchContent) {
        
        var text: String?
        
        var parentCategoryTitle: String?
        
        switch contentItem.type {

        case .searchHistory, .typedSearch:
            
            if let historyItem = contentItem.historyItem {
                switch historyItem.type {
                case .keyword:
                    text = historyItem.keyword 
                case .categoryId:
                    text = historyItem.title ?? ""
                    
                    parentCategoryTitle = historyItem.parentCategoryTitle
                }
            }

        case .suggestedSearch:
            text = contentItem.result?.title
            parentCategoryTitle = contentItem.result?.parentCategoryTitle
        }

        let formattedSearchResultText: String
        
        let parentCategoryLength: Int
        
        if let parentCategoryTitleUnwrpped = parentCategoryTitle, !parentCategoryTitleUnwrpped.isEmpty {
            // TODO: Localize this message
            if let existedText = text {
                text = existedText + " in"
            }
            
            formattedSearchResultText = (text ?? "")  + " " + parentCategoryTitleUnwrpped
            parentCategoryLength = parentCategoryTitleUnwrpped.count
            
        } else {
            formattedSearchResultText = text ?? ""
            parentCategoryLength = 0
        }
        
        let defaultAttributes = [NSAttributedStringKey.font: AppTheme.sharedInstance.searchResultTextFont,
                                 NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.searchResultTextColor]
        let arrtibutedString = NSMutableAttributedString(string: formattedSearchResultText, attributes: defaultAttributes)
        
        if parentCategoryLength > 0 {
            
            let range = NSRange(location: formattedSearchResultText.count - parentCategoryLength, length: parentCategoryLength)
            arrtibutedString.addAttributes([NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.searchResultParentTextColor, NSAttributedStringKey.font: AppTheme.sharedInstance.searchResultParentFont],
                                            range: range)
        }
        
        titleLabel?.attributedText = arrtibutedString
    }
}
