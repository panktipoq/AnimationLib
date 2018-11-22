//
//  OnboardingPageCell.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 12/21/16.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

/// Some block may contains deeplink and we need handle it
protocol OnboardingBlockActionDelegate: AnyObject {
    func openLink(_ link: String)
}

protocol OnboardingBlockCell: PoqReusableView {
    
    /// Update UI for onboarding screen and block
    func setup(using block: PoqBlock)
}

open class OnboardingPageCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    var onboarding: PoqOnboarding?
    
    weak var actionDelegate: OnboardingBlockActionDelegate?
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        var cellClasses = [UICollectionViewCell.Type]()
        for type in PoqBlockType.onboardingSupportedBlockTypes {
            
            cellClasses.append(type.onboardingCellClass)
        }
        
        collectionView?.registerPoqCells(cellClasses: cellClasses)
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {            
            flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        }
        
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        
        self.onboarding = nil
        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView?.reloadData()
    }
    
    func update(using onboarding: PoqOnboarding, actionDelegate: OnboardingBlockActionDelegate) {
        self.onboarding = onboarding
        
        // Collection view arrive here with wrong size....
        collectionView?.frame = bounds
        
        self.onboarding = onboarding
        collectionView?.reloadData()
        
        self.actionDelegate = actionDelegate
    }
    
    /// Since we have some floating object on top of this collection, we should be able scrol content on top of this floating object
    /// - Parameter overlapHeight: height of overlap from content with floating views (from bottom of screen)
    func update(bottomPadding padding: CGFloat) {
        guard var insets = collectionView?.contentInset else {
            return
        }
        insets.bottom = padding
        collectionView?.contentInset = insets
    }
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let blocks = onboarding?.contentBlocks else {
            return 0
        }
        return blocks.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let block: PoqBlock = onboarding?.contentBlocks?[indexPath.row], let reuseIdentifier = block.type?.onboardingCellClass.poqReuseIdentifier else {
            Log.error("Can't find block or it's type not supported")
            return collectionView.dequeueReusableCell(withReuseIdentifier: NotFoundContentCollectionViewCell.poqReuseIdentifier, for: indexPath)
        }
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let onboardingBlockCell: OnboardingBlockCell = cell as? OnboardingBlockCell {
            onboardingBlockCell.setup(using: block)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt didSelectItemAtIndexPath: IndexPath) {
        guard let block: PoqBlock = onboarding?.contentBlocks?[didSelectItemAtIndexPath.row], let link = block.link, !link.isEmpty else {
            return
        }
        actionDelegate?.openLink(link)
    }
}
