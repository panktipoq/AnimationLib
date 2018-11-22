//
//  BrandLandingViewController.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 01/06/2016.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

class StoryDetailViewController: PoqBaseViewController {

    weak var collectionView: UICollectionView?
    
    let storyId: Int
    
    init(storyId: Int) {
        self.storyId = storyId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.storyId = 0
        super.init(coder: aDecoder)
    }
    
    lazy var viewModel: StoryDetailViewModel = {
        [unowned self] in
        return StoryDetailViewModel(viewControllerDelegate: self, storyId: self.storyId)
    }()
    
    override func loadView() {
        
        let layout: UICollectionViewFlowLayout = BrandedSickyHeaderViewFlowLayout()
        let collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.backgroundView = nil
        
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        
        self.collectionView = collectionView
        self.view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)

        collectionView?.register(BrandedCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: BrandedHeaderReuseIdentifier)
        
        collectionView?.registerPoqCells(cellClasses: [StoryDetailBannerCell.self, StoryDetailImageCell.self, StoryDetailTextCell.self])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNavigationBrandBlock()
        
    }
    
    func getParentViewController() -> UIViewController? {
        return self.parent
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)

        if let currentParent: PoqNavigationViewController = getParentViewController() as? PoqNavigationViewController, parent == nil {
            currentParent.brandStory = nil
        }
    }
    
    override func updateRightButton(animated: Bool) {

    }
    
    // MARK: network response
    override func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        super.networkTaskDidComplete(networkTaskType)
        updateNavigationBrandBlock()
        collectionView?.reloadData()
    }
    
}

extension StoryDetailViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.sectionBlocks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item: PoqBlock = viewModel.sectionBlocks[indexPath.row]
        
        guard let blockType: PoqBlockType = item.type else {
            return UICollectionViewCell()
        }
        
        let cell: UICollectionViewCell?
        
        switch blockType {
        case .banner:
            let storyDetailBannerCell: StoryDetailBannerCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
            cell = storyDetailBannerCell
            
        case .card:

            let storyDetailImageCell: StoryDetailImageCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
            cell = storyDetailImageCell
            
        case .link:

            let storyDetailTextCell: StoryDetailTextCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
            cell = storyDetailTextCell
        default:
            Log.error("Unknown or not sutable type for story detail: \(blockType.rawValue)")
            cell = nil
        }

        if let storyDetailCell: StoryDetailBlockCell = cell as? StoryDetailBlockCell {
            storyDetailCell.updateUI(item)
        }
        
        return cell ?? UICollectionViewCell()
    }
}

extension StoryDetailViewController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let headerItem: PoqBlock = viewModel.brandedHeader else {
            return CGSize.zero
        }
        return BrandedHeaderView.calculateSize(headerItem)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let view: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BrandedHeaderReuseIdentifier, for: indexPath)
        
        if let brandedHeader: BrandedCollectionHeaderView = view as? BrandedCollectionHeaderView, let brandHeaderItem: PoqBlock = viewModel.brandedHeader {
            brandedHeader.headerBlock = brandHeaderItem
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let block: PoqBlock = viewModel.sectionBlocks[indexPath.row]
        guard let urlString: String = block.link else {
            return
        }

        NavigationHelper.sharedInstance.openURL(urlString)
    }

}

extension StoryDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard viewModel.sectionBlocks.count > indexPath.row else {
            return CGSize.zero
        }

        let block: PoqBlock = viewModel.sectionBlocks[indexPath.row]
        
        guard let blockType: PoqBlockType = block.type else {
            return CGSize.zero
        }

        var result: CGSize = CGSize.zero
        
        switch blockType {
            
        case .banner:
            result = StoryDetailBannerCell.sizeForItem(block)
            
        case .card:
            result = StoryDetailImageCell.sizeForItem(block)
            
        case .link:
            result = StoryDetailTextCell.sizeForItem(block)
        default:
            Log.error("Unknown or not sutable type for story detail: \(blockType.rawValue)")
        }
        
        return result
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let _ = viewModel.brandedHeader, section == 0 else {
            return UIEdgeInsets.zero
        }
        // TODO: this constant 5 - must be pard of app settings
        return UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard let _ = viewModel.brandedHeader, section == 0 else {
            return 0
        }
        // TODO: this constant 5 - must be pard of app settings
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: Private
extension StoryDetailViewController {

    func updateNavigationBrandBlock() {
        
        guard let brandStory: PoqStory = viewModel.story else {
            return
        }
        
        poqNavigationController?.brandStory = brandStory
    }
}
