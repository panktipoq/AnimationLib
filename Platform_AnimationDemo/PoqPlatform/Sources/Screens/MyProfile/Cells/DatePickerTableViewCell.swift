//
//  DatePickerTableViewCell.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 12/8/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import UIKit

/// Protocol that comunicates the change of the date
public protocol DatePickerCellDelegate {
    func dateWasChanged(_ date: Date)
}

/// Cell containing a date picker 
public class DatePickerTableViewCell: UITableViewCell {

    /// The cell's date picker
    @IBOutlet weak var datePicker: UIDatePicker?
    
    /// The delegate receiving the date picker actions
    var delegate: DatePickerCellDelegate?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        datePicker?.addTarget(self, action: #selector(DatePickerTableViewCell.changeDate(_:)), for: UIControlEvents.valueChanged)
    }
    
    /// Sets up the date picker with a date
    ///
    /// - Parameter date: The date to which the picker will be set to
    public func setUpPicker(_ date: String?) {
        datePicker?.minimumDate = DateHelper().getMinimumDate() as Date?
        datePicker?.maximumDate = Date()
        
        if let birthdayDate = DateHelper().getBirthdayDate(date) ?? DateHelper().getDefaultDate() {
            datePicker?.setDate(birthdayDate, animated: true)
        }
    }
    
    /// Triggered when the date picker has changed the date picker
    ///
    /// - Parameter sender: The object that triggers the action
    @objc public func changeDate(_ sender: AnyObject?) {
        guard let existedDatePicker = datePicker else {
            return
        }
        
        delegate?.dateWasChanged(existedDatePicker.date)
    }
}

// MARK: - MyProfileCell implementation
extension DatePickerTableViewCell: MyProfileCell {
    
    /// Sets up the UI accordingly
    ///
    /// - Parameters:
    ///   - item: The content item that populates the cell
    ///   - delegate: The delegate receiving the date picker actions
    public func updateUI(_ item: MyProfileContentItem, delegate: MyProfileCellsDelegate?) {
        setUpPicker(item.firstInputItem.value)

        self.delegate = delegate
    }
}
