//
//  AppStoryViewModelTests.swift
//  PoqDemoApp-UITests
//
//  Created by Nikolay Dzhulay on 9/20/17.
//

import XCTest

@testable import PoqDemoApp
@testable import PoqNetworking
@testable import PoqPlatform

class AppStoryViewModelTests: XCTestCase {
    
    override var resourcesBundleName: String {
        return "AppStoriesTests"
    }
    
    func testProductsItemType() {
        let stories = responseObject(forJson: "Full", ofType: PoqAppStoryResponse.self)?.stories ?? []
        XCTAssertEqual(stories.count, 5, "We should parse 5 stories")
        XCTAssertEqual(stories[1].cards.count, 2, "Second story should have 2 cards")
        
        let appStoryModel = AppStoryViewModel(with: stories[1])
        
        XCTAssertTrue(appStoryModel.content.count == 2, "View model should have 2 items")
        
        guard case .pdp(_) = appStoryModel.content[0].swipeUpAction else {
            XCTAssert(false, "First item action should be pdp")
            return
        }
        
        guard case .plp(_) = appStoryModel.content[1].swipeUpAction else {
            XCTAssert(false, "Secon item action should be plp")
            return
        }
    }
    
    func testWeblinkItemType() {
        let stories = responseObject(forJson: "Full", ofType: PoqAppStoryResponse.self)?.stories ?? []
        XCTAssertTrue(stories.count == 5, "We should parse 5 stories")
        XCTAssertTrue(stories[2].cards.count == 2, "Second story should have 2 cards")
        
        let story = stories[2]
        let appStoryModel = AppStoryViewModel(with: story)
        
        XCTAssertTrue(appStoryModel.content.count == 2, "View model should have 2 items")
        
        guard case .web( let url) = appStoryModel.content[0].swipeUpAction else {
            XCTAssert(false, "First item action should be web")
            return
        }
        
        guard case .weblink(let initialUrl) = story.cards[0].type, initialUrl == url else {
            XCTAssert(false, "Incorrect web url")
            return
        }
    }
    
    func testNoActionItemType() {
        let stories = responseObject(forJson: "Full", ofType: PoqAppStoryResponse.self)?.stories ?? []
        XCTAssertTrue(stories.count == 5, "We should parse 5 stories")
        XCTAssertTrue(stories[1].cards.count == 2, "Second story should have 2 cards")
        
        let story = stories[0]
        let appStoryModel = AppStoryViewModel(with: story)
        
        XCTAssertTrue(appStoryModel.content.count == 2, "View model should have 2 items")
        
        guard case .none = appStoryModel.content[0].swipeUpAction else {
            XCTAssert(false, "First item action should be .none")
            return
        }
    }
    
    func testVideoItemType() {
        let stories = responseObject(forJson: "Full", ofType: PoqAppStoryResponse.self)?.stories ?? []
        XCTAssertTrue(stories.count == 5, "We should parse 5 stories")
        XCTAssertTrue(stories[1].cards.count == 2, "Second story should have 2 cards")
        
        let story = stories[2]
        let appStoryModel = AppStoryViewModel(with: story)
        
        XCTAssertTrue(appStoryModel.content.count == 2, "View model should have 2 items")
        
        guard case .video( let url) = appStoryModel.content[1].swipeUpAction else {
            XCTAssert(false, "First item action should be video")
            return
        }
        
        guard case .video(let initialUrl) = story.cards[1].type, initialUrl == url else {
            XCTAssert(false, "Incorrect video url")
            return
        }
    }

}
