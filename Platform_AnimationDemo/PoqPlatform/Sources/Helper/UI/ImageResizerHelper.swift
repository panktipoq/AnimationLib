//
//  ImageResizerHelper.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 5/3/16.
//
//

import Foundation

class ImageResizerHelper {
    let screenWidth = UIScreen.main.bounds.size.width
    func resizeHomeBannerImage(_ homeBannerWidth: CGFloat, homeBannerHeight: CGFloat, isFeatured: Bool?) -> CGSize{
        let bannerWidth = isFeatured == true ? screenWidth : screenWidth / 2
        
        let bannerHeight = CGFloat(homeBannerHeight) * bannerWidth / CGFloat(homeBannerWidth)
        
        return CGSize(width: bannerWidth, height: bannerHeight)
    }
    
    func resizeMyProfileImage(_ pictureOriginalWidth: CGFloat, pictureOriginalHeight: CGFloat) -> CGSize{

        guard pictureOriginalWidth != 0 && pictureOriginalHeight != 0 else{
            return CGSize.zero
        }
        
        let aspectRatio = screenWidth / pictureOriginalWidth
        let bannerHeight = pictureOriginalHeight * aspectRatio
        return CGSize(width: screenWidth, height: bannerHeight)
    }
    
}
