//
//  SizeSelectorHeader.swift
//  Poq.iOS
//
//  Created by Jun Seki on 27/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

protocol SizeSelectorHeaderDelegate: class {
    
    func closeButtonTapped()
}

extension SizeSelectorHeaderDelegate where Self: UIViewController {
    
    func closeButtonTapped() {
        dismiss(animated: true)
    }
}

open class SizeSelectorHeader: UIView {
    
    weak var delegate: SizeSelectorHeaderDelegate?
    
    open var labelText: String?
    
    public init(frame: CGRect, headerTitle: String?) {
        super.init(frame: frame)
        labelText = headerTitle
        initSizeSelectorHeader()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSizeSelectorHeader()
    }
    
    func initSizeSelectorHeader() {
        
        let headerImageView = UIImageView(frame: bounds)
        let sizeSelectorHeaderImage: UIImage? = ImageInjectionResolver.loadImage(named: "SizeSelectorHeader")
        
        // Paintcode fully removed from Size Selector Header.
        // If your legacy project is still using aintcode to draw the image and the text, ask design to provide a background image.
        let headerLabel = UILabel(frame: bounds)
        headerLabel.textAlignment = .center
        headerLabel.textColor = AppTheme.sharedInstance.pdpSizeSelectorHeaderTextColor
        headerLabel.font = AppTheme.sharedInstance.pdpSizeSelectorHeader
        headerLabel.text = labelText
        
        addSubview(headerLabel)
        headerImageView.image = sizeSelectorHeaderImage
        insertSubview(headerImageView, at: 0)
        
        let closeButton = CloseButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        addSubview(closeButton)
        
        closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        closeButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor).isActive = true
    }
    
    @objc func closeButtonTapped() {
        delegate?.closeButtonTapped()
    }
}
