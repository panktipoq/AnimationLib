//
//  PoqVideoView.swift
//  PoqPlatform
//
//  Created by Rachel McGreevy on 07/10/2017.
//

import Foundation
import PoqUtilities
import AVFoundation

open class PoqVideoView: UIView {
    
    var spinnerView: PoqSpinner?
    var videoPlayer: AVPlayer?
    var videoAsset: AVAsset?
    var videoLoopObserver: NSObjectProtocol?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupProgressView()
    }
    
    open func setupProgressView() {
        
        let spinnerView = PoqSpinner(frame: CGRect.zero)
        self.addSubview(spinnerView)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = spinnerView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.5)
        widthConstraint.priority = UILayoutPriority.defaultHigh + 1
        
        let heightConstraint = spinnerView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.5)
        heightConstraint.priority = UILayoutPriority.defaultHigh + 1
        
        NSLayoutConstraint.activate([widthConstraint, heightConstraint])
        spinnerView.applyCenterPositionConstraints()
        
        spinnerView.lineWidth = 1.5
        spinnerView.tintColor = AppTheme.sharedInstance.mainColor
        
        self.spinnerView = spinnerView
    }
    
    open func fetchVideo(from videoUrl: URL, isAnimated: Bool = false, showLoading: Bool = true, completion: ((AVAssetTrack?) -> Void)? = nil) {
        
        if showLoading {
            spinnerView?.startAnimating()
        }
        
        videoAsset = AVAsset(url: videoUrl)
        videoAsset?.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError? = nil
            let status = self.videoAsset?.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded?:
                guard let videoAsset = self.videoAsset else {
                    Log.error("Couldn't initialise video asset from URL")
                    return
                }
                
                self.videoPlayer = AVPlayer(playerItem: AVPlayerItem(asset: videoAsset))
                let videoLayer = AVPlayerLayer(player: self.videoPlayer)
                let videoTracks = videoAsset.tracks(withMediaType: AVMediaType.video)
                
                guard videoTracks.count > 0 else {
                    Log.error("No video track in URL")
                    return
                }
                
                let videoTrack = videoTracks[0]
                
                videoLayer.frame.size = videoTrack.naturalSize
                self.layer.insertSublayer(videoLayer, at: 0)
                
                self.videoLoopObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.videoPlayer?.currentItem, queue: .main, using: { [weak self] (_) in
                    self?.videoPlayer?.seek(to: kCMTimeZero)
                    self?.videoPlayer?.play()
                })
                
                if showLoading {
                    self.spinnerView?.stopAnimating()
                }
                
                completion?(videoTrack)
                
                self.videoPlayer?.play()

            case .failed?:
                Log.error("Video asset cancelled loading due to \(String(describing: error))")
                
                if showLoading {
                    self.spinnerView?.stopAnimating()
                }

            case .cancelled?:
                Log.error("Video asset cancelled loading")
                
                if showLoading {
                    self.spinnerView?.stopAnimating()
                }

            default:
                
                if showLoading {
                    self.spinnerView?.stopAnimating()
                }
                
                break
            }
        }
        
    }
    
    deinit {
        videoPlayer?.pause()
        NotificationCenter.default.removeObserver(videoLoopObserver ?? self, name: .AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem)
    }
    
    open func prepareForReuse() {
        layer.removeAllAnimations()
        videoAsset?.cancelLoading()
        spinnerView?.stopAnimating()
        videoAsset = nil
    }

}
