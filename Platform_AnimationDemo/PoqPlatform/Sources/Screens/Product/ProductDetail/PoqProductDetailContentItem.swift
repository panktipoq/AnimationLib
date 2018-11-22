//
//  PoqProductDetailContentItem.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Mahmut Canga on 24/12/2016.
//
//

import Foundation
import PoqNetworking

public protocol PoqProductDetailCell: PoqReusableView {
    
    var separator: SolidLine? { get }
    
    var presenter: PoqProductBlockPresenter? { get set }
    func setup(using content: PoqProductDetailContentItem, with product: PoqProduct?)
}

public protocol PoqProductDetailCellTypeProvider {
    var cellClass: UICollectionViewCell.Type { get }
}

public enum PoqProductDetailCellType: PoqProductDetailCellTypeProvider {
    
    case info(imageViewContentMode: UIViewContentMode)
    case promotion
    case colors
    case htmlDescription(htmlBody: String)
    case buttonLink(link: String)
    case link(link: String)
    case sizes
    case share
    case action(action: () -> Void)
    
    public var cellClass: UICollectionViewCell.Type {
        switch self {
        case .info:
            return PoqProductInfoContentBlockView.self
            
        case .colors:
            return PoqProductSwatchColorsContentBlockView.self
            
        case .promotion:
            return PoqProductPromotionContentBlockView.self
            
        case .htmlDescription:
            return PoqProductDescriptionContentBlockView.self
            
        case .buttonLink:
            return PoqProductActionContentBlockView.self
            
        case .link:
            return PoqProductLinkContentBlockView.self

        case .sizes:
            return PoqProductSizesContentBlockView.self

        case .share:
            return PoqProductShareContentBlockView.self
            
        case .action:
            return PoqProductActionContentBlockView.self
        }
    }
}

public struct PoqProductDetailContentItem {
    
    public var cellType: PoqProductDetailCellTypeProvider
    
    /// Presentation for element with 2 text slots, not necessary they had 'title'  and 'description' meaning
    /// Usage of this value are contextual
    public var title: String?
    public var description: String?
    
    /// Block should be called if sizes/constrains changed
    public var invalidateCellBlock: (() -> Void)?
    
    public init(type: PoqProductDetailCellTypeProvider, title: String? = nil, description: String? = nil) {
        self.cellType = type
        self.title = title
        self.description = description
    }
}

// MARK: - Default implementations

extension PoqProductDetailCell where Self: UICollectionViewCell {
    
    public weak var separator: SolidLine? {
        for view in contentView.subviews {
            if let solidLine = view as? SolidLine {
                return solidLine
            }
        }
        return nil
    }
}
