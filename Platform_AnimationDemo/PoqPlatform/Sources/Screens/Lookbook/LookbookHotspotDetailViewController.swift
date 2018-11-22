//
//  LookbookHotspotDetailViewController.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 29/03/2016.
//
//

import PoqNetworking
import PoqAnalytics
import UIKit

class LookbookHotspotDetailViewController: PoqBaseViewController {

    var product: PoqProduct?
    
    weak var cellDelegate: ProductListViewCellDelegate?

    static let cellIndents: UIEdgeInsets = UIEdgeInsets.zero
    
    @IBOutlet weak var collectionView: UICollectionView? {
        didSet {
            collectionView?.registerPoqCells(cellClasses: [ProductListViewCell.self])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(product: PoqProduct) {
        super.init(nibName: "LookbookHotspotDetailView", bundle: nil)
        
        self.product = product
        
        self.preferredContentSize = ProductListViewCell.cellSize(product, cellInsets: LookbookHotspotDetailViewController.cellIndents)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.accessibilityIdentifier = AccessibilityLabels.lookBookHotspotDetailView
    }

}

extension LookbookHotspotDetailViewController: UICollectionViewDelegateFlowLayout {
    
    // Set cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let existedProduct: PoqProduct = product else {
            return CGSize.zero
        }
        return ProductListViewCell.cellSize(existedProduct, cellInsets: LookbookHotspotDetailViewController.cellIndents)
    }
    
    // Collection view padding
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return LookbookHotspotDetailViewController.cellIndents
    }
    
    // Cell line spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return CGFloat(ProductListViewController.rowSpacing)
        
    }
    
    // Cell column spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return CGFloat(ProductListViewController.columnSpacing)
    }
}

// MARK: Collection view data source
// _________________________________
extension LookbookHotspotDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let _: PoqProduct = product else {
            return 0
        }
        
        return 1
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let existedProduct: PoqProduct = product else {
            return UICollectionViewCell()
        }

        let cell: ProductListViewCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        cell.delegate = cellDelegate
        cell.updateView(existedProduct)
        cell.accessibilityIdentifier = AccessibilityLabels.productList
        
        cell.verticalSeparator?.isHidden = true
        cell.horizontalSeparator?.isHidden = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        
        guard let productId = product?.id else {
            return
        }
        
        NavigationHelper.sharedInstance.loadProduct(productId, externalId: product?.externalID, source: ViewProductSource.lookbookHotspotDetail.rawValue, productTitle: product?.title)
    }
}
