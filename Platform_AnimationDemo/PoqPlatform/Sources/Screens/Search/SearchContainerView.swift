//
//  PredictiveSearchContainerView.swift
//  PoqPlatform
//
//  Created by Nikolay Dzhulay on 10/20/17.
//

import Foundation
import UIKit

/// View of PredictiveSearchController
/// Provides 2 layout guides: for search bar and search results
/// Layout for search bar might have bigger height that 44, in this case content of search bar should stick to bottom
class SearchContainerView: UIView {
    
    /// Should be used for proper positiining top elements of PredictiveSearchController 
    /// This is guide for searchbar backgroun
    lazy var topLayoutGuide: UILayoutGuide = {
        let res = UILayoutGuide()
        self.addLayoutGuide(res)
        return res
    }()
    
    /// `contentLayoutGuide` should be used for serach result/content view
    /// This layout will placed right under `searchBarContainerView`
    lazy var contentLayoutGuide: UILayoutGuide = {
        let res = UILayoutGuide()
        self.addLayoutGuide(res)
        return res
    }()
    
    var topLayoutAppliedContrains = [NSLayoutConstraint]()
    var contentLayoutAppliedContraints = [NSLayoutConstraint]()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()

        NSLayoutConstraint.deactivate(topLayoutAppliedContrains)
        NSLayoutConstraint.deactivate(contentLayoutAppliedContraints)
        
        guard let windowUnwrapped = window else {
            return
        }

        // Top layout

        topLayoutAppliedContrains = contraintsForTopLayoutGuide(realatedTo: windowUnwrapped)
        NSLayoutConstraint.activate(topLayoutAppliedContrains)
        
        // Content layout

        contentLayoutAppliedContraints = contraintsForContentLayoutGuide(realatedTo: windowUnwrapped)
        NSLayoutConstraint.activate(contentLayoutAppliedContraints)
    }
    
    // MARK: Private
    fileprivate func contraintsForTopLayoutGuide(realatedTo window: UIWindow) -> [NSLayoutConstraint] {
        let leadingConstraint = topLayoutGuide.leadingAnchor.constraint(equalTo: window.leadingAnchor)
        let topConstraint = topLayoutGuide.topAnchor.constraint(equalTo: window.topAnchor)
        let trailingConstraint = topLayoutGuide.trailingAnchor.constraint(equalTo: window.trailingAnchor)
        
        let safeAreaHeight: CGFloat

        if window.safeAreaInsets.top.isEqual(to: 0) {
            // so we will extend it for status bar height
            safeAreaHeight = UIApplication.shared.statusBarFrame.size.height
        } else {
            safeAreaHeight = window.safeAreaInsets.top
        }

        let heightConstraint = topLayoutGuide.heightAnchor.constraint(equalToConstant: safeAreaHeight + SearchBar.height)

        return [leadingConstraint, topConstraint, trailingConstraint, heightConstraint]
    }
    
    fileprivate func contraintsForContentLayoutGuide(realatedTo window: UIWindow) -> [NSLayoutConstraint] {

        let leadingConstraint = contentLayoutGuide.leadingAnchor.constraint(equalTo: window.leadingAnchor)
        let topConstraint = contentLayoutGuide.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)

        let trailingConstraint = contentLayoutGuide.trailingAnchor.constraint(equalTo: window.trailingAnchor)
        let bottomConstraint = contentLayoutGuide.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        
        return [leadingConstraint, topConstraint, trailingConstraint, bottomConstraint]
    }
}
