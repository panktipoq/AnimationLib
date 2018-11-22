//
//  VisualSearchCameraDelegate.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 01/03/2018.
//

import AVFoundation
import UIKit

/// These errors will be used to return meaningful feedback to the completion closures and flow of calls
///
/// - captureSessionError: The session couldn't be captured
/// - inputsError: There was a problem setting up the camera inputs
/// - operationError: The operation couldn't be completed
/// - cameraUnavailableError: The camera is unavailable
/// - cameraPermissionError: The user has not given access the the gallery
/// - unknownError: Unknown Error
public enum CameraError: Swift.Error {
    case captureSessionError
    case inputsError
    case operationError
    case cameraUnavailableError
    case cameraPermissionError
    case unknownError
}

/// Position of the camera
///
/// - frontCamera: Front camera
/// - rearCamera: Rear camera
public enum CameraPosition {
    case frontCamera
    case rearCamera
}

/**
 `VisualSearchCameraDelegate` defines the design of the Camera Controller. These are the functions that a controller should implement in order to support the camera action. The main responsabilities of this delegate are:
 * Setting up the front and/or rear cameras
 * Adding camera subview to controller's view
 * Switching cameras if possible (front to read and viceversa)
 * Taking a picture
 * Enabling/disabling flash
 
 This delegate should always return its completion blocks from the main thread. It handles itself the expensive operations by dispatching them in an async queue
 */
public protocol VisualSearchCameraDelegate: AnyObject {
    
    /// Start the camera. It's main responsabilities are to initialised the camera controllers and trigger `displayCameraView(on view: UIView)` once the controllers are ready. This method DOES NOT user the main thread, therefore, make sure to use main thread on completion if updating the UI
    ///
    /// - Parameter completion: This completion handler will be called once the camera has been completely setup (Error will be nil) or there was an error whilst setting it up.
    func startCamera(completion: @escaping (CameraError?) -> Void)
    
    /// This method will display the camera view on top of the given view
    ///
    /// - Parameters:
    ///   - view: The view which will be used to display and add the camera view
    ///   - completion: This handler will be triggered once the view has been added to the Hierarchy
    func displayCameraView(on view: UIView, completion: @escaping (CameraError?) -> Void)

    /// Switches from the current camera to the opposite camera
    ///
    /// - Parameter completion: This closure will be trigger once the controller has finished switching the cameras
    func switchCameras(completion: @escaping (CameraError?) -> Void)

    /// This function will take a photo and return the image
    ///
    /// - Parameter completion: It will return the image taken and any given error that this might have caused. Also, it might return a nil image if there was a problem.
    func takePicture(completion: @escaping (UIImage?, Error?) -> Void)
    
    /// This var will be in charge of disabling or enabling the flash mode depending on actions from the user
    var flashMode: AVCaptureDevice.FlashMode { get set }
    
    /// This var will hold a reference to the current position of the camera
    var currentCameraPosition: CameraPosition? { get }
    
    /// This function will stop running the session
    func pauseCamera()
    
    /// This method will resume the session capture again.again
    ///
    /// - Parameter completion: This completion will be called inside the async thread on start session completion so the UI can be notified at the right time. It will return on a non-main thread
    func resumeCamera(completion: @escaping (CameraError?) -> Void)
}
