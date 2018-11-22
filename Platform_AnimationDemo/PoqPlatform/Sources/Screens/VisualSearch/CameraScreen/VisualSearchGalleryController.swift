//
//  VisualSearchGalleryController.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 25/02/2018.
//

import Foundation
import Photos

public class VisualSearchGalleryController: VisualSearchGalleryDelegate {
    
    var imageManager: PHImageManager?
    var requestOptions: PHImageRequestOptions?
    var fetchOptions: PHFetchOptions?
    var fetchResult: PHFetchResult<PHAsset>?
    
    public func setupPhotoGalleryController() {
        imageManager = PHImageManager.default()
        requestOptions = PHImageRequestOptions()
        requestOptions?.isSynchronous = true
        requestOptions?.resizeMode = .fast
        fetchOptions = PHFetchOptions()
        fetchOptions?.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
    }
    
    public func galleryThumbnail(size targetSize: CGSize, completion: @escaping (_ image: UIImage?, _ error: GalleryError?) -> Void) {
        // Store the completion closure in a variable so we can dispatch it from the main thread
        let returnCompletion: (_ image: UIImage?, _ error: GalleryError?) -> Void = { (image: UIImage?, error: GalleryError?) in
            DispatchQueue.main.async {
                completion(image, error)
            }
        }
        PermissionHelper.checkGalleryAccess { [weak self] (success: Bool) in
            guard let strongSelf = self else {
                returnCompletion(nil, GalleryError.unknownError)
                return
            }
            if success {
                // Set up the gallery fetcher so we can work with it
                strongSelf.setupPhotoGalleryController()
                guard let fetchResultUnwrapped = strongSelf.fetchResult else {
                    returnCompletion(nil, GalleryError.unknownError)
                    return
                }
                if fetchResultUnwrapped.count > 0 {
                    strongSelf.imageManager?.requestImage(for: fetchResultUnwrapped.object(at: fetchResultUnwrapped.count - 1) as PHAsset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFill, options: strongSelf.requestOptions) { (image: UIImage?, _) in
                        returnCompletion(image, nil)
                    }
                } else {
                    returnCompletion(nil, GalleryError.galleryNoImagesError)
                }
            } else {
                returnCompletion(nil, GalleryError.galleryPermissionError)
            }
        }
    }

    public func openGallery<T: UIViewController>(fromViewController controller: T, completion: @escaping (GalleryError?) -> Void) where T: UINavigationControllerDelegate, T: UIImagePickerControllerDelegate {
        PermissionHelper.checkGalleryAccess(shouldRequestAccess: true) { (success: Bool) in
            DispatchQueue.main.async {
                if success {
                    let galleryViewController = UIImagePickerController()
                    galleryViewController.delegate = controller
                    galleryViewController.sourceType = .photoLibrary
                    NavigationHelper.sharedInstance.openController(galleryViewController, modalWithNavigation: true, isSingleModal: true, topViewController: controller)
                    completion(nil)
                } else {
                    completion(GalleryError.galleryPermissionError)
                }
            }
        }
    }
}
