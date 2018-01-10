//
//  ViewController.swift
//  WKWebViewNewFeaturesDemo
//
//  Created by zhanggui on 2018/1/10.
//  Copyright © 2018年 zhanggui. All rights reserved.
//

import UIKit
import WebKit
class ViewController: UIViewController,WKUIDelegate,UINavigationControllerDelegate,WKNavigationDelegate {

    
    var myWKWebView: WKWebView! = nil
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let cookie = HTTPCookie.init(properties: [
            .domain:"172.16.10.26",
            .path:"/src/p/index/index.html",
            .version:0,
            .expires:Date.init(timeIntervalSinceNow: 30*60*60),
            .name:"username",
            .value:"zhanggui33"
            ])
        
        let configuration = WKWebViewConfiguration()
        //myWkWebView初始化
        self.myWKWebView = WKWebView.init(frame: self.view.frame, configuration: configuration)
        self.myWKWebView.scrollView.isScrollEnabled = false
        self.myWKWebView.uiDelegate = self
        self.myWKWebView.navigationDelegate = self
        
        self.view.addSubview(self.myWKWebView)
        
        
        
        //set cookies
        let cookieStore = myWKWebView.configuration.websiteDataStore.httpCookieStore
        cookieStore.setCookie(cookie!) {
            
            self.myWKWebView.load(URLRequest.init(url: URL.init(string: "http://172.16.10.26:3333/src/p/index/index.html")!))
        }
        
        
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview load finished")
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                print("cookie name is \(cookie.name),and cookie value is \(cookie.value)")
        
            }
        }
    }
    
//    //MARK: WKWebViewDelegate
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController.init(title: "温馨提示", message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "好的", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        completionHandler();
    }
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alert = UIAlertController.init(title: "温馨提示", message: prompt, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "好的", style: .default) { (action) in
            let textField: UITextField = alert.textFields![0]
            completionHandler(textField.text)
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (act) in
            completionHandler(nil)
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        alert.addTextField { (textField) in
            textField.placeholder = defaultText
            
        }
        self.present(alert, animated: true, completion: nil)
       

    }
    //MARK: private method
    func alertF(string: String) {
        let alert = UIAlertController.init(title: "温馨提示", message: string, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "好的", style: .default) { (action) in
            print("click done...")
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        

    }
    @IBAction func refreshWebViewAction(_ sender: Any) {
        self.myWKWebView.reload()
    }
    @IBAction func logoutAction(_ sender: Any) {
        let cookieStore = myWKWebView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                if cookie.name == "username" {
                    cookieStore.delete(cookie, completionHandler: {
                        self.alertF(string: "已经退出登录")
                    })
                }
            }
        }
    }
}

