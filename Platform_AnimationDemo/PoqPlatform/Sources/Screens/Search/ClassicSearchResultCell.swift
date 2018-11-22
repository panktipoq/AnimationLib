//
//  SearchResultCell.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Gabriel Sabiescu on 1/30/17.
//
//

import PoqNetworking
import UIKit
import PoqUtilities

open class ClassicSearchResultCell: FullWidthAutoresizedCollectionCell {
    
    @IBOutlet weak open var solidLine: SolidLine?
        
    @IBOutlet weak open var titleLabel: UILabel? {
        didSet {
            titleLabel?.accessibilityLabel = AccessibilityLabels.searchResultLabel
            accessibilityLabel = AccessibilityLabels.searchResultCell
        }
    }
}

extension ClassicSearchResultCell: SearchCell {

    public func update(using contentItem: SearchContent) {
        switch contentItem.type {
        case .searchHistory:
            titleLabel?.text = contentItem.historyItem?.keyword ?? contentItem.historyItem?.title
            solidLine?.isHidden = titleLabel?.text?.isEmpty ?? true
        default:
            Log.debug("Classic search has no type \(contentItem.type)")
        }
    }
}
