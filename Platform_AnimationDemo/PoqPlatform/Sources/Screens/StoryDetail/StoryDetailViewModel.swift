//
//  BrandLandingViewModel.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 01/06/2016.
//
//

import Foundation
import PoqNetworking

class StoryDetailViewModel: BaseViewModel {
    
    // If story contains brand header we will separate from other block - it must be on top and stick
    var brandedHeader: PoqBlock?
    var sectionBlocks: [PoqBlock] = []
    var story: PoqStory?
    
    init(viewControllerDelegate: PoqBaseViewController, storyId: Int) {
        
        super.init(viewControllerDelegate: viewControllerDelegate)
        
        PoqNetworkService(networkTaskDelegate: self).getStoryDetail(storyId)
    }
    
    // MARK: NETWORK
    override func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        super.networkTaskDidComplete(networkTaskType, result: result)

        if let existedStory: PoqStory = result?.first as? PoqStory {
            story = existedStory
            
            
            if let blocks: [PoqBlock] = existedStory.contentBlocks {
                let headerIndex: Int? = blocks.index(where: {
                    (block: PoqBlock) -> Bool in
                    
                    guard let validType = block.type else {
                        return false
                    }
                    return validType == PoqBlockType.brandHeader
                })
                
                if let index = headerIndex {
                    var newBlocks: [PoqBlock] = blocks
                    brandedHeader = newBlocks.remove(at: index)
                    sectionBlocks = newBlocks
                } else {
                    sectionBlocks = blocks
                }
            }
        }

        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
}

