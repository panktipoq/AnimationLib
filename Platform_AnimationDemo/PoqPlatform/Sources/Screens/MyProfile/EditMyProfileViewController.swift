//
//  EditMyProfileViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 19/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit
import PoqAnalytics

open class EditMyProfileViewController: SignUpViewController {
 
    var isModalView: Bool = false
    
    var isFormValid: Bool = false {
        didSet {
            saveButton?.isEnabled = isFormValid
        }
    }

    fileprivate var idDatePickerShown = false
    fileprivate var saveButton: UIBarButtonItem?

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup tableview
        
              tableView?.registerPoqCells(cellClasses: [MyProfileAddressBookTitleTableViewCell.self])

        viewModel.setupContentForEditMyProfile()
        saveButton = NavigationBarHelper.createButtonItem(withTitle: AppLocalization.sharedInstance.editMyProfileSaveButtonText,
                                                          target: self,
                                                          action: #selector(EditMyProfileViewController.saveButtonClicked))
        
        setUpNavigationBar(AppLocalization.sharedInstance.editMyProfileTitle, leftBarButtonItem: NavigationBarHelper.setupBackButton(self), rightBarButtonItem: saveButton)
    }
    
    @objc public func saveButtonClicked() {
        viewModel.updateAccount()
        saveButton?.isEnabled = false
    }

    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        super.networkTaskDidFail(networkTaskType, error: error)
        saveButton?.isEnabled = true
    }

    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        saveButton?.isEnabled = true
        if networkTaskType == PoqNetworkTaskType.updateAccount {
            // Track analytics
            PoqTrackerV2.shared.editDetails(userId: User.getUserId())
            _ = navigationController?.popViewController(animated: true)
        }
    }

    // MARK: UITableViewDelegate

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.content[indexPath.row].type != MyProfileContentItemType.date {
            return
        }
        
        // here I assume date picker always next after date
        let datePickerIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        
        // we need insert/delete date picker
        tableView.beginUpdates()
        if let _ = viewModel.indexOf(itemWithType: .datePicker) {
            
            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
            viewModel.content.remove(at: datePickerIndexPath.row)
            
        } else {
            tableView.insertRows(at: [datePickerIndexPath], with: .fade)
            var datePickerItem = MyProfileContentItem(type: .datePicker)
            datePickerItem.firstInputItem.value = viewModel.contentItem(typeOf: .date)?.firstInputItem.value
            viewModel.content.insert(datePickerItem, at: datePickerIndexPath.row)
        }
        tableView.endUpdates()
    }
}
