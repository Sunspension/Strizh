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
    
    init(url: URL, fileName: String) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.url = url
        self.fileName = fileName
    }
    
    override func loadView() {
        
        super.loadView()
        
        self.webView.navigationDelegate = self
        self.view = self.webView
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                target: self, action: #selector(self.close))
        self.title = self.fileName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = self.url else {
            
            return
        }
        
        self.webView.load(URLRequest(url: url))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
