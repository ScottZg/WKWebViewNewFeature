//
//  MyCustomSchemeHandler.swift
//  WKWebViewNewFeaturesDemo
//
//  Created by zhanggui on 2018/1/10.
//  Copyright © 2018年 zhanggui. All rights reserved.
//

import UIKit
import WebKit
class MyCustomSchemeHandler: NSObject,WKURLSchemeHandler,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
 
    var controller: UIViewController?
    var task:WKURLSchemeTask?
    
    
    
    init(viewController controller:UIViewController) {
        self.controller = controller
    }
    
    
    
    
    
    
    
    //MARK: WKURLSchemeHandler
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        task = urlSchemeTask
        
        
        
        let imageName = self.getImageName(string: urlSchemeTask.request.url!.absoluteString as NSString)
        let image = UIImage.init(named: imageName as String)!
        let data = UIImageJPEGRepresentation(image, 1.0)!
        task?.didReceive(URLResponse.init(url: (task?.request.url!)!, mimeType: "image/jpeg", expectedContentLength: data.count, textEncodingName: nil))
        task?.didReceive(data)
        task?.didFinish()
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.sourceType = .photoLibrary
//        controller?.present(picker, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        task = nil
    }
    //MARK: Private method
    func getImageName(string: NSString) ->String {
        if string.hasPrefix("wk-feature://") {
            let range = string.range(of: "wk-feature://")
            if range.location != NSNotFound {
                return string.substring(from: range.length)
            }
            
        }
        return "cat"
    }
    //MARK: UIIMagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        controller?.dismiss(animated: true, completion: nil)
        guard let task = task else { return }
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let data = UIImageJPEGRepresentation(image, 1.0)!
        
        task.didReceive(URLResponse.init(url: task.request.url!, mimeType: "image/jpeg", expectedContentLength: data.count, textEncodingName: nil))
        task.didReceive(data)
        task.didFinish()
    }
    
    
}
