//
//  FilterViewController.swift
//  WKWebViewNewFeaturesDemo
//
//  Created by zhanggui on 2018/1/10.
//  Copyright © 2018年 zhanggui. All rights reserved.
//

import UIKit
import WebKit
class FilterViewController: UIViewController {

    var filterWebView: WKWebView!

    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.filterWebView = WKWebView.init(frame: self.view.frame)
        self.filterWebView.allowsBackForwardNavigationGestures = true
        self.view = self.filterWebView
        
        
        //两个触发器：把http强转成https，把所有的图片阻塞加载
        let jsonString = """
            [{
                "trigger":{
                    "url-filter": ".*",
                    "resource-type":["image"]
                },
                "action":{
                    "type":"block"
                }
            }]
            """
        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "demoRuleList", encodedContentRuleList: jsonString) { (list, error) in
            guard let contentRuleList = list else { return }
            let configuration = self.filterWebView.configuration
            configuration.userContentController.add(contentRuleList)
            self.filterWebView.load(URLRequest.init(url: URL.init(string: "http://m.baidu.com")!))
        }
        
    }
    //MARK: Private method

}
