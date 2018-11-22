//
//  PoqProductSwatchColorsContentBlockView.swift
//  Poq.iOS.Belk
//
//  Created by Manuel Marcos Regalado on 13/02/2017.
//
//

import PoqModuling
import PoqNetworking
import PoqUtilities
import UIKit

open class PoqProductSwatchColorsContentBlockView: FullWidthAutoresizedCollectionCell, PoqProductDetailCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet open weak var collectionView: UICollectionView?
    @IBOutlet open weak var colorNameLabel: UILabel?
    @IBOutlet public weak var separator: SolidLine?

    // ______________________________________________________
    
    // MARK: - Properties
    
    var product: PoqProduct?
    weak open var presenter: PoqProductBlockPresenter?

    open var colors = [PoqProductColor]()
    open var selectedColorIndex: Int?
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView?.registerPoqCells(cellClasses: [ColorSwatchCell.self])
        collectionView?.accessibilityIdentifier = AccessibilityLabels.pdpColorSwatch
        
        if !AppSettings.sharedInstance.pdpProductColorSwatchesShowsSelectedColorName {
            collectionView?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        }
    }
        
    // ______________________________________________________
    
    // MARK: - Content Setup
    
    open func setup(using content: PoqProductDetailContentItem, with product: PoqProduct?) {
        
        self.product = product
        
        self.colors = product?.productColors ?? []
        
        collectionView?.reloadData()

        if let selectedColorProductID = product?.selectedColorProductID, let index = colors.index(where: { $0.productID == selectedColorProductID }) {
            selectedColorIndex = index
            
            var colorTitle = ""
            if let title = product?.color {
               colorTitle = "\("COLOUR".localizedPoqString): \(title)"
            }

            colorNameLabel?.text = colorTitle  
        } else {

            selectedColorIndex = nil
            colorNameLabel?.text = nil
        }
    }

    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ColorSwatchCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.setup(using: colors[indexPath.row], selected: selectedColorIndex == indexPath.row)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let colorId = colors[indexPath.row].id, let externalId = colors[indexPath.row].externalID else {
            Log.error("We don't have external or internal id")
            return
        }
        presenter?.colorSelected(productColorId: colorId, productColorExternalId: externalId)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let screenEdgePadding: CGFloat = 15
        
        guard AppSettings.sharedInstance.isPdpProductColorSwatchesCentered, let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return UIEdgeInsets(top: 0, left: screenEdgePadding, bottom: 0, right: screenEdgePadding)
        }
        
        // Even if want centered: we need check that we don't fill screen fully
        let countFloat = CGFloat(colors.count)
        let width = flowLayout.itemSize.width * countFloat + flowLayout.minimumLineSpacing * (countFloat - 1.0)
        let screenWidth = window?.bounds.size.width ?? 0
        if width >= screenWidth + 2.0 * screenEdgePadding {
            return UIEdgeInsets(top: 0, left: screenEdgePadding, bottom: 0, right: screenEdgePadding)
        }
        
        let centeringScreenEdgePadding = 0.5 * (screenWidth - width)
        
        return UIEdgeInsets(top: 0, left: centeringScreenEdgePadding, bottom: 0, right: centeringScreenEdgePadding)
    }
}
