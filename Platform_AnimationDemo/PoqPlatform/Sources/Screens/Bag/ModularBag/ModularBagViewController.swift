//
//  ModularBagViewController.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 11/01/2017.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

open class ModularBagViewController: PoqBaseViewController, PoqBagPresenter {
    
    @IBOutlet weak open var collectionView: UICollectionView?
    
    @IBOutlet weak var checkoutButton: UIButton?
    @IBOutlet weak var numberItemsLabel: UILabel?
    @IBOutlet weak var totalLabel: UILabel?
    
    lazy open var service: PoqBagService = {
        let service = ModularBagViewModel()
        service.presenter = self
        return service
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setCollectionViewLayout()
        service.getBag()
    }
    
    @IBAction func checkoutButtonTapped(_ sender: Any) {
            service.bagCheckout()
    }
}

extension ModularBagViewController {
    
    
    public func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.getModularBag:
            registerCells()
            collectionView?.reloadData()
            
        default:
            Log.error("Controller doesn't respond \(networkTaskType)")
        }
    }
    
    public func setCollectionViewLayout() {
        
        guard let collectionViewFlowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            
            Log.error("Collection view flow layout is not found.")
            return
        }
        
        let estimatedWidth = UIScreen.main.bounds.width
        let estimatedHeight = UIScreen.main.bounds.height
        
        // Cell heights will be defined by AutoLayout
        // EstimatedItemSize is for performance optimizations
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: estimatedWidth, height: estimatedHeight)
        
        // Space between rows for a vertical flow
        // Space between columns for a horizontal flow
        collectionViewFlowLayout.minimumLineSpacing = 0.0
        collectionViewFlowLayout.minimumInteritemSpacing = 0.0
    }
    
}

extension ModularBagViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return service.content.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let contentItem = service.content[indexPath.row]
        let reuseIdentifier = contentItem.cellType.cellClass.poqReuseIdentifier
        
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        
        if let poqBagCell = cell as? PoqBagCell {
            poqBagCell.setup(using: contentItem)
        }
        
        return cell
    }
}
