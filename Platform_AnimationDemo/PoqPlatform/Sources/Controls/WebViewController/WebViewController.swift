//
//  WebViewController.swift
//  Platform
//
//  Created by GabrielMassana on 01/05/2018.
//  Copyright © 2018 Gabriel Massana. All rights reserved.
//

import Foundation
import UIKit
import PoqUtilities

open class WebViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: - Properties

    typealias Completion = (_ controller: WebViewController) -> Void

    // Loding string
    var loadingString: String = "WEBVIEW_LOADING".localizedPoqString
    
    // Public variables
    public var webView: UIWebView = {
        var webView = UIWebView(frame: CGRect.zero)
        webView.autoresizingMask = [.flexibleWidth, .flexibleWidth]
        return webView
    }()
    
    // Private properties
    fileprivate var url: URL
    fileprivate var titleView: UIView?
    fileprivate var titleLabel: UILabel?
    
    var webTitleText: String {
        get {
            return titleLabel?.text ?? ""
        } set(newValue) {
            titleLabel?.text = newValue
            titleLabel?.sizeToFit()
            adjustNavigationBar()
        }
    }
    
    // MARK: - Init
    
    public init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = self.view.bounds
        webView.delegate = self
        setup()
    }
    
    // MARK: - Setup
    
    func setup() {
        // Allows navigationbar to overlap webview
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        edgesForExtendedLayout = .top
        setupTitleView()
        setupWebView()
        
        // Navigating to URL
        navigateTo(url: url)
    }
    
    func setupTitleLabel() {
        
        titleLabel = UILabel(frame: CGRect.zero)
        titleLabel?.backgroundColor = .clear
        titleLabel?.textColor = .black
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        titleLabel?.textAlignment = .natural
        // Set text, sizeToFit() and adjustNavigationBar
        webTitleText = loadingString
    }
    
    func setupTitleView() {
        
        setupTitleLabel()
        // Add new titleview with labels
        titleView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 30.0))
        titleView?.autoresizingMask = .flexibleWidth
        if let titleLabel = titleLabel {
            titleView?.addSubview(titleLabel)
        }

        navigationItem.titleView = titleView
    }
    
    func setupWebView() {
        
        view.addSubview(webView)
    }

    func adjustNavigationBar() {
        // Width of buttons in UINavigationBar
        let buttonsWidth: CGFloat = 110.0
        guard let titleLabel = titleLabel,
            let titleView = titleView else {
            return
        }
        titleLabel.frame = CGRect(
            x: titleLabel.frame.origin.x,
            y: titleView.frame.size.height / 2.0 - titleLabel.frame.size.height / 2.0,
            width: fmin(titleLabel.frame.size.width,
                        self.view.frame.size.width - buttonsWidth),
            height: titleLabel.frame.size.height)
    }
    
    // MARK: - Show
    
    func show() {
        if let viewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            showFrom(viewController: viewController)
        } else {
            showViewController(withCompletion: nil)
        }
    }
    
    func showFrom(viewController: UIViewController) {
        showViewControllerFrom(viewController: viewController, withCompletion: nil)
    }
    
    func showViewController(withCompletion completion: Completion?) {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            showViewControllerFrom(viewController: rootViewController, withCompletion: completion)
        }
    }
    
    func showViewControllerFrom(viewController: UIViewController, withCompletion completion: Completion?) {
        // Creates navigation controller, and presents modally.
        let navigationController = UINavigationController(rootViewController: self)
        viewController.present(
            navigationController,
            animated: true,
            completion: {
                // Send completion callback
                if let completion = completion {
                    completion(self)
                }
        })
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation
    
    func navigateTo(url: URL) {
        let request = URLRequest(url: url)
        Log.verbose("Loading \(request)")
        webView.loadRequest(request)
    }
    
    func reload() {
        webView.reload()
    }
    
    func load(request: URLRequest) {
        Log.verbose("Loading \(request)")
        webView.loadRequest(request)
    }
    
    // MARK: - UIWebViewDelegate
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        if let title = webView.stringByEvaluatingJavaScript(from: "document.title") {
            webTitleText = title
        }
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if let title = webView.stringByEvaluatingJavaScript(from: "document.title") {
            webTitleText = title
        }
        Log.error("Web view failed to laod. %@", error.localizedDescription)
    }
}
