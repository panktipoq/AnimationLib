//
//  ProductDescriptionViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 03/06/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

public class ProductDescriptionViewCell: UITableViewCell {
    
    // MARK: - Properties

    @IBOutlet public weak var descriptionLabel: UILabel!
    
    weak public var productDetailViewDelegate: ProductDetailViewDelegate?
    
    public var product: PoqProduct?
    
    public let productDescriptionLineSpacing = CGFloat(AppTheme.sharedInstance.pdpProductDescriptionLineSpacing)

    // MARK: - AwakeFromNib

    override public func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Add click event
        let cellClickGesture = UITapGestureRecognizer(target: self, action: #selector(ProductDescriptionViewCell.cellClicked(_:)))
        self.addGestureRecognizer(cellClickGesture)
        
        // Set default font
        descriptionLabel.font = AppTheme.sharedInstance.pdpDescriptionLabelFont
        descriptionLabel.textColor = AppTheme.sharedInstance.pdpDescriptionLabelColor
        
        createAccessoryView()
    }
    
    // MARK: - Setup
    
    public func setup(using product: PoqProduct) {

        self.product = product

        guard var productDescription = product.description else {
            
            return
        }
        
        let headline = AppLocalization.sharedInstance.pdpProductDescriptionHeadline
        
        // Setup descriptionLabel text depending if we have or not headline text
        
        var attributedText: NSMutableAttributedString?
        
        if headline.count > 0 {
            
            attributedText = descriptionSetupWithHeadline(using: productDescription,
                                                              headline: headline)
        } else {
            
            attributedText = descriptionSetupWithoutHeadline(using: productDescription)
        }
        
        descriptionLabel?.attributedText = attributedText

        // Use full text to calculate heigt for the text
        if let descriptionLabel = descriptionLabel,
            let attributedText = descriptionLabel.attributedText {
            
            productDescription = attributedText.string
        }
        
        // Calculate required heigt for the text
        let requiredHeight = heightForTextView(productDescription,
                                               font: descriptionLabel.font,
                                               width: descriptionLabel.bounds.size.width)
        
        // Hide right arrow indicator if text is short
        if requiredHeight < AppSettings.sharedInstance.productDescriptionCellHeight {
            
            accessoryView = nil
            selectionStyle = UITableViewCellSelectionStyle.none
        }
    }
    
    // MARK: - DescriptionSetup
    
    /**
     Setup Descriction Label with a headline.
     
     - parameter productDescription: product description text
     - parameter headline: headline text
     
     - returns: a formatted attributed string.
     */
    public func descriptionSetupWithHeadline(using productDescription: String, headline: String) -> NSMutableAttributedString {
        
        // Paragraph Style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = productDescriptionLineSpacing
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        // Attributed Strings
        let attributedDescription = NSMutableAttributedString(string: productDescription)
        let breakline = NSMutableAttributedString(string: "\n")
        let attributedHeadline = NSMutableAttributedString(string: headline)
        
        // Fonts
        let headlineFont = AppTheme.sharedInstance.pdpProductDescriptionCellHeadlineFont
        let productDescriptionFont = AppTheme.sharedInstance.pdpProductDescriptionCellDescriptionFont
        
        // Update attributed text
        attributedDescription.addAttributes([NSAttributedStringKey.font: productDescriptionFont],
                                            range: NSRange(location: 0, length: attributedDescription.length))
        attributedHeadline.addAttributes([NSAttributedStringKey.font: headlineFont],
                                         range: NSRange(location: 0, length: attributedHeadline.length))
        
        // Append Attributed Strings
        attributedHeadline.append(breakline)
        attributedHeadline.append(attributedDescription)
        
        // Update attributed text
        attributedHeadline.addAttribute(NSAttributedStringKey.paragraphStyle,
                                        value: paragraphStyle,
                                        range: NSRange(location: 0, length: attributedHeadline.length))
        
        return attributedHeadline
    }

    /**
     Setup Descriction Label.
     
     - parameter productDescription: product description text
     
     - returns: a formatted attributed string.
     */
    public func descriptionSetupWithoutHeadline(using productDescription: String) -> NSMutableAttributedString {
        
        // Paragraph Style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = productDescriptionLineSpacing
        
        // Attributed String
        let attributedDescription = NSMutableAttributedString(string: productDescription)

        // Font
        let productDescriptionFont = AppTheme.sharedInstance.pdpProductDescriptionCellDescriptionFont
        
        // Update attributed text
        attributedDescription.addAttributes([NSAttributedStringKey.font: productDescriptionFont],
                                            range: NSRange(location: 0, length: attributedDescription.length))
        
        attributedDescription.addAttribute(NSAttributedStringKey.paragraphStyle,
                                           value: paragraphStyle,
                                           range: NSRange(location: 0, length: attributedDescription.length))
        
        return attributedDescription
    }
    
    // MARK: - Actions

    @objc public func cellClicked(_ gesture: UIGestureRecognizer) {
        
        if let descriptionDelegate = productDetailViewDelegate {
            
            // Discloure indicator is nil when text is not too long
            // So no need to public description view again
            if let accessoryView = self.accessoryView, accessoryView.isKind(of: DisclosureIndicator.self) {
                descriptionDelegate.descriptionClicked()
            }
        }
    }
    
    // MARK: - HeightForTextView

    public func heightForTextView(_ text: String, font: UIFont, width: CGFloat) -> CGFloat {
        
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: width, height: CGFloat.greatestFiniteMagnitude))
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        // Add 20 for top bottom padding
        return label.frame.height + 20
    }
}
