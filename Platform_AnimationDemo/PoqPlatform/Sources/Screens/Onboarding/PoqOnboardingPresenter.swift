//
//  PoqOnboardingPresenter.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 29/12/2016.
//
//

import Foundation
import PoqNetworking

public protocol PoqOnboardingPresenter: PoqPresenter {
    
    static var shouldShowOnboarding: Bool { get set }
    
    var pagesCollectionView: UICollectionView? { get }
    
    var completeButton: UIButton? { get }
    var pageControl: UIPageControl? { get }
    
    var viewModel: OnboardingService { get }
    
    /// Update state of page controller after scrolling: hides/show or switch pages
    func updatePageControl()
    
    /// For any kind of reason we need sceoll to specific page
    func scrollTo(pageIndex index: Int, animated: Bool)
    
    /// If need update cells bottom paddings because of floating button
    /// Update bottom padding for all presented cell. During scrolling update should take plae on its own by presenter for each cell
    func updateCellsBottomPadding()
    
    // MARK: UI setup methods
    /// Create initial state of items
    func setupCompleteButton()
    func setupCollectionView()
    
    /// Should be colled while user scrolling
    func updateBackgroundColor()

}

let OnboardingShownStatusDefaultsKey: String = "PoqOnboardingShownStatus" 

extension PoqOnboardingPresenter where Self: PoqBaseViewController {
    
    public static var shouldShowOnboarding: Bool {
        get {
            let alreadyShown = UserDefaults.standard.bool(forKey: OnboardingShownStatusDefaultsKey)
            return AppSettings.sharedInstance.isOnboardingAvailable && !alreadyShown
        }
        set(value) {
            UserDefaults.standard.set(!value, forKey: OnboardingShownStatusDefaultsKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    public func updatePageControl() {
        pageControl?.numberOfPages = viewModel.pages.count
        pageControl?.isHidden = viewModel.pages.count < 2 || !AppSettings.sharedInstance.onboardingShowPageControl
        
        // update current page
        guard let offset = pagesCollectionView?.contentOffset, viewModel.pages.count > 1 else {
            return
        }
        let pageWidth = UIScreen.main.bounds.size.width
        
        let floatIndex = offset.x/pageWidth
        var index = Int(floatIndex)
        if floatIndex > CGFloat(index) + 0.5 {
            index += 1
        }
        
        // sanity check
        if index >= viewModel.pages.count {
            index = viewModel.pages.count - 1
        } else  if index < 0 {
            index = 0
        }
        
        pageControl?.currentPage = index
    }
   
    public func updateCellsBottomPadding() {
        
        let onboardingPageCells: [UICollectionViewCell] = pagesCollectionView?.visibleCells ?? []
        for cell in onboardingPageCells {
            guard let onboardingPageCell = cell as? OnboardingPageCell, let existedButton = completeButton else {
                continue
            }
            let overlatHeight = view.frame.size.height - existedButton.frame.minY
            onboardingPageCell.update(bottomPadding: overlatHeight)
        }

    }
    
    public func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        updateBackgroundColor()
        updatePageControl()
        pagesCollectionView?.reloadData()
    }
    
    public func setupCollectionView() {
        pagesCollectionView?.registerPoqCells(cellClasses: [OnboardingPageCell.self])
        pagesCollectionView?.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    public func updateBackgroundColor() {
        guard  let scrollView = pagesCollectionView else {
            return
        }
        let color = createColor(forBoundsX: scrollView.contentOffset.x)
        pagesCollectionView?.backgroundColor = color
    }
    
    public func scrollTo(pageIndex index: Int, animated: Bool = true) {

        pagesCollectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: animated)
    }
    
    /// create color according to contentOffset and 'viewModel.colorPoints'
    fileprivate func createColor(forBoundsX x: CGFloat) -> UIColor? {
        
        let colorPoints: [ColorPoint] = viewModel.colorPoints
        guard colorPoints.count > 0 else {
            return UIColor.white
        }
        
        // we need find points a and b, where x belongs to [a, b]
        // a and b can be equal
        var lower: Int = 0
        var upper: Int = 0
        for i in 0..<colorPoints.count {
            
            let colorPoint = colorPoints[i]
            if i == colorPoints.count - 1 {
                // we bounce out of right edge
                if colorPoint.boundsX < x {
                    lower = i
                    upper = i
                }
                break
            }
            
            let nextColorPoint = colorPoints[i + 1]
            if colorPoint.boundsX <= x && x <= nextColorPoint.boundsX {
                lower = i
                upper = i + 1
                break
            }
        }
        
        let coef: CGFloat
        if lower != upper {
            coef = (x - colorPoints[lower].boundsX) / (colorPoints[upper].boundsX - colorPoints[lower].boundsX)
        } else {
            coef = 0
        }
        
        let red = colorPoints[lower].red + coef * (colorPoints[upper].red - colorPoints[lower].red)
        let green = colorPoints[lower].green + coef * (colorPoints[upper].green - colorPoints[lower].green)
        let blue = colorPoints[lower].blue + coef * (colorPoints[upper].blue - colorPoints[lower].blue)
        let alpha = colorPoints[lower].alpha + coef * (colorPoints[upper].alpha - colorPoints[lower].alpha)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
