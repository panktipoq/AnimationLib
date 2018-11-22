//
//  HomePageStyleProvider.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 31/05/2016.
//  Copyright © 2016 POQ. All rights reserved.
//

import Foundation

public protocol HomePageStyleProvider {
    
    func drawRightMenu(frame: CGRect, pressed: Bool, badgeNumber: String)
    
    func drawBackButton(frame: CGRect, pressed: Bool)
    
    func drawCloseButton(frame: CGRect, pressed: Bool, isWhite: Bool, alpha: CGFloat, hasbackground: Bool, isCentered: Bool)
    
    func drawDisclosureIndicator(frame: CGRect)
    
    func drawLeftMenu(frame: CGRect, pressed: Bool)
    
    func drawPreviousButton(frame: CGRect, pressed: Bool, alpha: CGFloat)
    
    func drawNextButton(frame: CGRect, pressed: Bool, alpha: CGFloat)
    
    func drawWishListCloseButton(frame: CGRect, pressed: Bool, alpha: CGFloat)
    
    func drawPlusMinus(frame: CGRect, rotatingDegree: CGFloat)
    
    func drawLogo(frame: CGRect)
    
    func drawSplashLogo(frame: CGRect)
    
    func drawScanIcon(frame: CGRect)
    
    func drawScanIconPressed(frame: CGRect)
    
    func drawScanFrame(frame: CGRect)
    
    func drawSearchScanButton(frame: CGRect, pressed: Bool, enableScan: Bool)
    
    func drawSearchBarBackground(frame: CGRect)
    
    func drawSearchBarIcon(frame: CGRect)
    
    func drawHorizontalLine(frame: CGRect)
    
    func drawVerticalLine(frame: CGRect)
    
    func drawSolidLine(frame: CGRect, solidLineHasSeparator: Bool, solidLineSeparatorWidth: CGFloat)
        
    func drawShareButton(frame: CGRect, pressed: Bool)
    
    func drawAddtobagConfirmation(frame: CGRect, buttonText: String, xOffset: CGFloat, yOffset: CGFloat, scale: CGFloat)
    
    func drawPriceToggle(frame: CGRect, pressed: Bool)
    
    func drawCallButton(frame: CGRect, pressed: Bool, buttonText: String, fontSize: CGFloat, disabled: Bool)
    
    func drawDirectionButton(frame: CGRect, pressed: Bool)
    
    func drawFavoriteStoreButton(frame: CGRect, pressed: Bool)
    
    func drawWhiteButton(frame: CGRect, pressed: Bool, buttonText: String, fontSize: CGFloat)
    
    func drawShowHideButton(frame: CGRect, pressed: Bool, buttonText: String, pressedText: String)
    
    func drawBlackButton(frame: CGRect, pressed: Bool, buttonText: String, fontSize: CGFloat, borderWidth: CGFloat, disabled: Bool)
    
    func drawRetry(frame: CGRect, pressed: Bool, buttonText: String)
    
    func drawImportButton(frame: CGRect, pressed: Bool, buttonText: String, fontSize: CGFloat, disabled: Bool)
    
    func drawLookbookButton(frame: CGRect, pressed: Bool, buttonText: String, fontSize: CGFloat)
    
    func drawTick(frame: CGRect)
    
    func drawPlusButton(frame: CGRect, pressed: Bool)
    
    func drawMinusButton(frame: CGRect, pressed: Bool, disabled: Bool)
    
    func drawSizeSelectorHeader(frame: CGRect, buttonText: String)
    
    func drawBarcodeFrame(frame: CGRect)
    
    func drawPhysicalCard(frame: CGRect, physicalCardText: String, linkCardText: String)
    
    func drawMySizeMale(frame: CGRect, pressed: Bool)
    
    func drawMySizeFemale(frame: CGRect, pressed: Bool)
    
    func drawMySizeKids(frame: CGRect, pressed: Bool)
    
    /// MARK: Generated Images
    
    func imageOfRightMenu(frame: CGRect, pressed: Bool, badgeNumber: String) -> UIImage
    
    func imageOfCloseButton(frame: CGRect, pressed: Bool, isWhite: Bool, alpha: CGFloat, hasbackground: Bool, isCentered: Bool) -> UIImage

    func imageOfLeftMenu(frame: CGRect, pressed: Bool) -> UIImage

    func imageOfScanIcon(frame: CGRect) -> UIImage

    func imageOfScanIconPressed(frame: CGRect) -> UIImage
    
    
}

