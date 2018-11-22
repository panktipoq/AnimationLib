//
//  AppStoryViewModel.swift
//  PoqDemoApp
//
//  Created by Nikolay Dzhulay on 9/13/17.
//

import Foundation
import PoqNetworking

public enum SwipeUpAction {
    case none
    case plp(AppStoryCardProductListViewModel)
    case pdp(AppStoryCardProductInfoViewModel)
    case video(URL)
    case web(URL)
}

public struct StoryContentItem {
    public let storyCardController: AppStoryCardViewController
    public let swipeUpAction: SwipeUpAction
    public let card: PoqAppStoryCard
}

public class AppStoryViewModel {
    
    public var content = [StoryContentItem]()
    
    public init(with story: PoqAppStory) {
        
        for card in story.cards {
            let cardViewController = AppStoryCardViewController(with: card)
            
            let action: SwipeUpAction
            
            switch card.type {
            case .default:
                action = .none

            case .products(let productIds):
                let viewModel = AppStoryCardProductListViewModel(with: card)
                if productIds.count > 1 {
                    
                    action = .plp(viewModel)
                } else {
                    
                    let viewModel = AppStoryCardProductInfoViewModel(with: productIds[0])
                    action = .pdp(viewModel)
                }
                
            case .weblink(let url):
                action = .web(url)
                
            case .video(let url):
                action = .video(url)
            }

            let contentItem = StoryContentItem(storyCardController: cardViewController, swipeUpAction: action, card: card)
            
            content.append(contentItem)
        }
    }
}
