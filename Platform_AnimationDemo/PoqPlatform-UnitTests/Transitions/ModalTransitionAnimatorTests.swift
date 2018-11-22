//
//  ModalTransitionAnimatorTests.swift
//  PoqPlatform-UnitTests
//
//  Created by GabrielMassana on 14/03/2018.
//

import XCTest

@testable import PoqPlatform

class ModalTransitionAnimatorTests: XCTestCase {

    let viewController = UIViewController()
    let scrollView = UITableView()
    
    let isDragable: Bool = true
    let directionBottom: ModalTransitonDirection = .bottom
    let directionRight: ModalTransitonDirection = .right
    let directionLeft: ModalTransitonDirection = .left
    let behindViewScale: CGFloat = 0.5
    let behindViewAlpha: CGFloat = 0.5
    let transitionDuration: TimeInterval = 0.5
    
    func test_ModalTransitionAnimator_exists() {
        
        let modalTransitionAnimator = ModalTransitionAnimator(withModalViewController: viewController)

        XCTAssertNotNil(modalTransitionAnimator, "ModalTransitionAnimator should not be nil")
    }
    
    func test_ModalTransitionAnimator_isDragable() {

        let modalTransitionAnimator = ModalTransitionAnimator(withModalViewController: viewController)
        modalTransitionAnimator.isDragable = isDragable

        XCTAssert(modalTransitionAnimator.isDragable == isDragable, "ModalTransitionAnimator with wrong isDragable")
    }

    func test_ModalTransitionAnimator_behindViewAlpha() {

        let modalTransitionAnimator = ModalTransitionAnimator(withModalViewController: viewController)
        modalTransitionAnimator.behindViewAlpha = behindViewAlpha

        XCTAssert(modalTransitionAnimator.behindViewAlpha == behindViewAlpha, "ModalTransitionAnimator with wrong behindViewAlpha")
    }

    func test_ModalTransitionAnimator_behindViewScale() {

        let modalTransitionAnimator = ModalTransitionAnimator(withModalViewController: viewController)
        modalTransitionAnimator.behindViewScale = behindViewScale

        XCTAssert(modalTransitionAnimator.behindViewScale == behindViewScale, "ModalTransitionAnimator with wrong behindViewScale")
    }

    func test_ModalTransitionAnimator_transitionDuration() {

        let modalTransitionAnimator = ModalTransitionAnimator(withModalViewController: viewController)
        modalTransitionAnimator.transitionDuration = transitionDuration

        XCTAssert(modalTransitionAnimator.transitionDuration == transitionDuration, "ModalTransitionAnimator with wrong transitionDuration")
    }

    func test_ModalTransitionAnimator_directionBottom() {

        let modalTransitionAnimator = ModalTransitionAnimator(withModalViewController: viewController)
        modalTransitionAnimator.direction = directionBottom

        XCTAssert(modalTransitionAnimator.direction == directionBottom, "ModalTransitionAnimator with wrong direction")
    }

    func test_ModalTransitionAnimator_directionLeft() {

        let modalTransitionAnimator = ModalTransitionAnimator(withModalViewController: viewController)
        modalTransitionAnimator.setContentScrollView(scrollView)
        modalTransitionAnimator.direction = directionLeft

        XCTAssert(modalTransitionAnimator.direction == directionLeft, "ModalTransitionAnimator with wrong direction")
    }

    func test_ModalTransitionAnimator_directionRight() {

        let modalTransitionAnimator = ModalTransitionAnimator(withModalViewController: viewController)
        modalTransitionAnimator.setContentScrollView(scrollView)
        modalTransitionAnimator.direction = directionRight

        XCTAssert(modalTransitionAnimator.direction == directionRight, "ModalTransitionAnimator with wrong direction")
    }

    func test_ModalTransitionAnimator_setContentScrollView() {

        let modalTransitionAnimator = ModalTransitionAnimator(withModalViewController: viewController)
        modalTransitionAnimator.direction = directionRight
        modalTransitionAnimator.isDragable = false
        modalTransitionAnimator.setContentScrollView(scrollView)

        XCTAssert(modalTransitionAnimator.direction == .bottom, "ModalTransitionAnimator with wrong direction")
        XCTAssert(modalTransitionAnimator.isDragable == true, "ModalTransitionAnimator isDragable should be true after scroll view is Set")
    }
}
