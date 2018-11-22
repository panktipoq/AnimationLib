//
//  AppStoryCardViewController.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 8/11/17.
//
//

import Foundation
import PoqNetworking
import UIKit

let AppStoryCardViewAccessibilityIdBase = "CardViewAccessibilityId_"

public class AppStoryCardViewController: PoqBaseViewController {
    
    @IBOutlet public weak var imageView: PoqAsyncImageView?
    @IBOutlet public weak var gifView: PoqGifImageView?
    
    public let storyCard: PoqAppStoryCard

    public  fileprivate(set) final var isMediaLoaded: Bool = false {
        didSet {
            cardPresenter?.cardDidLoadMedia(storyCard)
        }
    }

    public final weak var cardPresenter: AppStoryCardPresenter?

    public init(with storyCard: PoqAppStoryCard) {
        self.storyCard = storyCard
        super.init(nibName: AppStoryCardViewController.XibName, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Display and set up the content views
        showContent()
        // Assign view identifiar
        view.accessibilityIdentifier = AppStoryCardViewAccessibilityIdBase + storyCard.identifier
        // Declare an observer for when the app gets dissmiss or inactive because a sms, switching Apps, etc
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func showContent() {
        switch storyCard.mediaType {
        case .image:
            imageView?.fetchImage(from: storyCard.mediaUrl) {
                [weak self]
                (_) in
                self?.isMediaLoaded = true
            }
            gifView?.isHidden = true
            
        case .gif:
            imageView?.isHidden = true
            gifView?.animateGif(storyCard.mediaUrl) {
                [weak self] in
                self?.isMediaLoaded = true
            }
        }
    }
    
    @objc func applicationDidBecomeActive() {
        showContent()
    }
}
