//
//  MaterialDesignSpinnerTests.swift
//  PoqPlatform-UnitTests
//
//  Created by GabrielMassana on 17/04/2018.
//

import XCTest

@testable import PoqPlatform

class MaterialDesignSpinnerTests: XCTestCase {
    
    let spinnerFrame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
    let lineWidth: CGFloat = 5.0
    let hidesWhenStoppedTrue: Bool = true
    let hidesWhenStoppedFalse: Bool = false
    let tintColor = UIColor.red
    let duration: TimeInterval = 5.0
    let lineCap: String = kCALineCapSquare
    
    func test_MaterialDesignSpinner_exists() {

        let materialDesignSpinner = MaterialDesignSpinner(frame: spinnerFrame)

        XCTAssertNotNil(materialDesignSpinner, "MaterialDesignSpinner should not be nil")
    }

    func test_MaterialDesignSpinner_size() {

        let materialDesignSpinner = MaterialDesignSpinner(frame: spinnerFrame)

        XCTAssert((materialDesignSpinner.bounds.width == spinnerFrame.width) && (materialDesignSpinner.bounds.height == spinnerFrame.height), "MaterialDesignSpinner with wrong bounds")
    }

    func test_MaterialDesignSpinner_lineWidth() {

        let materialDesignSpinner = MaterialDesignSpinner(frame: spinnerFrame)
        materialDesignSpinner.lineWidth = lineWidth

        XCTAssert(materialDesignSpinner.progressLayer.lineWidth == lineWidth, "MaterialDesignSpinner with wrong lineWidth")
    }

    func test_MaterialDesignSpinner_hidesWhenStoppedFalse() {

        let materialDesignSpinner = MaterialDesignSpinner(frame: spinnerFrame)
        materialDesignSpinner.hidesWhenStopped = hidesWhenStoppedFalse

        XCTAssert(materialDesignSpinner.hidesWhenStopped == hidesWhenStoppedFalse, "MaterialDesignSpinner with wrong hidesWhenStopped")
    }

    func test_MaterialDesignSpinner_isNotHidden_startAnimating() {

        let materialDesignSpinner = MaterialDesignSpinner(frame: spinnerFrame)
        materialDesignSpinner.hidesWhenStopped = hidesWhenStoppedTrue
        materialDesignSpinner.isHidden = true
        materialDesignSpinner.startAnimating()

        XCTAssert(materialDesignSpinner.isHidden == false, "MaterialDesignSpinner should be not hidden")
    }

    func test_MaterialDesignSpinner_isHidden_stopAnimating() {

        let materialDesignSpinner = MaterialDesignSpinner(frame: spinnerFrame)
        materialDesignSpinner.hidesWhenStopped = hidesWhenStoppedTrue
        materialDesignSpinner.isHidden = false
        materialDesignSpinner.stopAnimating()

        XCTAssert(materialDesignSpinner.isHidden == true, "MaterialDesignSpinner should be hidden")
    }

    func test_MaterialDesignSpinner_tintColor() {

        let materialDesignSpinner = MaterialDesignSpinner(frame: spinnerFrame)
        materialDesignSpinner.tintColor = tintColor

        XCTAssert(materialDesignSpinner.tintColor == tintColor, "MaterialDesignSpinner with wrong tintColor")
    }

    func test_MaterialDesignSpinner_duration() {

        let materialDesignSpinner = MaterialDesignSpinner(frame: spinnerFrame)
        materialDesignSpinner.duration = duration

        XCTAssert(materialDesignSpinner.duration == duration, "MaterialDesignSpinner with wrong duration")
    }

    func test_MaterialDesignSpinner_lineCap() {

        let materialDesignSpinner = MaterialDesignSpinner(frame: spinnerFrame)
        materialDesignSpinner.lineCap = lineCap

        XCTAssert(materialDesignSpinner.lineCap == lineCap, "MaterialDesignSpinner with wrong lineCap")
    }
}
