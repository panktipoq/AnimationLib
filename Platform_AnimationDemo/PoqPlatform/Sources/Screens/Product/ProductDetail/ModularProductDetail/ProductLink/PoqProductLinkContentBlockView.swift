//
//  PoqProductLinkContentBlockView.swift
//  Poq.iOS.Platform
//
//  Created by Manuel Marcos Regalado on 20/02/2017.
//
//

import Foundation
import PoqModuling
import PoqNetworking
import PoqUtilities

open class PoqProductLinkContentBlockView: FullWidthAutoresizedCollectionCell, PoqProductDetailCell, PoqLinkBlock {
    
    weak open var presenter: PoqProductBlockPresenter?
    var product: PoqProduct?
    
    @IBOutlet weak var linkButton: UIButton? {
        didSet {
            linkButton?.isAccessibilityElement = true
            linkButton?.accessibilityIdentifier = AccessibilityLabels.pdpSizeGuide
        }
    }
    @IBOutlet weak var linkLabel: UILabel?
    @IBOutlet weak var disclosureAccessoryImageView: DisclosureIndicator?
    @IBOutlet public weak var separator: SolidLine?
    open var content: PoqProductDetailContentItem?
    
    // MARK: - Content Setup
    
    open func setup(using content: PoqProductDetailContentItem, with product: PoqProduct?) {
        linkLabel?.text = content.title
        linkLabel?.font = AppTheme.sharedInstance.pdpSizeGuideLabelFont
        linkLabel?.textColor = AppTheme.sharedInstance.pdpSizeGuideLabelColor
        self.content = content
    }
    
    @IBAction open func linkTapped(_ sender: Any) {
        
        guard let contentItemType = content?.cellType as? PoqProductDetailCellType else {
            Log.error("Wrong cell type provided.")
            return
        }
        
        guard case PoqProductDetailCellType.link(let link) = contentItemType else {
            Log.error("Wrong cell type provided.")
            return
        }
        
        openLink(link)
    }
}
