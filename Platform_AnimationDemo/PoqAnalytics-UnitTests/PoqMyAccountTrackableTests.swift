//
//  PoqMyAccountTrackableTests.swift
//  PoqAnalytics-UnitTests
//
//  Created by Manuel Marcos Regalado on 23/01/2018.
//

import XCTest
import PoqPlatform
import PoqNetworking
@testable import PoqAnalytics

class PoqMyAccountTrackableTests: EventTrackingTestCase {
    
    func testSignUpMyAccountTracking() {
        PoqTrackerV2.shared.signUp(userId: "12345", marketingOptIn: true, dataOptIn: false)
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testLoginMyAccountTracking() {
        PoqTrackerV2.shared.login(userId: "12345")
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testLogoutMyAccountTracking() {
        PoqTrackerV2.shared.logout(userId: "12345")
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAddressBookMyAccountTracking() {
        PoqTrackerV2.shared.addressBook(action: "Change", userId: "3298743432")
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testEditDetailsMyAccountTracking() {
        PoqTrackerV2.shared.editDetails(userId: "238973342")
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testSwitchCountryMyAccountTracking() {
        PoqTrackerV2.shared.switchCountry(countryCode: "GB")
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    /// MARK: - Tests to confirm custom provider recieves calls from code
    
    func testEditProfileTracked() {
        let editProfileViewController = EditMyProfileViewController(nibName: "EditMyProfileViewController", bundle: nil)
        editProfileViewController.viewModel = MockEditMyProfileViewModel(viewControllerDelegate: editProfileViewController)
        editProfileViewController.saveButtonClicked()
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAddressBookTracked() {
        let myProfileAddressBook = MyProfileAddressBookViewController(nibName: "MyProfileAddressBookViewController", bundle: nil)
        myProfileAddressBook.trackAnalyticsEvent(PoqNetworkTaskType.deleteUserAddress)
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}

class MockEditMyProfileViewModel: SignUpViewModel {

    override func updateAccount() {
        viewControllerDelegate?.networkTaskDidComplete(PoqNetworkTaskType.updateAccount)
    }
}
