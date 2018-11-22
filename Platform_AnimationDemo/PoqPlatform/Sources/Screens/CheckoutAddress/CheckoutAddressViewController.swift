//
//  CheckoutAddressViewController.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 9/8/15.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import ContactsUI
import DBPrivacyHelper
import PoqNetworking
import UIKit
import PoqAnalytics

public protocol CheckoutAddressCell: PoqReusableView {

    typealias CheckoutAddressCellDelegate = CountrySelectionDelegate & UITextFieldDelegate

    /**
     Update UI with provided item. May need use external data validators
     - parameter item: mdoel element, which provide while needed information
     - parameter delegate: delegate for all possible user events.
     */
    func updateUI(_ item: CheckoutAddressElement, delegate: CheckoutAddressCellDelegate)

    /// While we switching between cells we need be able to make next one first responder
    func makeTextFieldFirstResponder(_ textFieldType: AddressTextFieldsType)

    /// Good chance to hide keyboard
    func resignTextFieldsFirstResponder()
}

open class CheckoutAddressViewController: PoqBaseViewController {

    override open var screenName: String {
        switch addressType {
        case .Billing:
            return "Checkout - New Billing Address Screen"

        case .Delivery:
            return "Checkout - New Delivery Address Screen"

        case .NewAddress:
            return "Edit My Profile - Add New Address Screen"

        default:
            return "Edit My Profile - Edit Existing Address Screen"
        }
    }

    lazy open var viewModel: CheckoutAddressViewModel = {
        return type(of: self).createCheckoutAddressViewModel()
    }()

    open var addressType = AddressType.NewAddress
    var modalAnimator: ModalTransitionAnimator?

    /// Checkout item, if provided
    open var checkoutAddressProvider: CheckoutAddressesProvider?

    open var addressTitle: String = ""

    @IBOutlet public var checkoutAddressTable: UITableView!

    open class func createCheckoutAddressViewModel() -> CheckoutAddressViewModel {
        return CheckoutAddressViewModel()
    }

    deinit {
        KeyboardHelper.removeKeyboardNotification(self)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Configure table view
        checkoutAddressTable?.registerPoqCells(cellClasses: [TwoTextfieldsTableViewCell.self, FullwidthTextFieldCellTableViewCell.self,
                                                             CheckoutAddressCountrySelectionCell.self, CheckoutSameAddressTableViewCell.self,
                                                             CheckoutImportContactTableViewCell.self, MyProfileAddressBookTitleTableViewCell.self,
                                                             BlackButtonTableViewCell.self])

        checkoutAddressTable?.tableFooterView = UIView(frame: CGRect.zero)

        viewModel.viewControllerDelegate = self
        if addressTitle == "" {
            addressTitle = AddressHelper.getTitle(addressType)
        }
        setupNavigationBar()
        viewModel.setUp(addressType, checkoutAddressProvider: checkoutAddressProvider, title: addressTitle)

        checkoutAddressTable?.reloadData()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KeyboardHelper.addKeyboardNotification(self)
        checkoutAddressTable?.reloadData()
    }
    @objc func saveAddress() {

        for cell in checkoutAddressTable.visibleCells {
            if let checkoutAddressCell: CheckoutAddressCell = cell as? CheckoutAddressCell {
               checkoutAddressCell.resignTextFieldsFirstResponder()
            }
        }

        if viewModel.checkInformationFields(checkoutAddressTable) {
            viewModel.saveInformation()
        }
    }

    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {

        super.networkTaskDidComplete(networkTaskType)
        // Track analytics
        trackAnalyticsEvent(networkTaskType)
        if (addressType != AddressType.AddressBook && networkTaskType == .updateUserAddress) || addressType == AddressType.AddressBook {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    private func trackAnalyticsEvent(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        var action: String?
        if networkTaskType == .updateUserAddress {
            if addressType == AddressType.AddressBook {
                // Track updating address
                action = AddressBookAction.change.rawValue
            } else if addressType == AddressType.NewAddress {
                // Track new address
                action = AddressBookAction.add.rawValue
            }
        } else if networkTaskType == .deleteUserAddress && addressType == AddressType.AddressBook {
            // Track remove address
            action = AddressBookAction.remove.rawValue
        }
        if let actionUnwrapped = action {
            PoqTrackerV2.shared.addressBook(action: actionUnwrapped, userId: User.getUserId())
        }
    }
}

// MARK: - Set up
// __________________________
extension CheckoutAddressViewController: NavigationBarTitle {
    
    fileprivate func setupNavigationBar() {

        let rightBarButtonItem = NavigationBarHelper.createButtonItem(withTitle: AppLocalization.sharedInstance.checkoutAddressSaveButtonTitle,
                                                                              target: self,
                                                                              action: #selector(CheckoutAddressViewController.saveAddress))
        setUpNavigationBar(addressTitle, leftBarButtonItem: NavigationBarHelper.setupBackButton(self), rightBarButtonItem: rightBarButtonItem)
    }
}

// MARK: - UITableViewDelegate Implementation
// __________________________

extension CheckoutAddressViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let element = viewModel.content[indexPath.row]
        return element.parentContent.height
    }
}

// MARK: - UITableViewDataSource Implementation
// __________________________

extension CheckoutAddressViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.content.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let element = viewModel.content[indexPath.row]

        // TODO: As you can see here we have 2 approach: one is create cell in ViewModel, which is not sounds good
        // Second: use universale approach with protocol. Goal is move all these cells to secons approach and reduce number of casses here to 0

        switch element.parentContent.identifier {

        case CheckoutImportContactTableViewCell.poqReuseIdentifier:

            return viewModel.getCellForImportButton(tableView, indexPath: indexPath, importConactsDelegate: self)

        case CheckoutSameAddressTableViewCell.poqReuseIdentifier:

            return viewModel.getCellForPickExistInformation(tableView, indexPath: indexPath, changeAddressTypeDelegate: self)

        case MyProfileAddressBookTitleTableViewCell.poqReuseIdentifier:

            return viewModel.getPoqTitleBlock(tableView, indexPath: indexPath, title: addressTitle)

        case BlackButtonTableViewCell.poqReuseIdentifier:

            return viewModel.getCellForBlackButton(tableView, indexPath: indexPath, delegate: self)

        default:

            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: element.parentContent.identifier, for: indexPath)
            if let checkoutAddressCell = cell as? CheckoutAddressCell {
                checkoutAddressCell.updateUI(element, delegate: self)

                if element.type == CheckoutAddressElementType.phone {
                    let textField = (cell as? FullwidthTextFieldCellTableViewCell)?.inputTextField

                    textField?.text = textField?.text?.phoneNumberFormat()
                }
            }

            if let fullWidthCell = cell as? FullwidthTextFieldCellTableViewCell {
                fullWidthCell.inputTextField?.config =  FloatLabelTextFieldConfig(placeholder: element.firstField?.type.placehoderText, editingMessage: nil,
                                                                                  errorMessage: element.firstField?.type.wrongValueText(forAddressType: addressType))
                fullWidthCell.inputTextField?.styling = FloatLabelTextFieldStyling.createDefaultMyProfileStyling()
            } else if let twoFieldsCell = cell as? TwoTextfieldsTableViewCell {
                twoFieldsCell.firstNameTextField?.config =  FloatLabelTextFieldConfig(placeholder: element.firstField?.type.placehoderText, editingMessage: nil,
                                                                                      errorMessage: element.firstField?.type.wrongValueText(forAddressType: addressType))
                twoFieldsCell.firstNameTextField?.styling = FloatLabelTextFieldStyling.createDefaultMyProfileStyling()

                twoFieldsCell.lastNameTextField?.config =  FloatLabelTextFieldConfig(placeholder: element.secondField?.type.placehoderText, editingMessage: nil,
                                                                                     errorMessage: element.secondField?.type.wrongValueText(forAddressType: addressType))
                twoFieldsCell.lastNameTextField?.styling = FloatLabelTextFieldStyling.createDefaultMyProfileStyling()
            }

            return cell
        }
    }
}

// MARK: - UITextFieldDelegate Implementation
// __________________________
extension CheckoutAddressViewController: UITextFieldDelegate {

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let floatLabelTextField = textField as? FloatLabelTextField, !floatLabelTextField.allowsPaste {
            return false
        }

        let currentText = (textField.obligatoryText() as NSString).replacingCharacters(in: range, with: string)
        viewModel.textFieldChanged(textField, tableView: checkoutAddressTable, newValue: currentText)

        return true
    }

    open func textFieldDidBeginEditing(_ textField: UITextField) {
        let indexPath = tableView?.indexPathForRow(at: textField.convert(textField.frame, to: tableView).origin)

        guard let unwrappedIndexPath = indexPath else {
            return
        }

        let element: CheckoutAddressElement = viewModel.content[unwrappedIndexPath.row]

        if element.type == CheckoutAddressElementType.phone {
            textField.text = textField.text?.getNumbersOnly()
        }
    }

    open func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.textFieldChanged(textField, tableView: checkoutAddressTable, newValue: textField.obligatoryText())

        let indexPath = tableView?.indexPathForRow(at: textField.convert(textField.frame, to: tableView).origin)

        guard let unwrappedIndexPath = indexPath else {
            return
        }

        let element: CheckoutAddressElement = viewModel.content[unwrappedIndexPath.row]

        if element.type == CheckoutAddressElementType.phone {
            textField.text = textField.text?.phoneNumberFormat()
        }
    }

    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.textFieldChanged(textField, tableView: checkoutAddressTable, newValue: textField.obligatoryText())

        if let floatLabelTextField: FloatLabelTextField = textField as? FloatLabelTextField,
            !viewModel.isValueValid(forTextFieldType: floatLabelTextField.addressTextFieldsType) {
            InvalidTextFieldHelper.shakeInvalidTextField(floatLabelTextField)
        }

        if let nextTextFieldType = viewModel.textFieldType(nextTo: textField.addressTextFieldsType), let cellIndex: Int = viewModel.indexOfItem(withTextFieldType: nextTextFieldType) {
            let indexPath = IndexPath(row: cellIndex, section: 0)
            if let cell = checkoutAddressTable.cellForRow(at: indexPath), let checkoutAddressCell: CheckoutAddressCell = cell as? CheckoutAddressCell {
                checkoutAddressCell.makeTextFieldFirstResponder(nextTextFieldType)
            }
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
}

// MARK: - Keyboard event notification
// __________________________

extension CheckoutAddressViewController: KeyboardEventsListener {

    // MARK: - Keyboard will show/hide
    public func keyboardWillShow(_ notification: Notification) {

        resizeTableViewForKeyboardWillShow(notification)
    }

    public func keyboardWillHide(_ notification: Notification) {
        resizeTableViewForKeyboardWillHide(notification)
    }
}

extension CheckoutAddressViewController: TableViewControllerWithTextFields {

    public var tableView: UITableView? {
        return checkoutAddressTable
    }
}

// MARK: - ChooseSameAddressDelegate
// __________________________

extension CheckoutAddressViewController: ChooseSameAddressDelegate {

    public func isSameAddressChangeValue(_ sameAs: AddressSameAs, isSame: Bool) {
        if addressType != .AddressBook, let address = (isSame ? checkoutAddressProvider?.billingAddress : checkoutAddressProvider?.shippingAddress) {
            viewModel.address = address
        }
        viewModel.isSameAddressChangeValue(sameAs, isSame: isSame, tableView: checkoutAddressTable)
    }
}

// MARK: - CheckoutImportContactsDelegate
// __________________________

extension CheckoutAddressViewController: ImportButtonDelegate {

    public func importButtonClicked(_ sender: ImportButton!) {
        PermissionHelper.checkBookContactAccess { (success: Bool) in

            if success {
                let picker = CNContactPickerViewController()
                picker.delegate = self

                self.navigationController?.present(picker, animated: true, completion: nil)
            } else {
                self.showPrivacyHelper(for: .contacts, controller: { _ in
                }, didPresent: {
                }, didDismiss: {
                }, useDefaultSettingPane: true)
            }
        }
    }
}

extension CheckoutAddressViewController: CNContactPickerDelegate {

    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        viewModel.bookAddressContact = contact

        if !handleContactDuplicateDetails() {
            viewModel.fillInformation(using: contact)
            checkoutAddressTable.reloadData()
        }
    }

    fileprivate func handleContactDuplicateDetails() -> Bool {
        guard let contact = viewModel.bookAddressContact else {
            return false
        }

        if viewModel.numberOfPhones(for: contact) > 1 {
            let contactPhones = contact.phoneNumbers.map({ $0.value.stringValue })
            showContactImportDetailSelection("Choose phone", information: contactPhones)
            return true
        }

        if viewModel.numberOfEmails(for: contact) > 1 {
            let contactEmails = contact.emailAddresses.map({ $0.value as String })
            showContactImportDetailSelection("Choose email", information: contactEmails)
            return true
        }

        if viewModel.numberOfAddresses(for: contact) > 1 {
            let contactAddresses = contact.postalAddresses.map({ $0.value.street })
            showContactImportDetailSelection("Choose address", information: contactAddresses)
            return true
        }

        return false
    }

    private func showContactImportDetailSelection(_ message: String, information: [String?]?) {
        let addressSelectionViewController = CheckoutAddressImportSelectionViewController(nibName: CheckoutAddressImportSelectionViewController.XibName, bundle: nil)
        addressSelectionViewController.showDeliveryModelWithContact(message, information: information)
        addressSelectionViewController.delegate = self
        addressSelectionViewController.modalPresentationStyle = .custom

        modalAnimator = ModalTransitionAnimator(withModalViewController: addressSelectionViewController)
        modalAnimator?.isDragable = true
        modalAnimator?.behindViewAlpha = 0.5
        modalAnimator?.behindViewScale = 0.9
        modalAnimator?.transitionDuration = 0.3
        modalAnimator?.direction = .bottom
        modalAnimator?.setContentScrollView(addressSelectionViewController.deliveryTypeTableView)

        addressSelectionViewController.transitioningDelegate = modalAnimator

        OperationQueue.main.addOperation {
            self.present(addressSelectionViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - Selected address from import contact delegate
// _____________________________________________________
extension CheckoutAddressViewController: SelectedAddress {

    public func selectedValue(_ index: Int) {

        viewModel.addIndexForBookContactMultipleValues(index)

        if !handleContactDuplicateDetails() {
            viewModel.fillInformation(using: viewModel.bookAddressContact)
            checkoutAddressTable.reloadData()
        }
    }
}

// MARK: - Black button delegate
// _____________________________
extension CheckoutAddressViewController: BlackButtonDelegate {

    public func blackButtonClicked(_ sender: Any?) {
        let alert = UIAlertController(title: "DELETE_ADDRESS_MESSAGE".localizedPoqString, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "No", style: .default) { (_: UIAlertAction) -> Void in
            }
        )

        alert.addAction(UIAlertAction(title: "Yes", style: .default) { (_ UIAlertAction) -> Void in
            self.viewModel.deleteAddress()
            }
        )
        present(alert, animated: true, completion: nil)
    }
}

extension CheckoutAddressViewController: CountrySelectionDelegate {

    func countrySelectiodDidStart() {
    }

    public func countrySelectiodDidChangeCountry(_ country: Country?) {
        guard let countryElementIndex: Int = viewModel.indexOfItem(withTextFieldType: .country) else {
            return
        }

        viewModel.content[countryElementIndex].firstField?.value = country?.isoCode
    }

    func countrySelectiodDidEnd() {
    }
}
