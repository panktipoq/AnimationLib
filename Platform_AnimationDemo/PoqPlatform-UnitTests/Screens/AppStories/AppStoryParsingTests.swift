//
//  AppStoryParsingTests.swift
//  PoqDemoApp-UnitTests
//
//  Created by Nikolay Dzhulay on 9/25/17.
//

import XCTest

@testable import PoqDemoApp
@testable import PoqNetworking
@testable import PoqPlatform

class AppStoryParsingTests: XCTestCase {
    
    override var resourcesBundleName: String {
        return "AppStoriesTests"
    }
    
    /// Test that type of stories correctly parsed
    func testStoriesTypeParsing() {
        let stories = responseObject(forJson: "AllTypes", ofType: PoqAppStoryResponse.self)?.stories ?? []
        XCTAssert(stories.count == 2)
        
        let story = stories[0]
        
        // check valid cards
        XCTAssert(story.cards.count == 4)
        
        switch story.cards[0].type {
        case .default:
            break
        default:
            XCTAssert(false, "Wrong card 0 type")
        }
        
        switch story.cards[1].type {
        case .products(let productIds):
            XCTAssert(productIds.count == 2)
            break
        default:
            XCTAssert(false, "Wrong card 1 type")
        }
        
        switch story.cards[2].type {
        case .weblink(let url):
            XCTAssert(url.absoluteString == "https://poquat.blob.core.windows.net/app173/11267334-1.jpg?v=131497037806700000")
            break
        default:
            XCTAssert(false, "Wrong card 2 type")
        }
        
        switch story.cards[3].type {
        case .video(let url):
            XCTAssert(url.absoluteString == "http://techslides.com/demos/sample-videos/small.mp4")
            break
        default:
            XCTAssert(false, "Wrong card 3 type")
        }
    }

    /// Test that type of stories correctly parsed and validated
    /// For example, if response type "Video" but there is no video link - we drop to default type
    func testIncorrectStoriesTypeParsing() {
        let stories = responseObject(forJson: "AllTypes", ofType: PoqAppStoryResponse.self)?.stories ?? []
        XCTAssert(stories.count == 2)
        
        let story = stories[1]
        
        // check valid cards
        XCTAssert(story.cards.count == 4)
        
        switch story.cards[0].type {
        case .default:
            break
        default:
            XCTAssert(false, "Wrong card 0 type")
        }
        
        switch story.cards[1].type {
        case .default:
            break
        default:
            XCTAssert(false, "Wrong card 1 type")
        }
        
        switch story.cards[2].type {
        case .default:
            break
        default:
            XCTAssert(false, "Wrong card 2 type")
        }
        
        switch story.cards[3].type {
        case .default:
            break
        default:
            XCTAssert(false, "Wrong card 3 type")
        }
    }
    
    
}
