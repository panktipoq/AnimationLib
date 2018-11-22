//
//  PoqBagPresenter.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 11/01/2017.
//
//

import Foundation
import PoqUtilities
import UIKit

public protocol PoqBagPresenter: PoqPresenter {
    
    var collectionView: UICollectionView? { get set }
    var service: PoqBagService { get }
    
    func setupNavigationBar()
    func editBag()
    func registerCells()
}


extension PoqBagPresenter where Self: PoqBaseViewController {
    
    public func registerCells() {

        var cellClasses = [UICollectionViewCell.Type]()
        for contentItem in service.content {
            let cellClass = contentItem.cellType.cellClass
            cellClasses.append(cellClass)
        }
        
        collectionView?.registerPoqCells(cellClasses: cellClasses)

    }
    
    public func editBag() {
        
        //To be done
        Log.verbose("Edit Bag....")
    }
    
    public func setupNavigationBar() {
        navigationItem.titleView = NavigationBarHelper.setupTitleView("Shopping Bag")
        navigationItem.rightBarButtonItem = NavigationBarHelper.setupTopRightBarButton(.edit, targetName: self, actionName: Selector(("editBag")))
    }
}
