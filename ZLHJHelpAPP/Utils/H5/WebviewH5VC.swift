//
//  WebviewH5VC.swift
//  ZLHJHelpAPP
//
//  Created by zhy on 2019/12/30.
//  Copyright © 2019 VIC. All rights reserved.
//

import UIKit
import WebKit
import PKHUD

class WebviewH5VC: BaseViewController {

    var webView = WKWebView()
    var allowZoom = true
    var H5Url: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.progressView.frame = CGRect(x:0,y:KHeight_NavBar,width:kScreenWidth,height:2)
        self.progressView.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.progressView.progress = 0.0
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = self.H5Url
         
         webView = WKWebView(frame: CGRect(x: 0, y: KHeight_NavBar, width: kScreenWidth, height: kScreenHeight - KHeight_NavBar))
         view.addSubview(webView)
         webView.navigationDelegate = self
         let mapwayURL = URL(string: url)!
         let mapwayRequest = URLRequest(url: mapwayURL)
         webView.load(mapwayRequest)
        
         view.addSubview(self.progressView)
    }
    
    // 进度条
    lazy var progressView:UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor.orange
        progress.trackTintColor = .clear
        return progress
    }()
    
}

extension WebviewH5VC: WKNavigationDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if !allowZoom {
            return nil
        }else{
            return webView.scrollView.subviews.first
        }
    }
    
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        HUD.show(.progress)
        self.navigationItem.title = "加载中..."
        /// 获取网页的progress
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = Float(self.webView.estimatedProgress)
        }
    }
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        
    }
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        
        HUD.hide()
        allowZoom = false
        /// 获取网页title
        self.title = self.webView.title
        
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = 1.0
            self.progressView.isHidden = true
        }
    }
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = 0.0
            self.progressView.isHidden = true
        }
        /// 弹出提示框点击确定返回
        HUD.flash(.labeledError(title: "加载失败!", subtitle: ""))
        
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        HUD.flash(.labeledError(title: "加载失败!", subtitle: ""))
    }
}
