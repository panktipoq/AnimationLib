//
//  PoqMyProfileListContentItem.swift
//  Poq.iOS.HollandAndBarrett
//
//  Created by Gabriel Sabiescu on 20/01/2017.
//
//

import PoqNetworking
import UIKit

public protocol PoqMyProfileListReusableView: PoqReusableView {
    
    var presenter: PoqMyProfileListPresenter? { get set }

    func setup(using content: PoqMyProfileListContentItem, cellPresenter: PoqMyProfileListPresenter)
}

extension PoqBlockType {
    
    var cellClass: UICollectionViewCell.Type {
        switch self {
        case .title:
            return MyProfileTitleViewCell.self
        case .link:
            return MyProfileLinkViewCell.self
        case .actionButton:
            return MyProfileActionButtonViewCell.self
        case .seperator:
            return MyProfileSeperatorViewCell.self
        case .welcome:
            return MyProfileWelcomeViewCell.self
        case .banner:
            return MyProfileBannerBlockCell.self
        case .landing:
            return MyProfilePlatformLoginViewCell.self
        case .brandHeader:
            return MyProfileSeperatorViewCell.self
        case .card:
            return MyProfileSeperatorViewCell.self
        case .favouriteStore:
            return MyProfileStoreViewCell.self
        default:
            return NotFoundContentCollectionViewCell.self
        }
    }
}

public struct PoqMyProfileListContentItem {
    
    public var cellClass: UICollectionViewCell.Type?
    public var block: PoqBlock?
    public var account: PoqAccount?
    
    public init(block: PoqBlock, account: PoqAccount? = nil) {
        
        guard let validBlockType = block.type else {
            return
        }
        
        self.cellClass = validBlockType.cellClass
        self.block = block
        self.account = account
    }
    
    public init(cellClass: UICollectionViewCell.Type, account: PoqAccount?, block: PoqBlock? = nil) {
        self.cellClass = cellClass
        self.block = block
        self.account = account
    }
}
