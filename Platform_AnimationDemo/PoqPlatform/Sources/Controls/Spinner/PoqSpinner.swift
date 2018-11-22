//
//  PoqSpinner.swift
//  Poq.iOS
//
//  Created by Jun Seki on 28/08/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import PoqModuling
import PoqNetworking
import PoqUtilities
import UIKit

public enum PoqIndicatorType: String {
    case material = "Material"
    case ringSpinner = "RingSpinner"
    case ballPulse = "BallPulse"
    case ballGridPulse = "BallGridPulse"
    case ballClipRotate = "BallClipRotate"
    case squareSpin = "SquareSpin"
    case ballClipRotatePulse = "BallClipRotatePulse"
    case ballClipRotateMultiple = "BallClipRotateMultiple"
    case ballPulseRise = "BallPulseRise"
    case ballRotate = "BallRotate"
    case cubeTransition = "CubeTransition"
    case ballZigZag = "BallZigZag"
    case ballZigZagDeflect = "BallZigZagDeflect"
    case ballTrianglePath = "BallTrianglePath"
    case ballScale = "BallScale"
    case lineScale = "LineScale"
    case lineScaleParty = "LineScaleParty"
    case ballScaleMultiple = "BallScaleMultiple"
    case ballPulseSync = "BallPulseSync"
    case ballBeat = "BallBeat"
    case lineScalePulseOut = "LineScalePulseOut"
    case lineScalePulseOutRapid = "LineScalePulseOutRapid"
    case ballScaleRipple = "BallScaleRipple"
    case ballScaleRippleMultiple = "BallScaleRippleMultiple"
    case ballSpinFadeLoader = "BallSpinFadeLoader"
    case lineSpinFadeLoader = "LineSpinFadeLoader"
    case triangleSkewSpin = "TriangleSkewSpin"
    case pacman = "Pacman"
    case ballGridBeat = "BallGridBeat"
    case semiCircleSpin = "SemiCircleSpin"
}

open class PoqSpinner: UIView {
    
    open var lineWidth: CGFloat = 1.5
    
    open var mmMaterialSpinnerView: MaterialDesignSpinner?
    open var ringSpinnerView: RingSpinnerView?
    open var activityIndicatorView: NVActivityIndicatorView?
    
    open func setUp() {
        var indicatorType = NVActivityIndicatorType.blank
        let indicatorStyle = getIndicatorStyle()
        switch indicatorStyle {
        case PoqIndicatorType.material.rawValue:
            setupMaterialSpinner()
            return
        case PoqIndicatorType.ballPulse.rawValue:
            indicatorType = .ballPulse
        case PoqIndicatorType.ballGridPulse.rawValue:
            indicatorType = .ballGridPulse
        case PoqIndicatorType.ballClipRotate.rawValue:
            indicatorType = .ballClipRotate
        case PoqIndicatorType.squareSpin.rawValue:
            indicatorType = .squareSpin
        case PoqIndicatorType.ballClipRotatePulse.rawValue:
            indicatorType = .ballClipRotatePulse
        case PoqIndicatorType.ballClipRotateMultiple.rawValue:
            indicatorType = .ballClipRotateMultiple
        case PoqIndicatorType.ballPulseRise.rawValue:
            indicatorType = .ballPulseRise
        case PoqIndicatorType.ballRotate.rawValue:
            indicatorType = .ballRotate
        case PoqIndicatorType.cubeTransition.rawValue:
            indicatorType = .cubeTransition
        case PoqIndicatorType.ballZigZag.rawValue:
            indicatorType = .ballZigZag
        case PoqIndicatorType.ballZigZagDeflect.rawValue:
            indicatorType = .ballZigZagDeflect
        case PoqIndicatorType.ballTrianglePath.rawValue:
            indicatorType = .ballTrianglePath
        case PoqIndicatorType.ballScale.rawValue:
            indicatorType = .ballScale
        case PoqIndicatorType.lineScale.rawValue:
            indicatorType = .lineScale
        case PoqIndicatorType.lineScaleParty.rawValue:
            indicatorType = .lineScaleParty
        case PoqIndicatorType.ballScaleMultiple.rawValue:
            indicatorType = .ballScaleMultiple
        case PoqIndicatorType.ballPulseSync.rawValue:
            indicatorType = .ballPulseSync
        case PoqIndicatorType.ballBeat.rawValue:
            indicatorType = .ballBeat
        case PoqIndicatorType.lineScalePulseOut.rawValue:
            indicatorType = .lineScalePulseOut
        case PoqIndicatorType.lineScalePulseOutRapid.rawValue:
            indicatorType = .lineScalePulseOutRapid
        case PoqIndicatorType.ballScaleRipple.rawValue:
            indicatorType = .ballScaleRipple
        case PoqIndicatorType.ballScaleRippleMultiple.rawValue:
            indicatorType = .ballScaleRippleMultiple
        case PoqIndicatorType.ballSpinFadeLoader.rawValue:
            indicatorType = .ballSpinFadeLoader
        case PoqIndicatorType.lineSpinFadeLoader.rawValue:
            indicatorType = .lineSpinFadeLoader
        case PoqIndicatorType.triangleSkewSpin.rawValue:
            indicatorType = .triangleSkewSpin
        case PoqIndicatorType.pacman.rawValue:
            indicatorType = .pacman
        case PoqIndicatorType.ballGridBeat.rawValue:
            indicatorType = .ballGridBeat
        case PoqIndicatorType.semiCircleSpin.rawValue:
            indicatorType = .semiCircleSpin
        default:
            setupRingSpinner()
            
            return
        }
        setupActivityIndicator(indicatorType)
    }
    
    // MARK: - UIView override

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override open var intrinsicContentSize: CGSize {
        let size = CGSize(width: CGFloat(AppSettings.sharedInstance.loadingIndicatorDimension), height: CGFloat(AppSettings.sharedInstance.loadingIndicatorDimension))
        return size
    }
    
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        if !isHidden, window != nil, isAnimating {
            startAnimating()
        }
    }
    
    // MARK: - Private
    
    fileprivate func getIndicatorStyle() -> String {
        
        var setting: PoqSetting?
        setting = SettingsCoreDataHelper.fetchSetting(nil, key: "loadingIndicatorStyle", settingTypeId: PoqSettingsType.config.rawValue, appId: PoqNetworkTaskConfig.appId)
        
        if let value = setting?.value, !value.isEmpty {
            
            return value
        } else {
            // First time running using default style (ring)
            return AppSettings.sharedInstance.loadingIndicatorStyle
        }
    }
    
    fileprivate func getIndicatorTintColor() -> UIColor {
        
        // Set the tint color of the spinner
        // By default it's gray for the first time, then 2nd time it will read from core data for the color
        var setting: PoqSetting?
        var indicatorTintColor: UIColor
        setting = SettingsCoreDataHelper.fetchSetting(nil, key: "mainColor", settingTypeId: PoqSettingsType.theme.rawValue, appId: PoqNetworkTaskConfig.appId)
        
        if let value = setting?.value, !value.isEmpty {
            
            indicatorTintColor = UIColor.hexColor(value)
        } else {
            // First time running using default color
            indicatorTintColor = AppTheme.sharedInstance.mainColor
        }
        return indicatorTintColor
    }
    
    fileprivate func setupMaterialSpinner() {
        let materialSpinnerView = MaterialDesignSpinner(frame: frame)
        
        materialSpinnerView.lineWidth = lineWidth
        materialSpinnerView.hidesWhenStopped = true
        materialSpinnerView.tintColor = getIndicatorTintColor()

        addSubview(materialSpinnerView)
        
        materialSpinnerView.translatesAutoresizingMaskIntoConstraints = false
        materialSpinnerView.applyCenterPositionConstraints()
        materialSpinnerView.applySizeConstraints()
        
        mmMaterialSpinnerView = materialSpinnerView
    }
    
    fileprivate func setupRingSpinner() {
        let ringSpinnerView = RingSpinnerView(frame: frame)
        ringSpinnerView.lineWidth = lineWidth
        ringSpinnerView.hidesWhenStopped = true
        ringSpinnerView.tintColor = getIndicatorTintColor()
        
        addSubview(ringSpinnerView)
        ringSpinnerView.translatesAutoresizingMaskIntoConstraints = false
        ringSpinnerView.applyCenterPositionConstraints()
        ringSpinnerView.applySizeConstraints()

        self.ringSpinnerView = ringSpinnerView
    }
    
    fileprivate func setupActivityIndicator(_ indicatorType: NVActivityIndicatorType) {

        if frame.size == CGSize(width: 0, height: 0) {
            let spinnerDimension = CGFloat(AppSettings.sharedInstance.loadingIndicatorDimension)
            frame.size = CGSize(width: spinnerDimension, height: spinnerDimension)
        }
        
        let activityIndicatorView = NVActivityIndicatorView(frame: frame, type: indicatorType, color: AppTheme.sharedInstance.mainColor, padding: nil)
        
        addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.applyCenterPositionConstraints()
        activityIndicatorView.applySizeConstraints()
        
        self.activityIndicatorView = activityIndicatorView
    }
    
    private var isAnimating = false
    
    public final func startAnimating() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(startAnimatingNow), with: nil, afterDelay: 0.3)
    }
    
    @objc private func startAnimatingNow() {
        DispatchQueue.main.async {
            if self.isAnimating {
                return
            }
            self.startSpin()
            self.isAnimating = true
        }
    }
    
    public final func stopAnimating() {
        DispatchQueue.main.async {
            if !self.isAnimating {
                NSObject.cancelPreviousPerformRequests(withTarget: self)
                return
            }
            self.stopSpin()
            self.isAnimating = false
        }
    }
    
    private func startSpin() {
        if let materialSpinnerView = self.mmMaterialSpinnerView {
            materialSpinnerView.startAnimating()
        }
        if let ringSpinnerView = self.ringSpinnerView {
            ringSpinnerView.startAnimating()
        }
        if let activityIndicator = self.activityIndicatorView {
            activityIndicator.startAnimating()
        }
        self.isHidden = false
    }
    
    private func stopSpin() {
        if let materialSpinnerView = self.mmMaterialSpinnerView {
            materialSpinnerView.stopAnimating()
        }
        if let ringSpinnerView = self.ringSpinnerView {
            ringSpinnerView.stopAnimating()
        }
        if let activityIndicator = self.activityIndicatorView {
            activityIndicator.stopAnimating()
        }
        self.isHidden = true
    }
}
