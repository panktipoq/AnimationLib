//
//  CheckoutAddressViewModel.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 9/8/15.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import Contacts
import PoqNetworking
import PoqUtilities
import UIKit

open class CheckoutAddressViewModel: BaseViewModel {
    
    open var addressType = AddressType.NewAddress

    open var content = [CheckoutAddressElement]()

    var bookAddressContact: CNContact?
    open var address: PoqAddress = PoqAddress()
    public var checkoutAddressesProvider: CheckoutAddressesProvider?
    var countryValueIndex = 0
    var useSameAddress = false
    var bookContactInformation: CheckoutBookContactInformation = CheckoutBookContactInformation()
    var billingAddress: PoqAddress?
    var addressTitle: String = ""
    var postAddrressResult: String?
    
    // MARK: - Init
    // ________________________
    
    // Used for avoiding optional checks in viewController
    override public init() {
        super.init()
    }
    
    override init(viewControllerDelegate: PoqBaseViewController) {
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        super.networkTaskDidComplete(networkTaskType, result: nil)
        if networkTaskType == .updateUserAddress {
            if let networkResult = result as? [PoqDeliveryOption], networkResult.count > 0 {
                // Post Address to Order only if it's Billing or Delivery
                // which means it was created from Checkout
                if addressType == .Billing || addressType == .Delivery {
                    postAddress(networkResult[0].id)
                }
            }
        } else {
            if let networkResult = result as? [PoqDeliveryOption], networkResult.count > 0 {
                
                postAddrressResult = networkResult[0].message
            }

        }
        
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        super.networkTaskDidFail(networkTaskType, error: error)
        
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
    
    fileprivate func setAddress(_ checkoutItemAddress: PoqAddress?) {
        guard let currenntAddress = checkoutItemAddress else {
            return
        }
        self.address = currenntAddress
    }
    
    open func setUp(_ addressType: AddressType, checkoutAddressProvider: CheckoutAddressesProvider?, title: String) {
        self.checkoutAddressesProvider = checkoutAddressProvider
        self.addressType = addressType
        
        switch addressType {
        case .Billing:
            setAddress(checkoutAddressesProvider?.billingAddress)
            break
        case .Delivery:
            setAddress(checkoutAddressesProvider?.shippingAddress)
            break
        case .AddressBook:
            setAddress(checkoutAddressesProvider?.shippingAddress)
            break
        case .NewAddress:
            setAddress(PoqAddress())
            break
        }
        
        addressTitle = title
        initTableCells()
    }
    
    open func updateAddress() {
        address.save = true
        PoqNetworkService(networkTaskDelegate: self).updateUserAddress(address)
    }
    
    open func deleteAddress() {
        guard let addressID = address.id else {
            Log.warning("Trying to delete an address without address ID")
            return
        }
        PoqNetworkService(networkTaskDelegate: self).deleteUserAddress(addressID)
    }
    
    open func initInputForms() {
        var contactAddress = PoqAddress()
        contactAddress = address
        
        let noneTextFieldValue: CheckoutAddressTextField = CheckoutAddressTextField(type: .none, value: nil)
        let defaultCellHeight: CGFloat = AppSettings.sharedInstance.checkoutAddressTableViewCellHeight
        
        if addressType != AddressType.AddressBook && AppSettings.sharedInstance.isChooseFromContactsEnabled {
            // import button
            let parentContent = TableViewContent(identifier: CheckoutImportContactTableViewCell.poqReuseIdentifier, height: defaultCellHeight)
            
            let element = CheckoutAddressElement(type: .import, firstField: noneTextFieldValue, parentContent: parentContent)
            content.append(element)
        }
        
        // Name
        let nameElement: CheckoutAddressElement = elementForTwoTextFieldsCell(contactAddress.firstName, secondLabelValue: contactAddress.lastName)
        content.append(nameElement)
        
        // Phone
        let phoneElement: CheckoutAddressElement = addressElementForFullTextFieldLabel(.phone, value: contactAddress.phone)
        content.append(phoneElement)
        
        if AppSettings.sharedInstance.emailFieldEnabledForAddress {
            let emailElement = addressElementForFullTextFieldLabel(.email, value: contactAddress.email)
            content.append(emailElement)
        }
        
        if AppSettings.sharedInstance.companyFieldEnabledForAddress {
            let companyElement = addressElementForFullTextFieldLabel(.company, value: contactAddress.company)
            content.append(companyElement)
        }
        
        let address1Element = addressElementForFullTextFieldLabel(.addressLine1, value: contactAddress.address1)
        content.append(address1Element)
        
        let address2Element = addressElementForFullTextFieldLabel(.addressLine2, value: contactAddress.address2)
        content.append(address2Element)
        
        let postcodeElement = addressElementForFullTextFieldLabel(.postCode, value: contactAddress.postCode)
        content.append(postcodeElement)
        
        let cityElement = addressElementForFullTextFieldLabel(.city, value: contactAddress.city)
        content.append(cityElement)
        
        if AppSettings.sharedInstance.countyFieldEnabledForAddress {
            let countyElement = addressElementForFullTextFieldLabel(.county, value: contactAddress.county)
            content.append(countyElement)
        }
        
        let countryElement = addressElementForCountrySelection(contactAddress.countryId)
        content.append(countryElement)
        
        countryValueIndex = content.count - 1
    }
    
    /**
     If there is no content for this textFieldType, treat as valid, check for required fields in 'checkForEmptyFields'
     If there is value for this textFieldType we will try to validate.
     - returns: true is empty or valid value
     */
    open func isValueValid(forTextFieldType textFieldType: AddressTextFieldsType?) -> Bool {
        
        guard let index = indexOfItem(withTextFieldType: textFieldType) else {
            return true
        }
        
        let item = content[index]
        
        guard let textFieldType = item.firstField?.type, let value = item.firstField?.value else {
            return true
        }
        
        switch (textFieldType) {
        case .phone:
            return value.isValidPhoneNumber()
            
        case .postCode:
            if let countryIndex = indexOfItem(withTextFieldType: .country), let isoCode = content[countryIndex].firstField?.value {
                if isoCode == Countries.UnitedKingdom.isoCode {
                    return value.isValidUKPostCode()
                }
                if isoCode == Countries.UnitedStates.isoCode {
                    return value.isValidUSAZipCode()
                }
            }
            
        case .email:
            return value.isValidEmail()
        default:
            return true
        }
        
        return true
    }
    
    open func setNewValueForTextField(_ textField: UITextField?, newValue: String) {
        
        guard let index = indexOfItem(withTextFieldType: textField?.addressTextFieldsType) else {
            return
        }
        
        if textField?.addressTextFieldsType == content[index].firstField?.type {
            content[index].firstField?.value = newValue
        } else {
            content[index].secondField?.value = newValue
        }
        
    }
    
    /// return nil - if address is inalid
    open func createAddressFromContentValues() -> PoqAddress {
        
        let resAddress = PoqAddress()
        resAddress.externalAddressId = address.externalAddressId
        resAddress.id = address.id
        resAddress.isDefaultBilling = address.isDefaultBilling
        resAddress.isDefaultShipping = address.isDefaultShipping
        
        for element: CheckoutAddressElement in content {
            switch (element.type) {
                
            case .name:
                resAddress.firstName = element.firstField?.value
                resAddress.lastName = element.secondField?.value
                break
            case .phone:
                resAddress.phone = element.firstField?.value?.getNumbersOnly()
                break
            case .email:
                resAddress.email = element.firstField?.value
                break
            case .company:
                resAddress.company = element.firstField?.value
                break
            case .addressLine1:
                resAddress.address1 = element.firstField?.value
                break
            case .addressLine2:
                resAddress.address2 = element.firstField?.value
                break
            case .postCode:
                resAddress.postCode = element.firstField?.value
                break
            case .city:
                resAddress.city = element.firstField?.value
                break
            case .county:
                resAddress.county = element.firstField?.value
                break
            case .country:
                resAddress.countryId = element.firstField?.value
                if let isoCode = element.firstField?.value, let index: Int = Countries.allValues.index( where: { $0.isoCode == isoCode }) {
                    resAddress.country = Countries.allValues[index].name
                }
                break
            case .addressName:
                resAddress.addressName = element.firstField?.value
                break
            case .state:
                resAddress.state = element.firstField?.value
                break
            default:
                break
            }
            
        }
        
        return resAddress
    }
    
    /// Valid all input data for empty and valid states
    open func checkInformationFields(_ tableView: UITableView?) -> Bool {
        tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
        // email not always presented as text field, if presented makes it required
        let requiredFields: [AddressTextFieldsType] = [.fisrtName,
                                                       .lastName,
                                                       .phone,
                                                       .addressLine1,
                                                       .postCode,
                                                       .city,
                                                       .email]
        
        for textFieldType in requiredFields {
            if checkForEmptyValue(forTextField: textFieldType) && isValueValid(forTextFieldType: textFieldType) {
                // all is ok
                continue
            }
            
            let textField = findTextField(forType: textFieldType, inTableView: tableView)
            InvalidTextFieldHelper.shakeInvalidTextField(textField)
            return false
        }
        
        // Check if Country has been selected
        guard let countryIndex = indexOfItem(withTextFieldType: .country),
            let countryValue = content[countryIndex].firstField?.value, !countryValue.isEmpty else {
            let alert = UIAlertController(title: "", message: AppLocalization.sharedInstance.addressSelectCountry, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default))
            self.viewControllerDelegate?.present(alert, animated: true)
            return false
        }
        
        return true
    }
}

// MARK: - Convenience API for work with items
extension CheckoutAddressViewModel {
    
    /// Search all constent items and return idex of first, which contains textfield with this type
    @nonobjc
    public final func indexOfItem(withTextFieldType textFieldOrNil: AddressTextFieldsType?) -> Int? {
        
        guard let textField = textFieldOrNil, textField != .none else {
            return nil
        }
        
        for i in 0..<content.count {
            let item: CheckoutAddressElement = content[i]
            if item.firstField?.type == textField || item.secondField?.type == textField {
                return i
            }
        }
        
        Log.warning("Can't find cell with text field \(textField), rawValue = \(textField.rawValue)")
        return nil
    }
    
    /// Search for text field type, which should be poplated next after provided 'nextTo'. 
    /// - returns: nil, if failed to find or we are populating last one
    @nonobjc
    final func textFieldType(nextTo type: AddressTextFieldsType) -> AddressTextFieldsType? {
        guard type != .none else {
            return nil
        }
        
        for i in 0..<content.count {
            guard content[i].firstField?.type == type || content[i].secondField?.type == type else {
                continue
            }
            
            if let secondTextField = content[i].secondField, content[i].firstField?.type == type {
                return secondTextField.type 
            }
            
            // we need find next text field
            if i == (content.count - 1) {
                return nil
            }
            
            for j in i+1..<content.count {
                if let nextTextField = content[j].firstField {
                    return nextTextField.type
                }
            }
            
            return nil
        }
        
        return nil
    }
    
    /// Search for text field, which has specific type 
    /// - returns: nil, if failed to find. UITextField otherwise
    @nonobjc
    final public func findTextField(forType type: AddressTextFieldsType, inTableView tableView: UITableView?) -> FloatLabelTextField? {
        guard type != .none else {
            return nil
        }
        
        for i in 0..<content.count {
            
            if content[i].firstField?.type == type {
                let cell = tableView?.cellForRow(at: IndexPath(row: i, section: 0))
                if let twoTextFieldsCell = cell as? TwoTextfieldsTableViewCell {
                    return twoTextFieldsCell.firstNameTextField
                }
                return (cell as? FullwidthTextFieldCellTableViewCell)?.inputTextField
            }

            if content[i].secondField?.type == type {
                let cell = tableView?.cellForRow(at: IndexPath(row: i, section: 0))
                return (cell as? TwoTextfieldsTableViewCell)?.lastNameTextField
            }
        }
        
        return nil
    }
    
}

// MARK: - TableView Operations
// ____________________________

extension CheckoutAddressViewModel: PoqTitleBlock {
    
    func getCellHeight(_ indexPath: IndexPath) -> CGFloat {
        return content[indexPath.row].parentContent.height
    }
    
    func getNumberOfRowsForTableView(_ section: Int) -> Int {
        return content.count
    }

    func getCellForImportButton(_ tableView: UITableView, indexPath: IndexPath, importConactsDelegate: ImportButtonDelegate) -> UITableViewCell {
        let cell: CheckoutImportContactTableViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        cell.importButtonView.configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.importButtonStyle)
        cell.importButtonView.setTitle(AppLocalization.sharedInstance.importButtonText, for: .normal)
        cell.importButtonView.delegate = importConactsDelegate
        return cell
    }
    
    func getCellForPickExistInformation(_ tableView: UITableView, indexPath: IndexPath, changeAddressTypeDelegate: ChooseSameAddressDelegate) -> UITableViewCell {
        let cell: CheckoutSameAddressTableViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)

        var sameAs = AddressSameAs.billing
        if content[indexPath.row].type == CheckoutAddressElementType.primaryBilling {
            cell.setUpSwitch(address.isDefaultBilling)
            sameAs = AddressSameAs.billing
        }

        if content[indexPath.row].type == CheckoutAddressElementType.primaryShipping {
            cell.setUpSwitch(address.isDefaultShipping)
            sameAs = AddressSameAs.shipping
        }

        cell.setUp(sameAs, sameAddressdelegate: changeAddressTypeDelegate, titleText: content[indexPath.row].firstField?.value)
        
        return cell
    }
    
    func getCellForBlackButton(_ tableView: UITableView, indexPath: IndexPath, delegate: BlackButtonDelegate) -> UITableViewCell {
        let cell: BlackButtonTableViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        cell.blackButton?.addTarget(delegate, action:#selector(delegate.blackButtonClicked(_:)), for: .touchUpInside)
        cell.blackButton?.setTitle(AppLocalization.sharedInstance.checkoutAddressDeleteButtonText, for: .normal)
        return cell
    }   
    
    @nonobjc
    public final func addressElementForFullTextFieldLabel(_ itemType: CheckoutAddressElementType, value: String?) -> CheckoutAddressElement {
        
        var textFieldValue: CheckoutAddressTextField = CheckoutAddressTextField(type: itemType.textFieldType, value: value)
        textFieldValue.wrongValueMessage =  itemType.textFieldType.wrongValueText(forAddressType: addressType)
        let parentContent = TableViewContent(identifier: FullwidthTextFieldCellTableViewCell.poqReuseIdentifier, height: AppSettings.sharedInstance.checkoutAddressTableViewCellHeight)
        
        let element = CheckoutAddressElement(type: itemType,
                                             firstField: textFieldValue,
                                             parentContent: parentContent)
        return element
    }
    
    @nonobjc
    public final func addressElementForCountrySelection( _ value: String?) -> CheckoutAddressElement {
        
        let textFieldValue: CheckoutAddressTextField = CheckoutAddressTextField(type: .country, value: value)
        let parentContent = TableViewContent(identifier: CheckoutAddressCountrySelectionCell.poqReuseIdentifier, height: AppSettings.sharedInstance.checkoutAddressTableViewCellHeight)
        
        let element = CheckoutAddressElement(type: .country,
                                             firstField: textFieldValue,
                                             parentContent: parentContent)
        return element
    }
    
    @nonobjc
    fileprivate final func emptyCellElement(_ itemType: CheckoutAddressElementType, 
                                  textFieldType: AddressTextFieldsType,
                                  cellIdentifier: String,
                                  value: String = AppLocalization.sharedInstance.sameAsBillingAddressText,
                                  height: CGFloat = AppSettings.sharedInstance.checkoutAddressTableViewCellHeight) -> CheckoutAddressElement {
        
        let textFieldValue: CheckoutAddressTextField = CheckoutAddressTextField(type: textFieldType, value: value)
        let parentContent = TableViewContent(identifier: cellIdentifier, height: height)
        
        let element = CheckoutAddressElement(type: itemType, firstField: textFieldValue, parentContent: parentContent)
        return  element
    }

    @nonobjc
    public final func elementForTwoTextFieldsCell(_ labelValue: String?, secondLabelValue: String?, wrongValue: String? = "") -> CheckoutAddressElement {

        let parentContent = TableViewContent(identifier: TwoTextfieldsTableViewCell.poqReuseIdentifier, height: AppSettings.sharedInstance.checkoutAddressTableViewCellHeight)
        
        var firstNameTexxFieldValue: CheckoutAddressTextField = CheckoutAddressTextField(type: .fisrtName, value: labelValue)
        firstNameTexxFieldValue.wrongValueMessage = String(format: AppLocalization.sharedInstance.enterValidFirstName, arguments: [addressType.rawValue])
        
        var lastNameTexxFieldValue: CheckoutAddressTextField = CheckoutAddressTextField(type: .lastName, value: secondLabelValue)
        lastNameTexxFieldValue.wrongValueMessage = String(format: AppLocalization.sharedInstance.enterValidLastName, arguments: [addressType.rawValue])
        
        let elemet = CheckoutAddressElement(type: .name, firstField: firstNameTexxFieldValue, secondField: lastNameTexxFieldValue, parentContent: parentContent) 
        
        return elemet
    }
    
    @nonobjc
    fileprivate final func initTableCells() {
        content = []
        
        let noneTextFieldValue: CheckoutAddressTextField = CheckoutAddressTextField(type: .none, value: nil)
        let defaultCellHeight: CGFloat = AppSettings.sharedInstance.checkoutAddressTableViewCellHeight
        
        if AppSettings.sharedInstance.addressTypeTitleEnabled {
            
            let parentContent = TableViewContent(identifier: MyProfileAddressBookTitleTableViewCell.poqReuseIdentifier, height: AppSettings.sharedInstance.checkoutAddressTableViewPoqTitleBlockHeight)
            
            let element = CheckoutAddressElement(type: .title, firstField: noneTextFieldValue, parentContent: parentContent)
            content.append(element)
        }
        
        if addressType == AddressType.AddressBook {
            // Add toggle cells for "Set as primary Billing/Shipping"
            let parentContent = TableViewContent(identifier: CheckoutSameAddressTableViewCell.poqReuseIdentifier, height: defaultCellHeight)
            
            if AppSettings.sharedInstance.setAsPrimaryBillingAddressFieldEnabled {
                let billingFieldValue: CheckoutAddressTextField = CheckoutAddressTextField(type: .none, value: AppLocalization.sharedInstance.setAsPrimaryBillingAddressText)
                
                let billingElement = CheckoutAddressElement(type: .primaryBilling, firstField: billingFieldValue, parentContent: parentContent)
                content.append(billingElement)
            }
            
            if AppSettings.sharedInstance.setAsPrimaryShippingAddressFieldEnabled {
                let shippingFieldValue: CheckoutAddressTextField = CheckoutAddressTextField(type: .none, value: AppLocalization.sharedInstance.setAsPrimaryShippingAddressText)
                
                let shippingElement = CheckoutAddressElement(type: .primaryShipping, firstField: shippingFieldValue, parentContent: parentContent)
                content.append(shippingElement)
            }
        }
        
        initInputForms()
        
        if addressType == AddressType.AddressBook {
            
            let parentContent = TableViewContent(identifier: BlackButtonTableViewCell.poqReuseIdentifier, height: BlackButtonTableViewCell.RowHeight)
            
            let element = CheckoutAddressElement(type: .deleteButton, firstField: noneTextFieldValue, parentContent: parentContent)
            content.append(element)
        }
    }
}
// MARK: - TableViewCell textField validation
// __________________________________________

extension CheckoutAddressViewModel {

    /**
     We will check populated texts in 'content'
     If this type of text field not listed in content, assume it is valid 
     - paramter tableView: will be use for text field search and shake it
     */
    public func checkForEmptyValue(forTextField textFieldType: AddressTextFieldsType) -> Bool {

        guard let index = indexOfItem(withTextFieldType: textFieldType) else {
            return true
        }
        
        if  content[index].firstField?.type == textFieldType, CheckoutAddressViewModel.isNilOrEmpty(string: content[index].firstField?.value) {
            
            return false
        }
        
        if let secondField = content[index].secondField, secondField.type == textFieldType, CheckoutAddressViewModel.isNilOrEmpty(string: secondField.value) {

            return false
        }
        
        return true
    }
    
    fileprivate func shakeIfFieldEmpty(_ textField: FloatLabelTextField?, tableView: UITableView) -> Bool {
        if isTextFieldEmpty(textField) || !isValueValid(forTextFieldType: textField?.addressTextFieldsType) {
            InvalidTextFieldHelper.shakeInvalidTextField(textField)
            checkLabelValue(textField, tableView: tableView)
            return true
        }
        return false
    }
    
    // TODO: we need just create smth like requiredTextFields: [.AddressLine1, .Company] 
    func isFieldRequered(_ textField: FullwidthTextFieldCellTableViewCell) -> Bool {
        return textField.inputTextField?.addressTextFieldsType != .addressLine2 && textField.inputTextField?.addressTextFieldsType != .company
    }
    
    func isTextFieldEmpty(_ textField: UITextField?) -> Bool {
        return textField?.text?.isEmpty == true
    }

    public func textFieldChanged(_ textField: UITextField?, tableView: UITableView?, newValue: String) {
        if (newValue == "") {
            textField?.text = ""
        }
        if 1 != content.count {
            setNewValueForTextField(textField, newValue: newValue)
            makeValueUpperCase(textField)
            checkLabelValue(textField, tableView: tableView)
        }
    }
    
    func makeValueUpperCase(_ textField: UITextField?) {
        guard let index = indexOfItem(withTextFieldType: textField?.addressTextFieldsType), textField?.addressTextFieldsType == .postCode else {
            return
        }
        
        let uppercaseValue: String? = textField?.text?.uppercased()
        
        textField?.text = uppercaseValue
        content[index].firstField?.value = uppercaseValue 
        
    }
    
    func checkLabelValue(_ textField: UITextField?, tableView: UITableView?) {
        guard let addressTextFieldsType = textField?.addressTextFieldsType else {
            return
        }
        switch addressTextFieldsType {
        case .fisrtName, 
             .lastName:
            if let floatLabelTextField: FloatLabelTextField = textField as? FloatLabelTextField {
                floatLabelTextField.titleActiveTextColour = isValueValid(forTextFieldType: floatLabelTextField.addressTextFieldsType) ? AppTheme.sharedInstance.mainColor : UIColor.red
            }
        default:
            
            // assume here that the rest is FullwidthTextFieldCellTableViewCell
            if let floatLabelTextField: FloatLabelTextFieldWithState = textField as? FloatLabelTextFieldWithState {
                floatLabelTextField.isValid = isValueValid(forTextFieldType: floatLabelTextField.addressTextFieldsType)
            }
        }
    }

}

// MARK: - Toggle switch button for is delivery the same as billing address
// __________________________________________
extension CheckoutAddressViewModel {
    func isSameAddressChangeValue(_ sameAs: AddressSameAs, isSame: Bool, tableView: UITableView) {
        
        switch sameAs {
        case .billing:
            address.isDefaultBilling = isSame
            break
        case .shipping:
            address.isDefaultShipping = isSame
            break
        }

    }
    
    func getIndexesArray(_ tableContent: [CheckoutAddressElement], tableView: UITableView) -> [IndexPath] {
        var indexArray: [IndexPath] = []
        let range = 1 ..< tableContent.count
        for i in range {
            let indexPath = IndexPath(row: i, section: tableView.numberOfSections - 1)
            indexArray.append(indexPath)
        }
        return indexArray
    }
}

// MARK: - Save information
// __________________________________________

extension CheckoutAddressViewModel {
    
    /// Save in for to API
    func saveInformation() {
        
        if !useSameAddress {
            address = createAddressFromContentValues()
        } else {
            
            // Due to some API inconsistence
            if let elementIndex: Int = indexOfItem(withTextFieldType: .country) {
                let element: CheckoutAddressElement = content[elementIndex]
                address.countryId = element.firstField?.value
                if let isoCode = element.firstField?.value, let index: Int = Countries.allValues.index( where: { $0.isoCode == isoCode }) {
                    address.country = Countries.allValues[index].name
                }
            }
        }
        
        updateAddress()
        
    }
    
    func postAddress(_ id: Int?) {
        let poqPostAddress = PoqPostAddress()
        address.id = id
        if addressType == AddressType.Billing {
            poqPostAddress.billingAddress = address

        }
        
        if addressType == AddressType.Delivery {
            poqPostAddress.shippingAddress = address
        }
        
        poqPostAddress.useBillingAsShipping = useSameAddress
        
        if let orderId = BagHelper().getOrderId() {
            
            PoqNetworkService(networkTaskDelegate: self).saveAddressToOrder(String(orderId), postAddress: poqPostAddress)

        }
    }
}

// MARK: - Save information from contact list
// __________________________________________

extension CheckoutAddressViewModel {
    
    func numberOfAddresses(for contact: CNContact) -> Int {
        guard contact.isKeyAvailable(CNContactPostalAddressesKey) else {
            Log.warning("PostalAddressesKey not available for contact")
            return 0
        }
        
        return numbersOfElements(contact.postalAddresses, popUpEnable: &bookContactInformation.chooseAddressPopUpEnable)
    }
    
    func numberOfPhones(for contact: CNContact) -> Int {
        guard contact.isKeyAvailable(CNContactPhoneNumbersKey) else {
            Log.warning("PhoneNumbersKey not available for contact")
            return 0
        }
        
        return numbersOfElements(contact.phoneNumbers, popUpEnable: &bookContactInformation.choosePhonePopUpEnable)
    }
    
    func numberOfEmails(for contact: CNContact) -> Int {
        guard contact.isKeyAvailable(CNContactEmailAddressesKey) else {
            Log.warning("EmailAddressesKey not available for contact")
            return 0
        }
        
        return numbersOfElements(contact.emailAddresses, popUpEnable: &bookContactInformation.chooseEmailPopUpEnable)
    }
    
    private func numbersOfElements(_ elements: [Any]?, popUpEnable: inout Bool) -> Int {
        guard let elements = elements, popUpEnable else {
            return 0
        }
        
        popUpEnable = elements.count > 1
        
        return elements.count
    }
    
    func fillInformation(using contact: CNContact?) {
        guard let contact = contact else {
            return
        }
        
        address = PoqAddress(contact: contact,
                             phoneNumberIndex: bookContactInformation.choosenPhoneIndex,
                             emailAddressIndex: bookContactInformation.choosenEmailIndex,
                             postalAddressIndex: bookContactInformation.choosenAddressIndex)
        
        if let countryCode = address.countryId {
            address.countryId = CountriesHelper.countryByIsoCode(countryCode)?.isoCode
            address.country = CountriesHelper.convertCountrytoLongName(countryCode)
        }
        
        structureDefaultValues()
        initTableCells()
    }
    
    fileprivate func structureDefaultValues() {
        bookContactInformation = CheckoutBookContactInformation()
    }
    
    func addIndexForBookContactMultipleValues(_ index: Int) {
        if bookContactInformation.choosePhonePopUpEnable {
            bookContactInformation.choosenPhoneIndex = index
            bookContactInformation.choosePhonePopUpEnable = false
            return
        }

        if bookContactInformation.chooseEmailPopUpEnable {
            bookContactInformation.choosenEmailIndex = index
            bookContactInformation.chooseEmailPopUpEnable = false
            return
        }
        
        if bookContactInformation.chooseAddressPopUpEnable {
            bookContactInformation.choosenAddressIndex = index
            bookContactInformation.chooseAddressPopUpEnable = false
            return
        }
    }
    
    fileprivate static func isNilOrEmpty(string: String?) -> Bool {
        guard let existedString = string else {
            return true
        }
        
        return existedString.isNullOrEmpty()
    }
}

struct CheckoutBookContactInformation {
    var chooseEmailPopUpEnable = AppSettings.sharedInstance.emailFieldEnabledForAddress
    var choosePhonePopUpEnable = true
    var chooseAddressPopUpEnable = true
    var choosenEmailIndex = 0
    var choosenPhoneIndex = 0
    var choosenAddressIndex = 0
}
