//
//  STDocumentViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 14/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import WebKit

class STDocumentViewController: UIViewController, WKNavigationDelegate {

    fileprivate var webView = WKWebView()
    
    fileprivate var url: URL?
    
    fileprivate var fileName: String?
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    init(url: URL, title: String) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.url = url
        self.fileName = title
    }
    
    override func loadView() {
        
        super.loadView()
        
        self.webView.navigationDelegate = self
        self.view = self.webView
        self.title = self.fileName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = self.url else {
            
            return
        }
        
        self.webView.load(URLRequest(url: url))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if self.navigationController != nil && self.navigationController!.isBeingPresented {
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                    target: self, action: #selector(self.close))
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.showBusy()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.hideBusy()
    }
    
    func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
}
