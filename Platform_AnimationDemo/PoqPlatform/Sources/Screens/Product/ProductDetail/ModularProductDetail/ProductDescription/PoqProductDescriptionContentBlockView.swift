//
//  PoqProductDescriptionContentBlockView.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/6/17.
//
//

import Foundation
import PoqNetworking

private let VerticalLabelsIndent: CGFloat = 8

open class PoqProductDescriptionContentBlockView: FullWidthAutoresizedCollectionCell, PoqProductDetailCell {

    @IBOutlet open weak var titleLabel: UILabel?
    @IBOutlet open weak var descriptionLabel: UILabel? {
        didSet {
            descriptionLabel?.isAccessibilityElement = true
            descriptionLabel?.accessibilityIdentifier = AccessibilityLabels.pdpDescription
            
        }
    }
    
    @IBOutlet open weak var verticalDistanceConstraint: NSLayoutConstraint?
    
    @IBOutlet open weak var disclosureIndicator: DisclosureIndicator?
    
    @IBOutlet public weak var separator: SolidLine?
    
    open var content: PoqProductDetailContentItem?

    weak open var presenter: PoqProductBlockPresenter?
    
    override open func awakeFromNib() {
        
        super.awakeFromNib()

        titleLabel?.font = AppTheme.sharedInstance.pdpDescriptionTitleLabelFont
        titleLabel?.textColor = AppTheme.sharedInstance.pdpDescriptionTitleLabelColor
        
        descriptionLabel?.font = AppTheme.sharedInstance.pdpDescriptionLabelFont
        descriptionLabel?.textColor = AppTheme.sharedInstance.pdpDescriptionLabelColor
        
        descriptionLabel?.numberOfLines = Int(AppSettings.sharedInstance.modularPdpDescriptionBlockLinesLimit)

    }

    // MARK: PoqProductDetailResuableView

    open func setup(using content: PoqProductDetailContentItem, with product: PoqProduct?) {
        
        self.content = content
        
        titleLabel?.text = content.title
        titleLabel?.accessibilityIdentifier = AccessibilityLabels.pdpProductDescription
        descriptionLabel?.text = content.description
        
        // in case if any line is empty we will show no additional gap
        if let title = content.title, let description = content.description, !title.isEmpty && !description.isEmpty {
            verticalDistanceConstraint?.constant = VerticalLabelsIndent
        } else {
            verticalDistanceConstraint?.constant = 0
        }
    }
    
}
