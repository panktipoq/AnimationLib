//
//  VouchersCategoryViewController.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 12/23/16.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

open class VouchersCategoryViewController: PoqBaseViewController, VouchersCategoryPresenter, UICollectionViewDelegateFlowLayout, VouchersCategoryHeaderCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    lazy open var service: VouchersCategoryService = {
        
        let service = VouchersCategoryViewModel()
        service.presenter = self
        return service
    }()
    
    public init() {
        super.init(nibName: "VouchersCategoryViewController", bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        customizeCollectionView()
        
        setRefreshControl()
        service.getDashboardItems()
    }
    
    open func setRefreshControl() {
        
        let refreshControl = UIRefreshControl()
        
        collectionView?.refreshControl = refreshControl        
        refreshControl.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(startRefresh(_:)), for: .valueChanged)
    }
    
    @objc func startRefresh(_ refreshControl: UIRefreshControl) {
        service.getDashboardItems()
        
        refreshControl.endRefreshing()
    }
    
    func customizeCollectionView() {
        // Customize collectionView
        collectionView?.registerPoqCells(cellClasses:
            [VouchersCategoryHeaderCell.self,
            VouchersCategorySectionHeaderCell.self,
            VouchersCategoryElementCell.self])
        
        collectionView?.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
    }
    
    open func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.getVouchersDashboard:
            service.generateContent()
            collectionView?.reloadData()
            
        default:
            Log.error("Controller doesn't respond \(networkTaskType)")
        }
    }
    
    open func headerCell(_ headerCell: VouchersCategoryHeaderCell, didSelectItemAtIndexPath indexPath: IndexPath) {
        
        guard service.featuredVouchersContent[indexPath.row].type == VouchersCategoryFeaturedContentType.element,
            let voucherId = service.featuredVouchers[indexPath.row].id else {
                
                return
        }
        
        let voucherDetailViewController = VoucherDetailViewController(nibName: "VoucherDetailView", bundle: nil)
        voucherDetailViewController.voucherId =  voucherId
        NavigationHelper.sharedInstance.openController(voucherDetailViewController, modalWithNavigation: true)
    }
    
    public func numberOfItemsInHeaderCell(_ headerCell: VouchersCategoryHeaderCell) -> Int {
        
        return service.featuredVouchersContent.count
    }
    
    open func headerCell(_ headerCell: VouchersCategoryHeaderCell, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let collectionView = headerCell.collectionView else {
            return UICollectionViewCell()
        }
        
        let content = service.featuredVouchersContent
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: content[indexPath.row].type.cellIdentifier, for: indexPath)
        
        let voucher: PoqVoucherV2? = service.featuredVouchers.count > indexPath.row ? service.featuredVouchers[indexPath.row] : nil
        
        (cell as? VouchersCategoryFeaturedResuableView)?.presenter = self
        (cell as? VouchersCategoryFeaturedResuableView)?.setup(using: content[indexPath.row], with: voucher)
        
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard service.content[indexPath.row].type == VouchersCategoryContentType.element else {
            return
        }
        
        if let categoryId = service.contentData[indexPath.row]?.id, let categoryTitle = service.contentData[indexPath.row]?.title {
            
            let voucherListViewController = VoucherListViewController(nibName: "VoucherListView", bundle: nil)
            voucherListViewController.voucherCategoryId =  categoryId
            voucherListViewController.voucherCategoryTitle = categoryTitle
            NavigationHelper.sharedInstance.openController(voucherListViewController)
            
        } else if let categoryTitle = service.contentData[indexPath.row]?.title, categoryTitle == "View all Offers".localizedPoqString {
            
            let offersViewController = OfferListViewController(nibName: "OfferListView", bundle: nil)
            NavigationHelper.sharedInstance.openController(offersViewController)
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: service.content[indexPath.row].type.height )
    }
}

// MARK: - UICollectionViewDataSource

extension VouchersCategoryViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return service.content.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: service.content[indexPath.row].type.cellIdentifier, for: indexPath)
        
        (cell as? VouchersCategoryResuableView)?.presenter = self
        (cell as? VouchersCategoryResuableView)?.setup(using: service.content[indexPath.row], with: service.contentData[indexPath.row])
        
        return cell
    }
    
}
