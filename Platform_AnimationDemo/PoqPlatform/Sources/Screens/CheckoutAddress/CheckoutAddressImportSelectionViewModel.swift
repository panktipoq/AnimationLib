//
//  CheckoutSelectionOfAddressTypeViewModel.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 10/16/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation

open class CheckoutAddressImportSelectionViewModel: BaseViewModel {
    
    open var contactInformation: [String?]?
    open var headerTitle: String?
}

// MARK: - TableView Operations
// ____________________________

extension CheckoutAddressImportSelectionViewModel {
    
    open func getNumberOfContactInfoRows() -> Int {
        return contactInformation?.count ?? 0
    }
    
    open func getCellForRowAtIndexPath(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        guard let information = contactInformation else {
            return UITableViewCell()
        }
        
        let cell: ProductSizeTableViewCell = tableView.dequeueReusablePoqCell()!
        
        cell.sizeLabel?.text = information[indexPath.row]
        return cell
    }
    
    open func getViewForHeaderInSection(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let sizeSelectorHeader = SizeSelectorHeader(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40), headerTitle: headerTitle ?? "")
        sizeSelectorHeader.backgroundColor = UIColor.white
        return sizeSelectorHeader
    }
}
