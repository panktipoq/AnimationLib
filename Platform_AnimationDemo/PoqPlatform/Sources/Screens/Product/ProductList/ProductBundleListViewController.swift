//
//  ProductBundleListViewController.swift
//  Poq.iOS
//
//  Created by Gabriel Sabiescu on 05/08/2016.
//
//

import UIKit

open class ProductBundleListViewController: ProductGroupedListViewController {
    
    override func getData() {
        loadBundleProduct()
    }

    func loadBundleProduct() {
        viewModel?.getProductsByBundleId(groupedProduct?.bundleId)
    }
}
