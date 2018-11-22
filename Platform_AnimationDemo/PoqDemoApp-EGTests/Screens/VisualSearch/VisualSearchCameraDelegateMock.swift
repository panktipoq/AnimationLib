//
//  VisualSearchCameraDelegateMock.swift
//  PoqDemoApp-EGTests
//
//  Created by Manuel Marcos Regalado on 28/02/2018.
//

import UIKit
import AVFoundation

@testable import PoqPlatform

class VisualSearchCameraDelegateMock: NSObject, VisualSearchCameraDelegate {
   
    public var currentCameraPosition: CameraPosition? = .frontCamera

    var hasCameraPermission = false
    
    var flashMode = AVCaptureDevice.FlashMode.off

    init(cameraPermissionGranted: Bool) {
        self.hasCameraPermission = cameraPermissionGranted
    }
    
    func startCamera(completion: @escaping (CameraError?) -> Void) {
        let result = hasCameraPermission ? nil : CameraError.cameraPermissionError
        completion(result)
    }
    
    func displayCameraView(on view: UIView, completion: @escaping (CameraError?) -> Void) {
        let result = hasCameraPermission ? nil : CameraError.cameraPermissionError
        completion(result)
    }
    
    func switchCameras(completion: @escaping (CameraError?) -> Void) {
        currentCameraPosition = currentCameraPosition == .frontCamera ? .rearCamera : .frontCamera
        completion(nil)
    }
    
    func takePicture(completion: @escaping (UIImage?, Error?) -> Void) {
        let bundle = Bundle(for: type(of: self)).path(forResource: "VisualSearchResultsTests", ofType: "bundle").flatMap({ Bundle(path: $0) })
        guard let image = UIImage(named: "uiTestRedDress.jpg", in: bundle, compatibleWith: nil) else {
            completion(nil, CameraError.unknownError)
            return
        }
        completion(image, nil)
    }
    
    func pauseCamera() {
        // This is method is to adhere protocol. It is defined by `VisualSearchCameraDelegate`
    }

    func resumeCamera(completion: @escaping (CameraError?) -> Void) {
        // This is method is to adhere protocol. It is defined by `VisualSearchCameraDelegate`
    }
}
