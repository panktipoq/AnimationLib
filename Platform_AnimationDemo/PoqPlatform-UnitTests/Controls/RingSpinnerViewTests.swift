//
//  RingSpinnerViewTests.swift
//  PoqDemoApp
//
//  Created by GabrielMassana on 17/04/2018.
//

import XCTest

@testable import PoqPlatform

class RingSpinnerViewTests: XCTestCase {
    
    let ringSpinnerFrame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
    let lineWidth: CGFloat = 5.0
    let hidesWhenStoppedTrue: Bool = true
    let hidesWhenStoppedFalse: Bool = false
    let tintColor = UIColor.red

    func test_RingSpinnerView_exists() {

        let ringSpinnerView = RingSpinnerView(frame: ringSpinnerFrame)

        XCTAssertNotNil(ringSpinnerView, "RingSpinnerView should not be nil")
    }
    
    func test_RingSpinnerView_size() {

        let ringSpinnerView = RingSpinnerView(frame: ringSpinnerFrame)

        XCTAssert((ringSpinnerView.bounds.width == ringSpinnerFrame.width) && (ringSpinnerView.bounds.height == ringSpinnerFrame.height), "RingSpinnerView with wrong bounds")
    }

    func test_RingSpinnerView_lineWidth() {

        let ringSpinnerView = RingSpinnerView(frame: ringSpinnerFrame)
        ringSpinnerView.lineWidth = lineWidth

        XCTAssert(ringSpinnerView.progressLayer.lineWidth == lineWidth, "RingSpinnerView with wrong lineWidth")
    }

    func test_RingSpinnerView_hidesWhenStoppedFalse() {

        let ringSpinnerView = RingSpinnerView(frame: ringSpinnerFrame)
        ringSpinnerView.hidesWhenStopped = hidesWhenStoppedFalse

        XCTAssert(ringSpinnerView.hidesWhenStopped == hidesWhenStoppedFalse, "RingSpinnerView with wrong hidesWhenStopped")
    }

    func test_RingSpinnerView_isNotHidden_startAnimating() {

        let ringSpinnerView = RingSpinnerView(frame: ringSpinnerFrame)
        ringSpinnerView.hidesWhenStopped = hidesWhenStoppedTrue
        ringSpinnerView.isHidden = true
        ringSpinnerView.startAnimating()

        XCTAssert(ringSpinnerView.isHidden == false, "RingSpinnerView should be not hidden")
    }

    func test_RingSpinnerView_isHidden_stopAnimating() {

        let ringSpinnerView = RingSpinnerView(frame: ringSpinnerFrame)
        ringSpinnerView.hidesWhenStopped = hidesWhenStoppedTrue
        ringSpinnerView.startAnimating()
        ringSpinnerView.isHidden = false
        ringSpinnerView.stopAnimating()

        XCTAssert(ringSpinnerView.isHidden == true, "RingSpinnerView should be hidden")
    }

    func test_RingSpinnerView_tintColor() {

        let ringSpinnerView = RingSpinnerView(frame: ringSpinnerFrame)
        ringSpinnerView.tintColor = tintColor

        XCTAssert(ringSpinnerView.tintColor == tintColor, "RingSpinnerView with wrong tintColor")
    }
}
