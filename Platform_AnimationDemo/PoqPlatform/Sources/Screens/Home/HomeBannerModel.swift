//
//  PoqHomeBannerExtension.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 11/29/16.
//
//

import Foundation
import PoqNetworking

public struct HomeContent {
    let identifier: String
    var bannerItem: HomeBannerItem?
}

public enum StoryCarouselType {
    case card
    case circular
}

public enum HomeBannerItemType {
    case firstTimePlatformLogin
    case firstTimeCustomerLogin
    case imageBanner
    case gif
    case stories(appStories: [PoqAppStory], storyType: StoryCarouselType)
}

public extension HomeBannerItemType {

    /// Depends on data inside return proper cell, for example: image or gif
    public var cellIdentifier: String {
        switch self {
        case .firstTimePlatformLogin: 
            return MyProfilePlatformLoginViewCell.poqReuseIdentifier
        case .firstTimeCustomerLogin: 
            return MyProfileLoginViewCell.poqReuseIdentifier
        case .imageBanner:
            return BannerCell.poqReuseIdentifier
        case .gif:
            return GifBannerCell.poqReuseIdentifier
        case .stories:
            return AppStoriesCarouselCell.poqReuseIdentifier
        }
    }
    
    public var typeIdentifier: String {
        switch self {
        case .firstTimePlatformLogin:
            return "firstTimePlatformLogin"
        case .firstTimeCustomerLogin:
            return "firstTimeCustomerLogin"
        case .imageBanner:
            return "imageBanner"
        case .gif:
            return "gif"
        case .stories:
            return "stories"
        }
    }
}

public struct HomeBannerItem {
    public let type: HomeBannerItemType
    public let poqHomeBanner: PoqHomeBanner?
}
