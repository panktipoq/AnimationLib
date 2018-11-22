//
//  WebWrapperViewConroller.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 9/28/16.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

/// Scheme which we will monitor and cancel its requests, since we need have protocol communication with page in UIWebView
private let customScheme: String = "poqwebcomponent"

// Alert query keys
private let alertTitleKey: String = "key"
private let alertMessageKey: String = "message"

enum CustomSchemeAction: String {
    case hideButton = "hidebutton"
    case showButton = "showbutton"
    case disableButton = "disablebutton"
    case popBack = "popback"
    case showAlert = "showalert"
}

/**
 This web component needed for replacement onetime usage native screens with web, which mimic native design.
 We won't here use usual for us CSS or somhow break page. Correct UI and styling is web page responsibility
 */
class WebWrapperViewConroller: PoqBaseViewController {

    @IBOutlet weak var webView: UIWebView?
    
    fileprivate let targetUrl: URL
    fileprivate let screenTitle: String?
    fileprivate let saveButtonTitle: String?
    
    // Will be execured on save action
    fileprivate let jsCode: String?
    
    fileprivate weak var loadingIndicator: PoqSpinner?

    /**
     Create WebWrapperViewConroller with target URL
     - parameter url: target URL
     - parameter title: screen title
     - saveButtonTitle: save button title, in tight top corner. If nil or empty - button will be hidden
     - jsCode: JavaScript will be executed when 'save' button pressed
     */
    init(url: URL, title: String?, saveButtonTitle: String?, jsCode: String?) {
        targetUrl = url
        screenTitle = title
        self.saveButtonTitle = saveButtonTitle
        self.jsCode = jsCode
        super.init(nibName: "WebWrapperViewConroller", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        let request = URLRequest(url: targetUrl)
        Log.verbose("Loading \(request)")
        webView?.loadRequest(request)
        if let existedScreenTitle = screenTitle {
            navigationItem.titleView = NavigationBarHelper.setupTitleView(existedScreenTitle)
        }
        createBarButtonItemIfNeeded()
        loadingIndicator = setupLoadingIndicator()
    }
    
    @objc func saveButtonAction() {
        Log.verbose("Save button pressed")
        guard let js: String = jsCode, !js.isEmpty else {
            return
        }
        // We will run 2 js: insert email and execute command
        injectUserEmailIfNeeded()
        _ = webView?.stringByEvaluatingJavaScript(from: js)
    }
}

// MARK: - UIWebViewDelegate
extension WebWrapperViewConroller: UIWebViewDelegate {

    func webViewDidStartLoad(_ webView: UIWebView) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        loadingIndicator?.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loadingIndicator?.stopAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = true
        injectUserEmailIfNeeded()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        Log.verbose("Opening url: \(String(describing: request.url?.absoluteString))")
        guard let url: URL = request.url, url.scheme == customScheme else {
            return true
        }
        guard let host = url.host, let action = CustomSchemeAction(rawValue: host) else {
            Log.error("We can't find path of URL ( \(url.absoluteString) ) or path is unknown for app")
            return false
        }
        switch action {
        case .hideButton:
            navigationItem.rightBarButtonItem = nil
        case .showButton:
            createBarButtonItemIfNeeded()
        case .disableButton:
            navigationItem.rightBarButtonItem?.isEnabled = false
        case .popBack:
            _ = navigationController?.popViewController(animated: true)
        case .showAlert:
            let title: String? = url.queryValue(forKey: alertTitleKey)
            let message: String? = url.queryValue(forKey: alertMessageKey)
            presentAlert(title, message: message)
        }
        return false
    }
}

// MARK: - Private
extension WebWrapperViewConroller {
    
    /// - Returns: ready to use loading indicator, whick already added to view
    fileprivate final func setupLoadingIndicator() -> PoqSpinner {
        // Add loading indicator
        let loadingIndicatorSize = CGFloat(AppSettings.sharedInstance.loadingIndicatorDimension)
        let spinnerView = PoqSpinner(frame: CGRect(x: 0, y: 0, width: loadingIndicatorSize, height: loadingIndicatorSize))
        view.addSubview(spinnerView)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: spinnerView.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: spinnerView.centerYAnchor).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: loadingIndicatorSize).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: loadingIndicatorSize).isActive = true
        return spinnerView
    }
    
    /// Search email text field and inser email of logged in user
    fileprivate final func injectUserEmailIfNeeded() {
        guard let email: String = LoginHelper.getEmail(), LoginHelper.isLoggedIn() else {
            return
        }
        let setEmailJS = "var hiddenInput = document.getElementById('email'); hiddenInput.value = '\(email)'"
        webView?.stringByEvaluatingJavaScript(from: setEmailJS)
    }
    
    /// Create bar button item with proper style and put it into right item slot
    /// Button won't created if title 
    fileprivate final func createBarButtonItemIfNeeded() {
        guard let buttonTitle: String = saveButtonTitle, !buttonTitle.isEmpty else {
            return
        }
        navigationItem.rightBarButtonItem = NavigationBarHelper.createButtonItem(withTitle: buttonTitle, target: self, action: #selector(WebWrapperViewConroller.saveButtonAction))
    }
    
    /// TODO: too many places where we do it, we m
    fileprivate final func presentAlert(_ title: String?, message: String?) {
        // Ask user for final confirmation
        let validAlertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okTitle: String = "OK".localizedPoqString
        validAlertController.addAction(UIAlertAction(title: okTitle, style: UIAlertActionStyle.destructive, handler: nil))
        self.present(validAlertController, animated: true, completion: nil)
    }
}
