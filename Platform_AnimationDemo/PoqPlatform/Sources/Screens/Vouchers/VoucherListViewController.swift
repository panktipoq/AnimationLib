//
//  VoucherListViewController.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 27/12/2016.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

open class VoucherListViewController: PoqBaseViewController, PoqVoucherListPresenter {
    
    open lazy var service: PoqVoucherListService = {
        let service = VoucherListViewModel()
        service.presenter = self
        return service
    }()
    
    open var voucherCategoryId: Int?
    open var voucherCategoryTitle: String?
    
    @IBOutlet open var collectionView: UICollectionView?
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard let voucherCategoryTitleUnwrapped = voucherCategoryTitle else {
            Log.error("Voucher list category title not set")
            return
        }
        
        guard let voucherCategoryIdUnwrapped = voucherCategoryId else {
            Log.error("Voucer list category id not set")
            return
        }
        
        setupNavigationBar(voucherCategoryTitleUnwrapped)
        service.getVouchers(voucherCategoryIdUnwrapped)
        collectionView?.registerPoqCells(cellClasses: [VoucherListViewCell.self])
        
    }
   
    open func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.getVouchers:
            service.generateContent()
            collectionView?.reloadData()
        case PoqNetworkTaskType.postVoucher:
            PopupMessageHelper.showMessage("icn-done", message: AppLocalization.sharedInstance.voucherListVouhcerAppliedToBagPopupTitle)
        default:
            break
            
        }
        
        if networkTaskType == PoqNetworkTaskType.getVouchers {
            service.generateContent()
            collectionView?.reloadData()
        }
    }
    
    open func applyVoucherToBag(_ voucher: PoqVoucherV2) {
        PopupMessageHelper.showMessage("icn-done", message: AppLocalization.sharedInstance.voucherListVouhcerAppliedToBagPopupTitle)
    }
    
    open func openVoucherDetail(_ voucherId: Int) {
        Log.verbose("Opening voucher detail view for voucher Id \(voucherId)")
        let voucherDetailViewController = VoucherDetailViewController(nibName: "VoucherDetailView", bundle: nil)
        voucherDetailViewController.voucherId = voucherId
        NavigationHelper.sharedInstance.openController(voucherDetailViewController, modalWithNavigation: true)
    }

}

extension VoucherListViewController: UICollectionViewDataSource {
 
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let contentCount = service.content?.count else {
            
            Log.error("Content in ViewModel \(service) is not found")
            return 0
        }
        
        return contentCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let content = service.content?[indexPath.row], let _ = service.vouchers?[indexPath.row] else {
            
            Log.error("Content or Voucher in ViewModel \(service) is not found")
            return UICollectionViewCell()
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: content.type.cellIdentifier, for: indexPath)
        
        (cell as? PoqVoucherListReusableView)?.setup(using: content)
        (cell as? PoqVoucherListReusableView)?.presenter = self
        
        return cell
    }
    
}

extension VoucherListViewController: UICollectionViewDelegateFlowLayout {
    
    // Set cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let voucherCellHeight = CGFloat(AppSettings.sharedInstance.voucherListCellHeight)
        let voucherCellWidth = collectionView.bounds.width
        return CGSize(width: voucherCellWidth, height: voucherCellHeight)
    }
    
}
