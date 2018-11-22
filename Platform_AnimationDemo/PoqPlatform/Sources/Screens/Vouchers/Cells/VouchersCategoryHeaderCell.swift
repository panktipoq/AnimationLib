//
//  VouchersCategoryHeaderCell.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 1/3/17.
//
//

import PoqNetworking
import UIKit

public protocol VouchersCategoryHeaderCellDelegate: AnyObject {
    
    func headerCell(_ headerCell: VouchersCategoryHeaderCell, didSelectItemAtIndexPath indexPath: IndexPath)
    
    func numberOfItemsInHeaderCell(_ headerCell: VouchersCategoryHeaderCell) -> Int
    
    func headerCell(_ headerCell: VouchersCategoryHeaderCell, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
}

open class VouchersCategoryHeaderCell: UICollectionViewCell, VouchersCategoryResuableView {
    
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var pageControl: UIPageControl?
    
    weak var delegate: VouchersCategoryHeaderCellDelegate?
    
    // MARK: - Properties
    
    weak open var presenter: VouchersCategoryPresenter?
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup collection view
        collectionView?.isPagingEnabled = true
        collectionView?.alwaysBounceVertical = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        // Setup page conrol
        pageControl?.hidesForSinglePage = true
        pageControl?.numberOfPages = 1
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        collectionView?.setCollectionViewLayout(flowLayout, animated: false)
    }
    
    open func setup(using content: VouchersCategoryContent, with category: PoqVoucherCategory?) {
        pageControl?.pageIndicatorTintColor = UIColor(red: 0, green: 132.0/255.0, blue: 208.0/255.0, alpha: 0.2)
        pageControl?.currentPageIndicatorTintColor = UIColor(red: 0, green: 132.0/255.0, blue: 208.0/255.0, alpha: 1.0)
        
        delegate = presenter as? VouchersCategoryHeaderCellDelegate
        
        collectionView?.registerPoqCells(cellClasses: [VouchersCategoryFeaturedCell.self, VouchersCategoryFeaturedLogoCell.self])
        
        collectionView?.reloadData()
        pageControl?.numberOfPages = presenter?.service.featuredVouchers.count ?? 1
    }
}

// MARK: - UICollectionViewDelegate

extension VouchersCategoryHeaderCell {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.headerCell(self, didSelectItemAtIndexPath: indexPath)
    }
}

extension VouchersCategoryHeaderCell: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Carousel collection view
        return collectionView.bounds.size
    }
}

// MARK: - UICollectionViewDataSource

extension VouchersCategoryHeaderCell: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.numberOfItemsInHeaderCell(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = delegate?.headerCell(self, cellForItemAtIndexPath: indexPath)
        
        return cell!
    }
}

// MARK: - UIScrollViewDelegate

extension VouchersCategoryHeaderCell: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Calculate current page
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageControl?.currentPage = page
    }
}
