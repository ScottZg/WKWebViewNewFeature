//
//  CustomResourceViewController.swift
//  WKWebViewNewFeaturesDemo
//
//  Created by zhanggui on 2018/1/10.
//  Copyright © 2018年 zhanggui. All rights reserved.
//

import UIKit
import WebKit
class CustomResourceViewController: UIViewController,WKNavigationDelegate {

    var customWebView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()
        let schemeHandler = MyCustomSchemeHandler.init(viewController: self)
        
        configuration.setURLSchemeHandler(schemeHandler, forURLScheme: "wk-feature")
        self.customWebView = WKWebView.init(frame: self.view.frame, configuration: configuration)
        self.customWebView.navigationDelegate = self
        self.view = self.customWebView
          self.customWebView.load(URLRequest.init(url: URL.init(string: "http://172.16.10.26:3333/src/p/customresource/customresource.html")!))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("-----load finished")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("*****load error")
    }

}
