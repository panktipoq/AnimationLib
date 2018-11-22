//
//  AppStoriesCarouselCell.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 8/1/17.
//
//

import PoqModuling
import PoqNetworking
import PoqUtilities
import UIKit

public struct AppStoryCarouselContentItem {
    let story: PoqAppStory
    var isViewed: Bool
}

/// This protocol should be adopted by cells that are displayed in the App Story carousel
public protocol AppStoryCell: SkeletonViewCell {
    
    /// This function will set up the app story cell with a given content item
    ///
    /// - Parameter storyItem: This item will have all the info needed to setup the cell
    func setup(using storyItem: AppStoryCarouselContentItem)
}

let AppStoriesCarouselAccessibilityId = "AppStoriesCarouselAccessibilityId" 

open class AppStoriesCarouselCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, HomeBannerCell, AppStoryCarouselPresenter, AppStoryNavigationControllerDelegate {
    
    /// Size for Card Type AppStoriesCarouselCell in outer UICollectionView
    static let cardTypeCarouselSize: CGSize = {
        // Inner card cell height must be less than height of `AppStoriesCarouselCell.collectionView`, otherwise we will see these in log:
        /*
         The behavior of the UICollectionViewFlowLayout is not defined because:
         the item height must be less than the height of the UICollectionView minus the section insets top and bottom values, minus the content insets top and bottom values
         */
        return CGSize(width: UIScreen.main.bounds.size.width, height: cardCellSize.height + 1)
    }()
    
    /// Size for Circle Type AppStoriesCarouselCell in outer UICollectionView
    static let circleTypeCarouselSize: CGSize = {
        
        // Inner circular cell height must be less than height of `AppStoriesCarouselCell.collectionView`, otherwise we will see these in log:
        /*
         The behavior of the UICollectionViewFlowLayout is not defined because:
         the item height must be less than the height of the UICollectionView minus the section insets top and bottom values, minus the content insets top and bottom values
         */
        return CGSize(width: UIScreen.main.bounds.size.width, height: circleCellSize.height + 1)
    }()
    
    fileprivate static let cardCellSize: CGSize = {
        
        let cardWidth = cardWidthRatioToScreenWidth * UIScreen.main.bounds.size.width
        
        // Image Ratio for circular carousel will be 1. Widht needs to be equal to height for circular stories.
        let imageSizedRatio = CGFloat(AppSettings.sharedInstance.appStoriesCarouselImageRatio)
        let cardHeight = cardWidth/imageSizedRatio
        
        // Image has indents in cell: 8 on top + 8 on bottom. 8 + 8 = 16
        let imageIndentAdjustment: CGFloat = 16
        return CGSize(width: cardWidth, height: cardHeight + imageIndentAdjustment)
    }()
    
    fileprivate static let circleCellSize: CGSize = {
       
        let circleWidth = circleWidthRatioToScreenWidth * UIScreen.main.bounds.size.width
        
        // Image Ratio for circular carousel will be 1. Width needs to be equal to height for circular stories.
        let circleHeight = circleWidth
        
        return CGSize(width: circleWidth, height: circleHeight)
    }()
    
    // These properties can be set by clients to customise the size the of the cells.
    public static var cardWidthRatioToScreenWidth: CGFloat = 0.7
    public static var circleWidthRatioToScreenWidth: CGFloat = 0.24

    fileprivate var storyCarouselType: StoryCarouselType = .card

    @IBOutlet weak var collectionView: UICollectionView?
    
    fileprivate var appStories = [AppStoryCarouselContentItem?]()
    fileprivate weak var presenter: HomeViewController?
    
    open override func awakeFromNib() {
        
        super.awakeFromNib()

        collectionView?.registerPoqCells(cellClasses: [AppStoryCarouselCardCell.self, AppStoryCarouselCircularCell.self])

        collectionView?.backgroundColor = UIColor.clear
        collectionView?.backgroundView = nil
        
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
    }

    // MARK: - HomeBannerCell
    public func updateUI(_ bannerItem: HomeBannerItem, delegate: HomeViewController) {
        accessibilityIdentifier = AppStoriesCarouselAccessibilityId
        guard case .stories(let stories, let storyCarouselType) = bannerItem.type else {
            Log.error("We pass wrong HomeBannerItem to \(AppStoriesCarouselCell.self). Expected .stories")
            return
        }
        // Enable back the interaction just in case skeletons were enabled
        isUserInteractionEnabled = true
        appStories = [AppStoryCarouselContentItem]()
        for story in stories {
            appStories.append(AppStoryCarouselContentItem(story: story, isViewed: false))
        }
        
        // Update the flow layout and its items size
        updateLayout(withStoryCarouselType: storyCarouselType)
        
        PoqDataStore.store?.getAll { (results: [ViewedAppStory]) in
            let allStories = self.appStories.compactMap({ $0?.story })
            for story in results {
                if let index = allStories.index(where: { $0.identifier == story.storyId }) {
                    self.appStories[index]?.isViewed = true
                }
            }
            self.collectionView?.reloadData()
        }
        
        presenter = delegate
    }
    
    public func updateLayout(withStoryCarouselType: StoryCarouselType) {
        
        self.storyCarouselType = withStoryCarouselType
        // Define insets here, since they are depends on number of items
        let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        if appStories.count == 1 && storyCarouselType == .card {
            // For single stories .card we center the carousel to look better.
            // .circular stories will be always left align to be consistent with social media layouts.
            let leftRightInset = 0.5 * (UIScreen.main.bounds.size.width - AppStoriesCarouselCell.cardCellSize.width)
            flowLayout?.sectionInset = UIEdgeInsets(top: 0, left: leftRightInset, bottom: 0, right: leftRightInset)
        } else {
            let leftRightInset: CGFloat = 15
            flowLayout?.sectionInset = UIEdgeInsets(top: 0, left: leftRightInset, bottom: 0, right: leftRightInset)
        }
        flowLayout?.itemSize = storyCarouselType == .card ? AppStoriesCarouselCell.cardCellSize : AppStoriesCarouselCell.circleCellSize
    }

    // MARK: - UICollectionViewSkeletonCell

    public func setupSkeleton(image: UIImage, padding: UIEdgeInsets, contentMode: UIViewContentMode, cornerRadius: CGFloat) {
        // Since this cell doesn't host the actual images, we will place the logic here
        isUserInteractionEnabled = false
        appStories = [nil, nil, nil, nil, nil]
    }
    
    // MARK: - UICollectionViewDataSource

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appStories.count
    }
    
    public func carouselCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, cellIdentifier: String) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        guard let appStoryCell = cell as? AppStoryCell else {
            Log.error("Cell is not of type AppStoryCell")
            return UICollectionViewCell()
        }
        
        if let storyItem = appStories[indexPath.row] {
            appStoryCell.setup(using: storyItem)
        } else {
            guard let skeletonImage = ImageInjectionResolver.loadImage(named: "loadingFrame") else {
                Log.error("Couldn't unwrap skeletonImage")
                return UICollectionViewCell()
            }
            appStoryCell.setupSkeleton(image: skeletonImage, padding: UIEdgeInsets.zero, contentMode: .scaleToFill, cornerRadius: 0)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch storyCarouselType {
        case .card:
            return carouselCell(collectionView, cellForItemAt: indexPath, cellIdentifier: AppStoryCarouselCardCell.poqReuseIdentifier)
        case .circular:
            return carouselCell(collectionView, cellForItemAt: indexPath, cellIdentifier: AppStoryCarouselCircularCell.poqReuseIdentifier)
        }
    }
    
    open func getStoriesViewController(appStories: [PoqAppStory], selectedIndex: Int) -> AppStoryNavigationController? {
        
        let storiesViewController = AppStoryNavigationController(appStories: appStories, selectedIndex: selectedIndex, storyCarouselType: storyCarouselType)
        storiesViewController?.carouselDelegate = self
        storiesViewController?.navigateToStory(at: selectedIndex, presentedCard: .first)
        
        return storiesViewController
    }
    
    // MARK: - UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentIndex = findCurrentCarouselIndex()
        
        // If the selected item is not in the center or if the story type circular adjust the content offset for a read story
        if indexPath.row != currentIndex || storyCarouselType == .circular {
            let offset = calculateOffset(for: indexPath.row)
            collectionView.setContentOffset(offset, animated: true)
        }
        
        guard let storiesViewControllerUnwrapped = getStoriesViewController(appStories: appStories.compactMap { $0?.story }, selectedIndex: indexPath.row) else {
            
            Log.error("Smth wrong in AppStoriesNavigationViewController. We got nil from init")
            return
        }
        
        storiesViewControllerUnwrapped.storyCarouselPresenter = self
        
        presenter?.present(storiesViewControllerUnwrapped, animated: true) {
            // Track user plays a story
            let stories = self.appStories.compactMap({ $0?.story })
            let titleOfSelectedStory = stories[indexPath.row].title
            PoqTrackerHelper.trackOpenAppStories(storyTitle: titleOfSelectedStory ?? "")
        }
    }
    
    // MARK: - AppStoryNavigationControllerDelegate
    public func appStoryNavigationControllerDidNavigateToStory(atIndex index: IndexPath) {
        guard let storyId = appStories[index.row]?.story.identifier else {
            Log.error("There isn't a story ID")
            return
        }
        var story = ViewedAppStory()
        story.storyId = storyId
        PoqDataStore.store?.create(story, maxCount: nil, completion: nil)

        switch storyCarouselType {
        case .card:
            let cell = collectionView?.cellForItem(at: index) as? AppStoryCarouselCardCell
            cell?.storyHasBeenRead(true)
        case .circular:
            let cell = collectionView?.cellForItem(at: index) as? AppStoryCarouselCircularCell
            cell?.storyHasBeenRead(true)
        }

        appStories[index.row]?.isViewed = true
        PoqDataStore.store?.getAll { (results: [ViewedAppStory]) in
            let allStories = self.appStories.compactMap({ $0?.story })
            for story in results {
                if let index = allStories.index(where: { $0.identifier == story.storyId }) {
                    self.appStories[index]?.isViewed = true
                }
            }
        }
    }

    fileprivate var startDraggingIndex: Int?
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startDraggingIndex = findCurrentCarouselIndex()
        
    }
   
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        guard case StoryCarouselType.card = storyCarouselType else {
            Log.info("No paging for circular stories")
            return
        }
        
        guard let startDraggingIndexUnwrapped = startDraggingIndex else {
            Log.error("We stop deceleration without current index")
            return
        }

        let nextIndex: Int
        
        let currentIndex = findCurrentCarouselIndex()
        
        /// Assume that everying what is below - not a swipe, just finger shaking
        let minSwipeVelocity: CGFloat = 0.6
        if abs(velocity.x) > minSwipeVelocity {

            if velocity.x > minSwipeVelocity {
                if currentIndex > startDraggingIndexUnwrapped {
                    nextIndex = currentIndex
                } else {
                    nextIndex = currentIndex + 1
                }
                
            } else {
                
                if currentIndex < startDraggingIndexUnwrapped {
                    nextIndex = currentIndex
                } else {
                    nextIndex = currentIndex - 1
                }
            }
        } else {

            // Assume that we can't scroll to bring card over one
            nextIndex = findCurrentCarouselIndex()
        }

        targetContentOffset.pointee = calculateOffset(for: nextIndex)
    }
    
    // MARK: - AppStoryCarouselPresenter
    public func storyWasPresented(at index: Int) {
        let offset = calculateOffset(for: index)
        collectionView?.contentOffset = offset
    }
    
    // MARK: - Helpers
    
    func shouldShowSkeletons() -> Bool {
        if HomeViewController.isSkeletonsEnabled && appStories.isEmpty {
            return true
        }
        return false
    }
    
    // MARK: - Private
    
    /// return index of int for carousel, by checking which card in central of screen(or closes to it)
    /// - NOTE: undefined behaviour for empty collection view
    fileprivate func findCurrentCarouselIndex() -> Int {
        guard  let collectionViewUnwrapped = collectionView, collectionViewUnwrapped.numberOfItems(inSection: 0) > 0 else {
            Log.error("We got empty or not existed collection view")
            return 0
        }
        
        // Cell center in collection view coordinated
        let centerPoint = CGPoint(x: collectionViewUnwrapped.bounds.midX, y: collectionViewUnwrapped.bounds.midY)

        typealias DistanceToCell = (index: Int, distance: CGFloat)
        
        var distances = [DistanceToCell]()
        
        let numberOfCells = collectionViewUnwrapped.numberOfItems(inSection: 0)
        
        for i in 0..<numberOfCells {
            let indexPath = IndexPath(row: i, section: 0)
            
            guard let attributes = collectionViewUnwrapped.collectionViewLayout.layoutAttributesForItem(at: indexPath) else {
                continue
            }

            let distance = attributes.frame.distance(to: centerPoint)

            distances.append((indexPath.row, distance))
        }
        
        distances.sort {
            (lhs: DistanceToCell, rhs: DistanceToCell) in
            return lhs.distance < rhs.distance
        }
        
        return distances[0].index
    }
    
    /// Calculate offset to place card at `index` to center of screent
    fileprivate func calculateOffset(for index: Int) -> CGPoint {
        
        switch storyCarouselType {
        case .card:
            return calculateOffsetForCardTypeCarousel(for: index)
            
        case .circular:
            return calculateOffsetForCircularTypeCarousel(for: index)
        }
    }
    
    fileprivate func calculateOffsetForCircularTypeCarousel(for index: Int) -> CGPoint {
        
        guard  let collectionViewUnwrapped = collectionView, collectionViewUnwrapped.numberOfItems(inSection: 0) > 0 else {
            Log.error("We got empty or not existent collection view")
            return CGPoint.zero
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        
        guard let attributes = collectionViewUnwrapped.collectionViewLayout.layoutAttributesForItem(at: indexPath) else {
            Log.error("We can't get attributes for cell at index \(index)")
            return CGPoint.zero
        }
        
        var xOffset = attributes.frame.origin.x
        var maxXOffset = collectionViewUnwrapped.contentSize.width - collectionViewUnwrapped.bounds.size.width
        maxXOffset = max(0, maxXOffset)
        xOffset = min(maxXOffset, xOffset)

        return CGPoint(x: xOffset, y: 0)
    }
    
    fileprivate func calculateOffsetForCardTypeCarousel(for index: Int) -> CGPoint {
        
        guard  let collectionViewUnwrapped = collectionView, collectionViewUnwrapped.numberOfItems(inSection: 0) > 0 else {
            Log.error("We got empty or not existent collection view")
            return CGPoint.zero
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        
        guard let attributes = collectionViewUnwrapped.collectionViewLayout.layoutAttributesForItem(at: indexPath) else {
            Log.error("We can't get attributes for cell at index \(index)")
            return CGPoint.zero
        }
        
        var xOffset = attributes.frame.origin.x + 0.5 * attributes.frame.size.width - 0.5 * collectionViewUnwrapped.bounds.size.width
        /// Special case, when left item is not centered
        xOffset = max(0, xOffset)
        let maxXOffset = collectionViewUnwrapped.contentSize.width - collectionViewUnwrapped.bounds.size.width
        xOffset = min(maxXOffset, xOffset)
        
        return CGPoint(x: xOffset, y: 0)
    }

}
