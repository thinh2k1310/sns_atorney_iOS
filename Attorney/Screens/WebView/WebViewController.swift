//
//  WebViewController.swift
//  Attorney
//
//  Created by ThinhTCQ on 12/13/22.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var backwardButton: UIButton!
    @IBOutlet private weak var forwardButton: UIButton!
    @IBOutlet private weak var refreshButton: UIButton!
    @IBOutlet private weak var indicateView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupWebView() {
        webView.uiDelegate = self
        webView.navigationDelegate = self
        if let url = URL(string: "https://thuvienphapluat.vn/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    
    @IBAction private func didTapClose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func didTapForward(_ sender: Any) {
        webView.goForward()
    }
    
    @IBAction private func didTapBackward(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction private func didTapRefresh(_ sender: Any) {
        webView.reload()
    }
    
    private func showIndicator(isAnimating: Bool) {
        if isAnimating {
            indicateView.startAnimating()
            indicateView.isHidden = false
        } else {
            indicateView.stopAnimating()
            indicateView.isHidden = true
        }
    }
    
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        showIndicator(isAnimating: true)
        self.backwardButton.isEnabled = false
        self.forwardButton.isEnabled = false
      
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showIndicator(isAnimating: false)
        if webView.canGoBack {
            self.backwardButton.isEnabled = true
        }
        
        if webView.canGoForward {
            self.forwardButton.isEnabled = true
        }
    }
}
