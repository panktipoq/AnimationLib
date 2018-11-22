//
//  VisualSearchCameraController.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 21/02/2018.
//

import AVFoundation
import UIKit

public class VisualSearchCameraController: NSObject, VisualSearchCameraDelegate, AVCapturePhotoCaptureDelegate {
    
    var captureSession: AVCaptureSession?    
    public private(set) var currentCameraPosition: CameraPosition?
    
    var frontCameraCaptureDevice: AVCaptureDevice?
    var frontCameraDeviceInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var rearCameraCaptureDevice: AVCaptureDevice?
    var rearCameraDeviceInput: AVCaptureDeviceInput?
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    public var flashMode = AVCaptureDevice.FlashMode.off
    var photoCaptureCompletion: ((UIImage?, Error?) -> Void)?
    
    // MARK: - Camera set up
    
    public func pauseCamera() {
        guard let captureSessionUnwrapped = captureSession else {
            return
        }
        DispatchQueue.global(qos: .default).async {
            captureSessionUnwrapped.stopRunning()
        }
    }

    public func resumeCamera(completion: @escaping (CameraError?) -> Void) {
        guard let captureSessionUnwrapped = captureSession else {
            completion(CameraError.captureSessionError)
            return
        }
        DispatchQueue.global(qos: .default).async {
            captureSessionUnwrapped.startRunning()
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }

    public func startCamera(completion: @escaping (CameraError?) -> Void) {
        // Store the completion closure in a variable so we can dispatch it from the main thread
        let returnCompletion: (CameraError?) -> Void = { (error: CameraError?) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
        PermissionHelper.checkCameraAccess { [weak self] (success: Bool) in
            guard let strongSelf = self else {
                returnCompletion(CameraError.unknownError)
                return
            }
            if success {
                DispatchQueue.global(qos: .default).async {
                    do {
                        strongSelf.createCaptureSession()
                        try strongSelf.configureCaptureDevices()
                        try strongSelf.configureDeviceInputs()
                        try strongSelf.configurePhotoOutput()
                        returnCompletion(nil)
                    } catch {
                        returnCompletion(CameraError.unknownError)
                    }
                }
            } else {
                returnCompletion(CameraError.cameraPermissionError)
            }
        }
    }
    
    func createCaptureSession() {
        captureSession = AVCaptureSession()
    }
    
    func configureCaptureDevices() throws {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        let cameras = session.devices
        guard !cameras.isEmpty else {
                throw CameraError.cameraUnavailableError
        }
        
        for camera in cameras {
            if camera.position == .front {
                frontCameraCaptureDevice = camera
            }
            
            if camera.position == .back {
                rearCameraCaptureDevice = camera
                
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
        }
    }
    
    func configureDeviceInputs() throws {
        guard let captureSessionUnwrapped = captureSession else {
            throw CameraError.captureSessionError
        }
        if let rearCameraUnwrapped = rearCameraCaptureDevice {
            rearCameraDeviceInput = try AVCaptureDeviceInput(device: rearCameraUnwrapped)
            try addInput(input: rearCameraDeviceInput, session: captureSessionUnwrapped)
            currentCameraPosition = .rearCamera
        } else if let frontCameraUnwrapped = frontCameraCaptureDevice {
            frontCameraDeviceInput = try AVCaptureDeviceInput(device: frontCameraUnwrapped)
            try addInput(input: frontCameraDeviceInput, session: captureSessionUnwrapped)
            currentCameraPosition = .frontCamera
        } else {
            throw CameraError.cameraUnavailableError
        }
    }
    
    func addInput(input: AVCaptureDeviceInput?, session: AVCaptureSession) throws {
        if let input = input, session.canAddInput(input) {
            session.addInput(input)
        } else {
            throw CameraError.inputsError
        }
    }
    
    func configurePhotoOutput() throws {
        guard let captureSessionUnwrapped = captureSession else {
            throw CameraError.captureSessionError
        }
        
        photoOutput = AVCapturePhotoOutput()
        photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])], completionHandler: nil)
        
        if let photoOutput = photoOutput, captureSessionUnwrapped.canAddOutput(photoOutput) {
            captureSessionUnwrapped.addOutput(photoOutput)
        }
        captureSessionUnwrapped.startRunning()
    }
    
    public func displayCameraView(on view: UIView, completion: @escaping (CameraError?) -> Void) {
        guard let captureSessionUnwrapped = captureSession,
            captureSessionUnwrapped.isRunning else {
                completion(CameraError.captureSessionError)
                return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSessionUnwrapped)
        guard let previewLayerUnwrapped = videoPreviewLayer else {
            completion(CameraError.operationError)
            return
        }
        previewLayerUnwrapped.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayerUnwrapped.connection?.videoOrientation = .portrait
        view.layer.insertSublayer(previewLayerUnwrapped, at: 0)
        previewLayerUnwrapped.frame = view.frame
        completion(nil)
    }
    
    // MARK: - Switch cameras
    
    public func switchCameras(completion: @escaping (CameraError?) -> Void) {
        // Store the completion closure in a variable so we can dispatch it from the main thread
        let returnCompletion: (CameraError?) -> Void = { (error: CameraError?) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            do {
                try self.switchCameraConfiguration()
                returnCompletion(nil)
            } catch {
                guard let cameraControllerError = error as? CameraError else {
                    returnCompletion(CameraError.unknownError)
                    return
                }
                returnCompletion(cameraControllerError)
            }
        }
    }
    
    func switchCameraConfiguration() throws {
        guard let currentCameraPositionUnwrapped = currentCameraPosition else {
            throw CameraError.unknownError
        }
        guard  let captureSessionUnwrapped = captureSession,
            captureSessionUnwrapped.isRunning else {
                throw CameraError.captureSessionError
        }
        captureSessionUnwrapped.beginConfiguration()
        switch currentCameraPositionUnwrapped {
        case .frontCamera:
            try switchCamera(addCameraDeviceInput: &rearCameraDeviceInput, removeCameraDeviceInput: &frontCameraDeviceInput, captureDevice: &rearCameraCaptureDevice, cameraPosition: .rearCamera)
        case .rearCamera:
            try switchCamera(addCameraDeviceInput: &frontCameraDeviceInput, removeCameraDeviceInput: &rearCameraDeviceInput, captureDevice: &frontCameraCaptureDevice, cameraPosition: .frontCamera)
        }
        captureSessionUnwrapped.commitConfiguration()
    }
    
    func switchCamera(addCameraDeviceInput: inout AVCaptureDeviceInput?, removeCameraDeviceInput: inout AVCaptureDeviceInput?, captureDevice: inout AVCaptureDevice?, cameraPosition: CameraPosition) throws {
        guard let captureSessionUnwrapped = captureSession else {
            throw CameraError.operationError
        }
        let inputs = captureSessionUnwrapped.inputs
        guard let removeCameraDeviceInputUnwrapped = removeCameraDeviceInput,
            let captureDeviceUnwrapped = captureDevice,
            inputs.contains(removeCameraDeviceInputUnwrapped) else {
                throw CameraError.operationError
        }
        
        addCameraDeviceInput = try AVCaptureDeviceInput(device: captureDeviceUnwrapped)
        
        captureSessionUnwrapped.removeInput(removeCameraDeviceInputUnwrapped)
        
        if let addCameraDeviceInput = addCameraDeviceInput, captureSessionUnwrapped.canAddInput(addCameraDeviceInput) {
            captureSessionUnwrapped.addInput(addCameraDeviceInput)
            currentCameraPosition = cameraPosition
        } else {
            throw CameraError.operationError
        }
    }
    
    public func takePicture(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSessionUnwrapped = captureSession,
            captureSessionUnwrapped.isRunning else {
                completion(nil, CameraError.captureSessionError)
                return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        
        photoOutput?.capturePhoto(with: settings, delegate: self) // AVCapturePhotoCaptureDelegate
        photoCaptureCompletion = completion
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                            didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                            previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                            resolvedSettings: AVCaptureResolvedPhotoSettings,
                            bracketSettings: AVCaptureBracketedStillImageSettings?,
                            error: Swift.Error?) {
        // Store the completion closure in a variable so we can dispatch it from the main thread
        let returnCompletion: (UIImage?, Error?) -> Void = { [weak self]  (image: UIImage?, error: Error?) in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.photoCaptureCompletion?(image, error)
            }
        }
        if let error = error {
            returnCompletion(nil, error)
        } else if let buffer = photoSampleBuffer,
            let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
            let image = UIImage(data: data) {
            returnCompletion(image, nil)
        } else {
            returnCompletion(nil, CameraError.unknownError)
        }
    }
}
