//
//  ApplyVoucherViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 24/08/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqAnalytics
import UIKit

open class ApplyVoucherViewModel: BaseViewModel {
    
    var voucherCode:String = ""
    var studentVoucherCode:String = ""
    // MARK: - Init
    // ________________________
    
    // Used for avoiding optional checks in viewController
    public override init(){
        
        super.init()
    }
    
    public override init(viewControllerDelegate:PoqBaseViewController) {
        
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    
    // MARK: - Business Logic
    // ________________________
    
    func endEditingVoucherTextFieldAndApplyCode(_ textField:UITextField, orderId:Int?, voucherType: VoucherType) {
        
        endEditingVoucherTextField(textField)
        voucherType == .default ? applyVoucherCode(textField.obligatoryText()) : applyStudentCode(textField.obligatoryText())
    }
    
    func applyVoucherCode(_ voucherCode: String) {

        let postVoucher = PoqPostVoucher()
        postVoucher.code = voucherCode
        self.voucherCode = voucherCode
        postVoucher.orderId = BagHelper().getOrderId()
        PoqNetworkService(networkTaskDelegate: self).postVoucher(postVoucher)
    }
    
    func applyStudentCode(_ studentCode: String) {
        
        let studentVoucher: PoqStudentNumber = PoqStudentNumber()
        studentVoucher.cardNumber = studentCode
        self.studentVoucherCode = studentCode
        studentVoucher.orderId = BagHelper().getOrderId()
        PoqNetworkService(networkTaskDelegate: self).postStudentVoucher(studentVoucher)
    }
    
    open func isTextFieldEmpty(_ textField:UITextField) -> Bool {
        
        return textField.obligatoryText().isEmpty
    }
    
    func startEditingVoucherTextField(_ textField: UITextField) {
        
        textField.becomeFirstResponder()
    }
    
    func endEditingVoucherTextField(_ textField: UITextField) {
        
        textField.resignFirstResponder()
    }
    
    func shakeInvalidTextField(_ invalidTextField:FloatLabelTextField){
        invalidTextField.placeholder = AppLocalization.sharedInstance.invalidVoucherCodeMessage
        InvalidTextFieldHelper.shakeInvalidTextField(invalidTextField)
    }
    
    func resetTextField(_ textField:FloatLabelTextField, voucherType: VoucherType){
        
        if !textField.obligatoryText().isEmpty {
            
            textField.placeholder = voucherType == .default ? AppLocalization.sharedInstance.voucherCodeDefaultText : AppLocalization.sharedInstance.studentDiscountDefaultText
            textField.titleActiveTextColour = AppTheme.sharedInstance.mainColor
        }
    }
    
    
    // MARK: - Network Delegates
    // ________________________
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        super.networkTaskDidComplete(networkTaskType, result: [])
        
        if let networkResult = result as? [PoqMessage], networkResult.count > 0 && (networkTaskType ==  PoqNetworkTaskType.postVoucher || networkTaskType == PoqNetworkTaskType.postStudentVoucher){
            
            if let statusCode = networkResult[0].statusCode, statusCode == HTTPResponseCode.OK {
                
                PopupMessageHelper.showMessage(AppSettings.sharedInstance.applyVoucherSuccessIconName, message: AppLocalization.sharedInstance.applyVoucherSuccessMessage)

                viewControllerDelegate?.dismiss(animated: true, completion: nil)
                
                trackVoucherCode()
               
            }
            else {
                // failed operation
                if let applyVoucherViewController = viewControllerDelegate as? ApplyVoucherViewController {
                    applyVoucherViewController.whiteBoxView.shake()
                }

            }
            
            viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
        }
    }
    
    
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        super.networkTaskWillStart(networkTaskType)
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        super.networkTaskDidFail(networkTaskType, error: error)
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
    
    func trackVoucherCode(){
        if !voucherCode.isNullOrEmpty() {
            PoqTracker.sharedInstance.logAnalyticsEvent("Voucher", action: "Applied", label:voucherCode , extraParams: nil)
            PoqTrackerV2.shared.applyVoucher(voucher: voucherCode)
        }
        
        if !studentVoucherCode.isNullOrEmpty() {
             PoqTracker.sharedInstance.logAnalyticsEvent("Student Discount", action: "Applied", label:studentVoucherCode , extraParams: nil)
            PoqTrackerV2.shared.applyStudentDiscount(voucher: studentVoucherCode)
        }

    }
}
