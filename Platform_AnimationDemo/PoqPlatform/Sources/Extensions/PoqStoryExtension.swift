//
//  PoqStoryExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 29/06/2016.
//
//

import Foundation
import PoqNetworking

extension PoqStory {
    
    /**
     Branded story support, we often need this specific block
     */
    public final func findBrandedHeader() -> PoqBlock? {
        guard let blocks: [PoqBlock] = contentBlocks else {
            return nil
        }
        var brandedHeader: PoqBlock?
        for block: PoqBlock in blocks {
            if block.type == PoqBlockType.brandHeader {
                brandedHeader = block
            
                break
            }
        }
        
        return brandedHeader
    }
}

