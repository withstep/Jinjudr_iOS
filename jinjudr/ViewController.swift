//
//  ViewController.swift
//  jinjudr
//
//  Created by 최병구 on 2017. 8. 7..
//  Copyright © 2017년 최병구. All rights reserved.
//

import UIKit
import WebKit
import Firebase

var myContext = 0

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var myURL = "http://www.jinjudr.or.kr/app/index.php"
    var webView: WKWebView!
    var activityIndicator = UIActivityIndicatorView()
    
    var backBarButton: UIBarButtonItem?
    var forwardBarButton: UIBarButtonItem?
    var homeBarButton: UIBarButtonItem?
    var refreshBarButton: UIBarButtonItem?
    
    override func loadView() {
        super.loadView()
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences = preferences
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isUserInteractionEnabled = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        self.navigationController?.isNavigationBarHidden = false;
        self.navigationController?.isToolbarHidden = false;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IndicatorView.shared.show()
        
        let token = InstanceID.instanceID().token()
        print("Token : " + token!)
        myURL = myURL + "?device=iOS&iostoken=" + token!
        let webURL = URL(string: myURL)!
        var webRequest = URLRequest(url: webURL)
        var cookies = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies(for: webRequest.url!)!)
        if let value = cookies["Cookie"] {
            webRequest.addValue(value, forHTTPHeaderField: "Cookie")
        }
        webView.load(webRequest)
        webView.navigationDelegate = self
        
        webView.addObserver(self, forKeyPath: "title", options: .new, context: &myContext)
        webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: &myContext)
        webView.addObserver(self, forKeyPath: "canGoForward", options: .new, context: &myContext)
        
        view = webView
        
        self.backBarButton?.isEnabled = false
        self.forwardBarButton?.isEnabled = false
        
        self.navigationItem.titleView = setTitle(title: "진주시의사회")
        
        let edgeSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.backBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_arrow_back"), style: .plain, target: self, action: #selector(backBarButtonTapped))
        self.forwardBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_arrow_forward"), style: .plain, target: self, action: #selector(forwardBarButtonTapped))
        self.homeBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_home"), style: .plain, target: self, action: #selector(homeBarButtonTapped))
        self.refreshBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_refresh"), style: .plain, target: self, action: #selector(refreshBarButtonTapped))
        
        self.toolbarItems = [edgeSpace, self.backBarButton!, space, self.forwardBarButton!, space, self.homeBarButton!, space, self.refreshBarButton!, edgeSpace]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTitle(title:String) -> UIView {
        let titleView = UIView(frame: CGRect(x:0, y: 0, width: self.view.frame.width, height: 60))
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y:15, width:0, height:0))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        titleLabel.center.x = titleView.center.x
        titleView.addSubview(titleLabel)
        
        return titleView
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 1. 가운데 로딩 이미지를 띄워주면서
        IndicatorView.shared.show()
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 1. 제거
        IndicatorView.shared.hide()
        
        // 2. 제거
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context != &myContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == "title" {
            if let title = change?[.newKey] as? String {
                self.navigationItem.title = title
            }
            return
        }
        
        if keyPath == "canGoBack" {
            if let canGoBack = change?[.newKey] as? Bool {
                self.backBarButton?.isEnabled = canGoBack
            }
            return
        }
        
        if keyPath == "canGoForward" {
            if let canGoForward = change?[.newKey] as? Bool {
                self.forwardBarButton?.isEnabled = canGoForward
            }
            return
        }
    }
    
    func backBarButtonTapped() {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    func forwardBarButtonTapped() {
        if self.webView.canGoForward {
            self.webView.goForward()
        }
    }
    
    func homeBarButtonTapped() {
        
        
        let webRequest = URLRequest(url: URL(string: myURL)!);
        self.webView.load(webRequest)
    }
    
    func refreshBarButtonTapped() {
        self.webView.reload()
    }
    
    // MARK: - WKNavigationDelegate methods
    
    
    internal func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {
        print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(decisionHandler)")
        
        //        let url = navigationAction.request.url
        
        switch navigationAction.navigationType {
        case .linkActivated:
            if navigationAction.targetFrame == nil {
                self.webView.load(navigationAction.request)
            }
        default:
            break
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping ((WKNavigationResponsePolicy) -> Void)) {
        print("webView:\(webView) decidePolicyForNavigationResponse:\(navigationResponse) decisionHandler:\(decisionHandler)")
        
        decisionHandler(.allow)
    }
    
    // MARK: WKUIDelegate methods
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (() -> Void)) {
        print("webView:\(webView) runJavaScriptAlertPanelWithMessage:\(message) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        IndicatorView.shared.hide()
        
        let alertController = UIAlertController(title: frame.request.url?.host, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completionHandler()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ((Bool) -> Void)) {
        print("webView:\(webView) runJavaScriptConfirmPanelWithMessage:\(message) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        IndicatorView.shared.hide()
        
        let alertController = UIAlertController(title: frame.request.url?.host, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completionHandler(false)
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completionHandler(true)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String!) -> Void) {
        //print("webView:\(webView) runJavaScriptTextInputPanelWithPrompt:\(prompt) defaultText:\(String(defaultText)) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        IndicatorView.shared.hide()
        
        let alertController = UIAlertController(title: frame.request.url?.host, message: prompt, preferredStyle: .alert)
        weak var alertTextField: UITextField!
        alertController.addTextField { textField in
            textField.text = defaultText
            alertTextField = textField
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completionHandler(nil)
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completionHandler(alertTextField.text)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
}



//extension String {
//    func aesEncrypt(key: String, iv: String) throws -> String{
//        let data = self.data(using: .utf8)
//        let enc = try AES(key: key, iv: iv, blockMode:.ECB, padding: PKCS7()).encrypt(data!.bytes)
//        let encData = NSData(bytes: enc, length: Int(enc.count))
//        let base64String: String = encData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0));
//        let result = String(base64String)
//        return result!
//    }
//
//    func aesDecrypt(key: String, iv: String) throws -> String {
//        let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0))
//        let dec = try AES(key: key, iv: iv, blockMode: .ECB, padding: PKCS7()).decrypt(data!.bytes)
//        let decData = NSData(bytes: dec, length: Int(dec.count))
//        let result = NSString(data: decData as Data, encoding: String.Encoding.utf8.rawValue)
//        return String(result!)
//    }
//}

