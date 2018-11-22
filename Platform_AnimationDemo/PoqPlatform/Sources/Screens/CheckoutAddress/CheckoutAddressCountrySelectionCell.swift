//
//  CheckoutAddressCountrySelectionCell.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 9/11/15.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import UIKit

public protocol CountrySelectionDelegate: AnyObject {
    
    func countrySelectiodDidChangeCountry(_ country: Country?)
}

class CheckoutAddressCountrySelectionCell: UITableViewCell {
    
    @IBOutlet fileprivate  weak var inputTextField: UITextField? 
    
    @IBOutlet weak var underline: HorizontalLine?
    @IBOutlet weak var solidLine: SolidLine?
    
    fileprivate var pickerView: UIPickerView = UIPickerView()
    
    fileprivate weak var delegate: CountrySelectionDelegate?
    
    fileprivate var isoCode: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        inputTextField?.inputView = pickerView
        inputTextField?.delegate = self

        inputTextField?.font = AppTheme.sharedInstance.signUpTextFieldFont
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }

}

// MARK: - CheckoutAddressCell

extension CheckoutAddressCountrySelectionCell: CheckoutAddressCell {

    func updateUI(_ item: CheckoutAddressElement, delegate: CheckoutAddressCell.CheckoutAddressCellDelegate) {
        
        self.delegate = delegate
        
        isoCode = item.firstField?.value ?? ""
        
        pickerView.selectRow(selectedCountryIndex(), inComponent: 0, animated: true)
        
        updateTextFIeldText()
    }
    
    func makeTextFieldFirstResponder(_ textFieldType: AddressTextFieldsType) {
        inputTextField?.becomeFirstResponder()
    }
    
    func resignTextFieldsFirstResponder() {
        inputTextField?.resignFirstResponder()
    }
}

// MARK: - UIPickerViewDataSource

extension CheckoutAddressCountrySelectionCell: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Countries.allValues.count
    }
}

// MARK: - UIPickerViewDelegate

extension CheckoutAddressCountrySelectionCell: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Countries.allValues[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let country: Country?
        if row == 0 {
            country = nil
        } else {
            country = Countries.allValues[row]
        }
        
        isoCode = country?.isoCode ?? ""
        updateTextFIeldText()
        delegate?.countrySelectiodDidChangeCountry(country)
    }
}

// MARK: - UITextFieldDelegate

extension CheckoutAddressCountrySelectionCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        updateTextFIeldText()
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

// MARK: - Private
extension CheckoutAddressCountrySelectionCell {

    /// Return index of element in Countries.allValues. If index 0 - mean no selected country
    @nonobjc
    fileprivate func selectedCountryIndex() -> Int {
        let countryIndex: Int? = Countries.allValues.index { return $0.isoCode == isoCode }
        return countryIndex ?? 0
    }
    
    /// Update UITextField according to selectedCountryIndex( value)
    @nonobjc
    fileprivate func updateTextFIeldText() {
        
        let selectedIndex = selectedCountryIndex()
        let country = Countries.allValues[selectedIndex]
        inputTextField?.text = country.name
    }
}

class TextFieldWithoutCursor: UITextField {
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
}
