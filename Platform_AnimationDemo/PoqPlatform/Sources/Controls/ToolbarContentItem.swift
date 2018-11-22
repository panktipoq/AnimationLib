//
//  ToolbarContentButtonItem.swift
//  PoqPlatform
//
//  Created by GabrielMassana on 28/06/2017.
//
//

import Foundation
import PoqAnalytics

public protocol ToolbarContentItemType {
    var rawValue: String { get }
}

public struct ToolbarContentItem {
    
    public let type: ToolbarContentItemType
    public let isAvailable: Bool
    
    public let title: String
    public let position: Double
    
    public init(type: ToolbarContentItemType,
                isAvailable: Bool,
                title: String,
                position: Double) {
        
        self.type = type
        self.isAvailable = isAvailable
        self.title = title
        self.position = position
    }
}

public protocol ToolbarContentButtonItemDelegate: AnyObject {
    
    func toolbarContentButtonItem(_ item: ToolbarContentButtonItem, tappedForType type: ToolbarContentItemType)
}

public class ToolbarContentButtonItem: UIBarButtonItem {
    
    public let contentItem: ToolbarContentItem
    weak var delegate: ToolbarContentButtonItemDelegate?
    
    public init?(for item: ToolbarContentItem, style: UIBarButtonItemStyle = .plain, delegate: ToolbarContentButtonItemDelegate) {
        guard item.isAvailable else {
            return nil
        }
        
        self.contentItem = item
        
        super.init()
        
        self.delegate = delegate
        self.style = style
        
        title = item.title
        accessibilityIdentifier = "\(item.title)"
        target = self
        action = #selector(fireDelegate)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func fireDelegate() {
        delegate?.toolbarContentButtonItem(self, tappedForType: contentItem.type)
        PoqTrackerV2.shared.sortProducts(type: contentItem.type.rawValue)
    }
}
