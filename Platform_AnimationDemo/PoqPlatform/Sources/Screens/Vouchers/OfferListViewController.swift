//
//  OfferListViewController.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 05/01/2017.
//
//

import PoqNetworking
import PoqUtilities
import UIKit


open class OfferListViewController: PoqBaseViewController, PoqOfferListPresenter {
    
    open lazy var service: PoqOfferListService = {
        let service = OfferListViewModel()
        service.presenter = self
        return service
    }()
    
    @IBOutlet open weak var collectionView: UICollectionView?
    
    open override func viewDidLoad() {
        
        setupNavigationBar()
        service.getOffers()
        collectionView?.registerPoqCells(cellClasses: [OfferListViewCell.self])
        
    }
    
    open func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if networkTaskType == PoqNetworkTaskType.getOffers {
            service.generateContent()
            collectionView?.reloadData()
        }
    }
    
    
}

extension OfferListViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let contentCount = service.content?.count else {
            
            Log.error("Content in ViewModel \(service) is not found")
            return 0
        }
        
        return contentCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let content = service.content?[indexPath.row] else {
            
            Log.error("Content in ViewModel \(service) is not found")
            return UICollectionViewCell()
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: content.type.cellIdentifier, for: indexPath)
        
        (cell as? PoqOfferListReusableView)?.setup(using: content)
        (cell as? PoqOfferListReusableView)?.presenter = self
        
        return cell
    }
    
}

extension OfferListViewController: UICollectionViewDelegateFlowLayout {
    
    // Set cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let offerCellHeight = CGFloat(AppSettings.sharedInstance.offerListCellHeight)
        let offerCellWidth = collectionView.bounds.width
        return CGSize(width: offerCellWidth, height: offerCellHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return CGFloat(AppSettings.sharedInstance.offerListRowSpacing)
    }
    
}
