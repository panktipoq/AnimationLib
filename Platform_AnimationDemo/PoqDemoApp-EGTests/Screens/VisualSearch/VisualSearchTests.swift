//
//  VisualSearchTests.swift
//  Poq.iOS.Platform
//
//  Created by Manuel Marcos Regalado on 28/02/2018.
//

import EarlGrey
import XCTest

@testable import PoqPlatform
@testable import PoqAnalytics

class VisualSearchTests: EGTestCase {
    
    func testCameraReady() {        
        let viewController = VisualSearchViewController(nibName: VisualSearchViewController.XibName, bundle: nil)
        viewController.visualSearchCameraController = VisualSearchCameraDelegateMock(cameraPermissionGranted: true)
        insertNavigationController(withViewController: viewController)
        
        // Wait for animations to complete
        wait(forDuration: 1)
        XCTAssertTrue(viewController.visualSearchCameraViewControllerMode == .cameraReady)
    }
    
    func testCameraUnavailable() {
        let viewController = VisualSearchViewController(nibName: VisualSearchViewController.XibName, bundle: nil)
        viewController.visualSearchCameraController = VisualSearchCameraDelegateMock(cameraPermissionGranted: false)
        insertNavigationController(withViewController: viewController)
        
        // Wait for animations to complete
        wait(forDuration: 1)
        XCTAssertTrue(viewController.visualSearchCameraViewControllerMode == .cameraUnavailable)
    }
    
    func testVisualSearchCameraViewVisible() {
        let viewController = VisualSearchViewController(nibName: VisualSearchViewController.XibName, bundle: nil)
        viewController.visualSearchCameraController = VisualSearchCameraDelegateMock(cameraPermissionGranted: true)
        insertNavigationController(withViewController: viewController)

        // Wait for animations to complete
        wait(forDuration: 1)

        // Camera view should be there because permissions were granted
        let cameraViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchViewController.visualSearchCameraViewAccessibilityId)
        EarlGrey.elementExists(with: cameraViewMatcher)
    }
    
    func testVisualSearchCameraViewNotVisible() {
        let viewController = VisualSearchViewController(nibName: VisualSearchViewController.XibName, bundle: nil)
        viewController.visualSearchCameraController = VisualSearchCameraDelegateMock(cameraPermissionGranted: false)
        
        insertNavigationController(withViewController: viewController)
        
        // Camera view shouldn't be there because permissions weren't granted
        let cameraViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchViewController.visualSearchCameraViewAccessibilityId)
        EarlGrey.elementDoesNotExist(with: cameraViewMatcher)
    }
    
    func testVisualSearchCameraDelegateSwitchCameras() {
        let viewController = VisualSearchViewController(nibName: VisualSearchViewController.XibName, bundle: nil)
        viewController.visualSearchCameraController = VisualSearchCameraDelegateMock(cameraPermissionGranted: true)
        insertNavigationController(withViewController: viewController)
        
        // Wait for animations to complete
        wait(forDuration: 1)
        
        let currentCameraPosition = viewController.visualSearchCameraController.currentCameraPosition
        // Camera view shouldn't be there because permissions weren't granted
        let cameraSwitchButtonMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchViewController.visualSearchCameraSwitchNavButtonAccessibilityId)
        EarlGrey.elementExists(with: cameraSwitchButtonMatcher)
        EarlGrey.selectElement(with: cameraSwitchButtonMatcher).perform(grey_tap())
        GREYAssert(currentCameraPosition != viewController.visualSearchCameraController.currentCameraPosition)
    }
    
    func testVisualSearchCameraDelegateFlashMode() {
        let viewController = VisualSearchViewController(nibName: VisualSearchViewController.XibName, bundle: nil)
        viewController.visualSearchCameraController = VisualSearchCameraDelegateMock(cameraPermissionGranted: true)

        insertNavigationController(withViewController: viewController)
        
        // Wait for animations to complete
        wait(forDuration: 1)
        
        let currentCameraFlashMode = viewController.visualSearchCameraController.flashMode.rawValue
        // Camera view shouldn't be there because permissions weren't granted
        let cameraFlashButtonMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchViewController.visualSearchCameraFlashNavButtonAccessibilityId)
        EarlGrey.elementExists(with: cameraFlashButtonMatcher)
        EarlGrey.selectElement(with: cameraFlashButtonMatcher).perform(grey_tap())
        GREYAssert(currentCameraFlashMode != viewController.visualSearchCameraController.flashMode.rawValue)
    }
    
    func testOpenGalleryTappable() {
        let viewController = VisualSearchViewController(nibName: VisualSearchViewController.XibName, bundle: nil)
        viewController.visualSearchCameraController = VisualSearchCameraDelegateMock(cameraPermissionGranted: true)
        viewController.visualSearchGalleryController = VisualSearchGalleryDelegateMock(galleryPermissionGranted: true)
        insertNavigationController(withViewController: viewController)
        
        // Wait for animations to complete
        wait(forDuration: 1)

        let galleryButtonMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchViewController.visualSearchGalleryButtonAccessibilityId)
        EarlGrey.elementExists(with: galleryButtonMatcher)
        EarlGrey.selectElement(with: galleryButtonMatcher).perform(grey_tap())
    }
    
    func testCapturedImage() {
        let viewController = VisualSearchViewController(nibName: VisualSearchViewController.XibName, bundle: nil)
        viewController.visualSearchCameraController = VisualSearchCameraDelegateMock(cameraPermissionGranted: true)
        viewController.visualSearchGalleryController = VisualSearchGalleryDelegateMock(galleryPermissionGranted: true)
        insertNavigationController(withViewController: viewController)
        
        // Wait for animations to complete
        wait(forDuration: 1)
        
        let capturedImageButtonMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchViewController.visualSearchCameraButtonAccessibilityId)
        EarlGrey.elementExists(with: capturedImageButtonMatcher)
        EarlGrey.selectElement(with: capturedImageButtonMatcher).perform(grey_tap())

        // Check that the view controller's mode is the captured photo since the user has taken a picture
        XCTAssertTrue(viewController.visualSearchCameraViewControllerMode == .capturedPhoto)
    }
    
    func testRetakePicture() {
        let viewController = VisualSearchViewController(nibName: VisualSearchViewController.XibName, bundle: nil)
        viewController.visualSearchCameraController = VisualSearchCameraDelegateMock(cameraPermissionGranted: true)
        insertNavigationController(withViewController: viewController)
        
        // Wait for animations to complete
        wait(forDuration: 1)
        
        // Take a picture
        let capturedImageButtonMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchViewController.visualSearchCameraButtonAccessibilityId)
        EarlGrey.elementExists(with: capturedImageButtonMatcher)
        EarlGrey.selectElement(with: capturedImageButtonMatcher).perform(grey_tap())
        
        // Tap the retake button
        let retakeButtonMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchViewController.visualSearchRetakeButtonAccessibilityId)
        EarlGrey.elementExists(with: retakeButtonMatcher)
        EarlGrey.selectElement(with: retakeButtonMatcher).perform(grey_tap())
        
        // Check that the view controller's mode is back to the camera ready to take pictures
        XCTAssertTrue(viewController.visualSearchCameraViewControllerMode == .cameraReady)
        
        let photoImageViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchViewController.visualSearchPhotoImageViewAccessibilityId)
        EarlGrey.selectElement(with: photoImageViewMatcher).perform(EGHelpers.checkIsHiddenViewActionBlock())
    }
    
    func testUsePhotoPicture() {
        // In this test we are going to build the views controllers in the same way as we do in the App
        // 1.- Create a Navigation controller
        let navigationControler = UINavigationController()
        // 2.- Insert them in the view hearichy
        insertViewController(navigationControler)
        // 3.- Present Visual Search as a Modal view on top of a navigation controller
        let visualviewController = VisualSearchViewController(nibName: VisualSearchViewController.XibName, bundle: nil)
        visualviewController.visualSearchCameraController = VisualSearchCameraDelegateMock(cameraPermissionGranted: true)
        let visualNavigationControler = UINavigationController(rootViewController: visualviewController)
        navigationControler.present(visualNavigationControler, animated: false, completion: nil)
        
        // Wait for animations to complete
        wait(forDuration: 1)
        
        // Take a picture
        let capturedImageButtonMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchViewController.visualSearchCameraButtonAccessibilityId)
        EarlGrey.elementExists(with: capturedImageButtonMatcher)
        EarlGrey.selectElement(with: capturedImageButtonMatcher).perform(grey_tap())
        
        // Tap the use photo button
        let usePhotoButtonMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchViewController.visualSearchUsePhotoButtonAccessibilityId)
        EarlGrey.elementExists(with: usePhotoButtonMatcher)
        EarlGrey.selectElement(with: usePhotoButtonMatcher).perform(grey_tap())
        // Wait for animations to complete
        wait(forDuration: 1)
        
        // Make sure that we have moved to the next controller
        let visualSearchViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchViewController.visualSearchViewAccessibilityId)
        EarlGrey.elementDoesNotExist(with: visualSearchViewMatcher)
        
        // Wait for animations to complete
        wait(forDuration: 1)

        // Tap the done button from the cropping view
        let doneButtonMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchCropViewController.visualSearchDoneButtonAccessibilityId)
        EarlGrey.elementExists(with: doneButtonMatcher)
        EarlGrey.selectElement(with: doneButtonMatcher).perform(grey_tap())

        // Make sure that the view controller has been dismissed
        let visualSearchCroppingViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchCropViewController.visualSearchCropViewAccessibilityId)
        EarlGrey.elementDoesNotExist(with: visualSearchCroppingViewMatcher)
    }
    
    func testCropPicture() {
        let navigationControler = UINavigationController()
        insertViewController(navigationControler)
        let bundle = Bundle(for: type(of: self)).path(forResource: "VisualSearchResultsTests", ofType: "bundle").flatMap({ Bundle(path: $0) })
        guard let image = UIImage(named: "uiTestRedDress.jpg", in: bundle, compatibleWith: nil) else {
            XCTFail("Couldn't get image")
            return
        }
        let cropViewController = VisualSearchCropViewController(image: image, source: VisualSearchImageSource.camera)
        navigationControler.present(cropViewController, animated: false, completion: nil)
        
        // Make sure that the cropping view is draggable in all directions
        let draggableBottomRightViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchCropRectView.visualSearchBottomRightDraggableViewAccessibilityId)
        EarlGrey.elementExists(with: draggableBottomRightViewMatcher)
        EarlGrey.selectElement(with: draggableBottomRightViewMatcher).perform(grey_swipeFastInDirection(GREYDirection.left))
        
        let draggableBottomLeftViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchCropRectView.visualSearchBottomLeftDraggableViewAccessibilityId)
        EarlGrey.elementExists(with: draggableBottomLeftViewMatcher)
        EarlGrey.selectElement(with: draggableBottomLeftViewMatcher).perform(grey_swipeFastInDirection(GREYDirection.up))
        
        let draggableTopRightViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchCropRectView.visualSearchTopRightDraggableViewAccessibilityId)
        EarlGrey.elementExists(with: draggableTopRightViewMatcher)
        EarlGrey.selectElement(with: draggableTopRightViewMatcher).perform(grey_swipeFastInDirection(GREYDirection.down))
        
        let draggableTopLeftViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchCropRectView.visualSearchTopLeftDraggableViewAccessibilityId)
        EarlGrey.elementExists(with: draggableTopLeftViewMatcher)
        EarlGrey.selectElement(with: draggableTopLeftViewMatcher).perform(grey_swipeFastInDirection(GREYDirection.right))
        
        let scrollViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchCropView.visualSearchCropScrollViewAccessibilityId)
        EarlGrey.elementExists(with: scrollViewMatcher)
        // We zoom out 3 times to make sure that we have a big image because in order for it to be valid it has to be bigger than 200x200
        EarlGrey.selectElement(with: scrollViewMatcher).perform(grey_pinchFastInDirectionAndAngle(GREYPinchDirection.inward, kGREYPinchAngleDefault))
        EarlGrey.selectElement(with: scrollViewMatcher).perform(grey_pinchFastInDirectionAndAngle(GREYPinchDirection.inward, kGREYPinchAngleDefault))
        EarlGrey.selectElement(with: scrollViewMatcher).perform(grey_pinchFastInDirectionAndAngle(GREYPinchDirection.inward, kGREYPinchAngleDefault))

        // Tap the done button from the cropping view
        let doneButtonMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchCropViewController.visualSearchDoneButtonAccessibilityId)
        EarlGrey.elementExists(with: doneButtonMatcher)
        EarlGrey.selectElement(with: doneButtonMatcher).perform(grey_tap())
        
        // The controller should be dismissed since the image is valid
        let visualSearchCropViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchCropViewController.visualSearchCropViewAccessibilityId)
        EarlGrey.elementDoesNotExist(with: visualSearchCropViewMatcher)
    }
    
    func testCropTooSmallPicture() {
        let navigationControler = UINavigationController()
        insertViewController(navigationControler)
        let bundle = Bundle(for: type(of: self)).path(forResource: "VisualSearchResultsTests", ofType: "bundle").flatMap({ Bundle(path: $0) })
        guard let image = UIImage(named: "uiTestRedDress.jpg", in: bundle, compatibleWith: nil) else {
            XCTFail("Couldn't get image")
            return
        }
        let cropViewController = VisualSearchCropViewController(image: image, source: VisualSearchImageSource.camera)
        navigationControler.present(cropViewController, animated: false, completion: nil)

        // Scroll inwards into the image
        let scrollViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchCropView.visualSearchCropScrollViewAccessibilityId)
        EarlGrey.elementExists(with: scrollViewMatcher)
        EarlGrey.selectElement(with: scrollViewMatcher).perform(grey_pinchFastInDirectionAndAngle(GREYPinchDirection.outward, kGREYPinchAngleDefault))
        
        // Tap the done button from the cropping view
        let doneButtonMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchCropViewController.visualSearchDoneButtonAccessibilityId)
        EarlGrey.elementExists(with: doneButtonMatcher)
        EarlGrey.selectElement(with: doneButtonMatcher).perform(grey_tap())
        
        // The alert view should appear indicating that the image is far too small
        let visualSearchCropAlertViewMatcher = GREYMatchers.matcher(forAccessibilityID: VisualSearchCropViewController.visualSearchCropAlertViewAccessibilityId)
        EarlGrey.elementExists(with: visualSearchCropAlertViewMatcher)
    }
}
