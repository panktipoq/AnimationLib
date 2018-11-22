//
//  StarRatingViewTests.swift
//  PoqPlatform-UnitTests
//
//  Created by GabrielMassana on 08/03/2018.
//

import XCTest

@testable import PoqPlatform

class StarRatingViewTests: XCTestCase {
    
    let starSizeSmall = CGSize(width: 15.0, height: 15.0)
    let starSizeLarge = CGSize(width: 22.0, height: 22.0)
    let numberOfStarsFive = 5
    let numberOfStarsTen = 10
    let rating: Float = 2.5
    let fillColor = UIColor.purple
    let unfilledColor = UIColor.yellow
    let strokeColor = UIColor.orange
    
    func test_StarRatingView_exists() {
        
        let starRatingView = StarRatingView(
            starSize: starSizeSmall,
            numberOfStars: numberOfStarsFive,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )
        
        XCTAssertNotNil(starRatingView, "StarRatingView should not be nil")
    }
    
    func test_StarRatingView_starSize() {

        let starRatingView = StarRatingView(
            starSize: starSizeSmall,
            numberOfStars: numberOfStarsFive,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )
        
        XCTAssert((starRatingView.starSize.width == starSizeSmall.width) && (starRatingView.starSize.height == starSizeSmall.height), "StarRatingView with wrong starSize")
    }

    func test_StarRatingView_numberOfStars() {

        let starRatingView = StarRatingView(
            starSize: starSizeSmall,
            numberOfStars: numberOfStarsFive,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )

        XCTAssert(starRatingView.numberOfStars == numberOfStarsFive, "StarRatingView with wrong numberOfStars")
    }

    func test_StarRatingView_rating() {

        let starRatingView = StarRatingView(
            starSize: starSizeSmall,
            numberOfStars: numberOfStarsFive,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )

        XCTAssert(starRatingView.rating == rating, "StarRatingView with wrong rating")
    }

    func test_StarRatingView_fillColor() {

        let starRatingView = StarRatingView(
            starSize: starSizeSmall,
            numberOfStars: numberOfStarsFive,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )

        XCTAssert(starRatingView.fillColor == fillColor, "StarRatingView with wrong fillColor")
    }

    func test_StarRatingView_unfilledColor() {

        let starRatingView = StarRatingView(
            starSize: starSizeSmall,
            numberOfStars: numberOfStarsFive,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )

        XCTAssert(starRatingView.unfilledColor == unfilledColor, "StarRatingView with wrong unfilledColor")
    }

    func test_StarRatingView_strokeColor() {

        let starRatingView = StarRatingView(
            starSize: starSizeSmall,
            numberOfStars: numberOfStarsFive,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )

        XCTAssert(starRatingView.strokeColor == strokeColor, "StarRatingView with wrong strokeColor")
    }

    func test_StarRatingView_different() {

        let starRatingViewFive = StarRatingView(
            starSize: starSizeSmall,
            numberOfStars: numberOfStarsFive,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )

        let starRatingViewTen = StarRatingView(
            starSize: starSizeLarge,
            numberOfStars: numberOfStarsTen,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )

        XCTAssertNotEqual(starRatingViewFive, starRatingViewTen, "StarRatingViews should be different")
    }

    func test_StarRatingView_sizeBigger_starSize() {

        let starRatingViewSmall = StarRatingView(
            starSize: starSizeSmall,
            numberOfStars: numberOfStarsFive,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )

        let starRatingViewLarge = StarRatingView(
            starSize: starSizeLarge,
            numberOfStars: numberOfStarsFive,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )

        XCTAssertNotEqual(starRatingViewSmall.frame.width, starRatingViewLarge.frame.width, "StarRatingViews width should be different")
        XCTAssertNotEqual(starRatingViewSmall.frame.height, starRatingViewLarge.frame.height, "StarRatingViews height should be different")
    }

    func test_StarRatingView_sizeBigger_numberOfStars() {

        let starRatingViewFive = StarRatingView(
            starSize: starSizeSmall,
            numberOfStars: numberOfStarsFive,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )

        let starRatingViewTen = StarRatingView(
            starSize: starSizeSmall,
            numberOfStars: numberOfStarsTen,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )

        XCTAssertNotEqual(starRatingViewFive.frame.width, starRatingViewTen.frame.width, "StarRatingViews width should be different")
        XCTAssertEqual(starRatingViewFive.frame.height, starRatingViewTen.frame.height, "StarRatingViews height should be the same")
    }
    
    func test_StarRatingView_invalidateIntrinsicContentSize() {
        
        let starRatingView = StarRatingView(
            starSize: starSizeSmall,
            numberOfStars: numberOfStarsFive,
            rating: rating,
            fillColor: fillColor,
            unfilledColor: unfilledColor,
            strokeColor: strokeColor
        )
        
        let five = starRatingView.intrinsicContentSize.width
        starRatingView.numberOfStars = numberOfStarsTen
        let ten = starRatingView.intrinsicContentSize.width

        XCTAssertNotEqual(five, ten, "StarRatingViews width should be different because intrinsicContentSize was invalidated")
    }
}
