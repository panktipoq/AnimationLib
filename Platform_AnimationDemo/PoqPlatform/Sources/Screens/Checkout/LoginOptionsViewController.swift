//
//  LoginOptionsViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 07/09/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit

open class LoginOptionsViewController: PoqBaseViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MyProfileLoginViewCellDelegate, PoqMyProfileListPresenter {
    
    public weak var delegate: UIViewController?
    
    @IBOutlet weak var loginOptionsCollectionView: UICollectionView!
    
    @IBOutlet var closeButton: CloseButton?
    
    open lazy var service: PoqMyProfileListService = self.getService()
        
    open func getService() -> PoqMyProfileListService {
        let service = MyProfileViewModel()
        service.presenter = self
        return service
    }
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set up the only login cell in the collection view
        
        loginOptionsCollectionView.registerPoqCells(cellClasses: [MyProfilePlatformLoginViewCell.self])
    }
    
    // MARK: - PoqPresenter
    public func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
    }
    
    // MARK: - COLLECTION VIEW FOR REUSE MYPROFILE LOGIN
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: MyProfilePlatformLoginViewCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.presenter = self
        cell.updateView()
        return cell
    }
    
    // MARK: - Collectionview layout
    
    // Set cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return UIScreen.main.bounds.size
    }
    
    // MARK: - Delegation methods from login
    @IBAction func closeButtonClicked(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    public func dismissLogin() {
    }
    
    open func signUp() {
        dismiss(animated: true, completion: { () -> Void in
            NavigationHelper.sharedInstance.loadSignUp()
        })
    }
    
    open func logIn(withType type: AuthetificationType) {
        switch type {
        case .loginPassword:
            dismiss(animated: true, completion: { () -> Void in
                NavigationHelper.sharedInstance.loadLogin(isModal: true, isViewAnimated: true, isFromLoginOptions: true)
            })
        case .facebook:
            service.authenticateWithFacebook(fromViewController: self)
        }
    }
}
