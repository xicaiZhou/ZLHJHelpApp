//
//  DirectSWKWebViewVC.swift
//  ZLHJHelpAPP
//
//  Created by zhy on 2020/4/15.
//  Copyright © 2020 VIC. All rights reserved.
//

import UIKit
import WebKit
import PKHUD

class H5: BaseViewController {

    var webView = WKWebView()
    var goBackBtn = UIButton()
    var closeBtn = UIButton()
    var searchBtn = UIButton()
    var allowZoom = true // 是否允许缩放
    var H5Url: String = "" // 传入的链接
    private let h5ToSwift = "setLocal"
    var titleText = ""
    var iSTouchIDOrFaceID = false
    
    // 进度条
    lazy var progressView:UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor.orange
        progress.trackTintColor = .clear
        return progress
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        iSTouchIDOrFaceID = UserDefaults.standard.bool(forKey: "iSTouchIDOrFaceID")

//        let path = Utils.getFilePath(fileName: "index", ofType: "html")
//        let path =  "/Users/zhouxicai/Desktop/ZLHJHelpAPP/ZLHJHelpAPP/R/dist/index.html"

//        let mapwayURL = URL(fileURLWithPath: path)
        let mapwayURL = URL(string: "http://192.168.7.30:8080/#/")!
        let mapwayRequest = URLRequest(url: mapwayURL)
        print(mapwayRequest)
        /// 设置访问的URL
        /// 自定义配置
        let conf = WKWebViewConfiguration()
        conf.userContentController = WKUserContentController()
        conf.preferences.javaScriptEnabled = true
        conf.selectionGranularity = WKSelectionGranularity.character
        /// h5 调用 swift 提供的方法
        conf.userContentController.add(self, name: h5ToSwift)
        webView = WKWebView( frame: CGRect(x:0, y:KHeight_NavBar,width:kScreenWidth, height:kScreenHeight - KHeight_NavBar),configuration:conf)
        webView.addObserver(self, forKeyPath: "title", options: NSKeyValueObservingOptions.new, context: nil)

        view.addSubview(webView)
        webView.navigationDelegate = self
        webView.load(mapwayRequest)
        view.addSubview(self.progressView)
        
        // 设置返回按钮
        showLeftNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.progressView.frame = CGRect(x:0,y:KHeight_NavBar,width:kScreenWidth,height:2)
        self.progressView.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.progressView.progress = 0.0
        }
    }
    deinit {
        print("==============","\(self)","被销毁")
        //当前ViewController销毁前将其移除，否则会造成内存泄漏
        webView.configuration.userContentController.removeScriptMessageHandler(forName: h5ToSwift)
    }
    
    func showLeftNavigationItem(){
         searchBtn = self.setupRightBarButtonItemSelectorName(imageName: "ic_searchone") { [weak self] in
            var js = ""
            if self?.titleText == "经销商列表"{
               js = "showExhibitionSearch()"
            }else if self?.titleText == "车辆品牌"{
                js = "showCarModelSearch()"
            }
            else if self?.titleText == "车辆品牌列表"{
                js = "showCarModelListSearch()"
            }else if self?.titleText == "车系列表"{
                js = "showCarModelListSearch()"
            }else if self?.titleText == "查询"{
                js = "showCarModelListSearch()"
            }
            self!.webView.evaluateJavaScript(js) { (response, error) in
            }

         }
        // 返回按钮
        goBackBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        goBackBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0);
        goBackBtn.setImage(UIImage(named: "ic_turn")!.withRenderingMode(.alwaysOriginal), for: .normal)
        goBackBtn.setImage(UIImage(named: "ic_turn")!.withRenderingMode(.alwaysOriginal), for: .selected)
        goBackBtn.setTitle(" 返回", for: UIControl.State.normal)
        goBackBtn.setTitle(" 返回", for: UIControl.State.highlighted)
        goBackBtn.setTitleColor(systemColor, for: UIControl.State.normal)
        goBackBtn.addTarget(self, action: #selector(goBack), for: UIControl.Event.touchUpInside)
        let barGoBackBtn = UIBarButtonItem(customView: goBackBtn)
        
        //用于消除右边边空隙，要不然按钮顶不到最边上
        let spacer = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        spacer.width = -5;
        
        //设置按钮（注意顺序）
        self.navigationItem.leftBarButtonItems = [spacer, barGoBackBtn]
    }
    
    @objc func goBack(){
        if self.webView.canGoBack {
            self.webView.goBack()
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @objc func popViewController(){
        self.navigationController?.popViewController(animated: true)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         if keyPath == "title" {
            self.titleText = webView.title!;
            // 查询 车辆品牌 //车辆品牌列表  
            if webView.title == "首页" || webView.title == "查询" || webView.title == "我的"{
                self.goBackBtn.isHidden = true
            }else{
                self.goBackBtn.isHidden = false
            }
            if webView.title == "经销商列表" || webView.title == "车辆品牌" || webView.title == "车辆品牌列表" || webView.title == "查询"{
                self.searchBtn.isHidden = false;
            }else{
                self.searchBtn.isHidden = true;
            }
            
            if webView.title == "设置"{
//                var data = ["password":Utils.getPassword(),"cache":Utils.getCacheSize(),"phoneIsTouchID":]
                self.webView.evaluateJavaScript("") { (response, error) in
                }
            }
            self.navigationItem.title = webView.title;
        }
        
    }
    
}


extension H5: WKNavigationDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if !allowZoom {
            return nil
        }else{
            return webView.scrollView.subviews.first
        }
    }
    
//    // 页面开始加载时调用
//    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
//        HUD.show(.progress)
//        self.navigationItem.title = "加载中..."
//        /// 获取网页的progress
//        UIView.animate(withDuration: 0.5) {
//            self.progressView.progress = Float(self.webView.estimatedProgress)
//        }
//    }
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        
    }
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        
        HUD.hide()
        allowZoom = false
        
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = 1.0
            self.progressView.isHidden = true
        }
        
        /// iOS调用js
        // 调用js里的navButtonAction方法，并且传入了两个参数，回调里面response是这个方法return回来的数据
       let str = "userInfo(" + Utils.getUserInfo().kj.JSONString() + ")"
        self.webView.evaluateJavaScript(str) { (response, error) in
            print(response ?? "")
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


extension H5: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        /// JS调Native APP
        /// h5 调用 swift 方案   window.webkit.messageHandlers.AppFunc.postMessage("这是传个 Swift 的")
        
        if(message.name == h5ToSwift) { // 1-touchID 2-手势 3-缓存 4-登出
            print("JavaScript is sending a message.body \(message.body)")
            
            if let index = message.body as? Int{
                
                switch index {
                case 1:
                    FingureCheckTool.userFigerprintAuthenticationTipStr(withtips: "验证") { (result) in
                        if result == .success {
                            self.iSTouchIDOrFaceID = !self.iSTouchIDOrFaceID
                            UserDefaults.standard.set(self.iSTouchIDOrFaceID, forKey: "iSTouchIDOrFaceID") // 用户是否允许TouchID或FaceID登录
                        }else if result == .NotSupport {
                            Alert.showAlert2(self, title: "提示", message: "当前设备没有开启或不支持" + (isiPhoneX ? "FaceID" : "TouchID") + "," + "前往设置?", alertTitle1: "前往", style1: .default, confirmCallback1: {
                                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)

                            }, alertTitle2: "取消", style2: .cancel, confirmCallback2: {
                            });
                        }else if result == .touchidNotAvailable {
                            Alert.showAlert2(self, title: "提示", message: "当前设备没有开启" + (isiPhoneX ? "FaceID" : "TouchID") + "," + "前往设置?", alertTitle1: "前往", style1: .default, confirmCallback1: {
                                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)

                            }, alertTitle2: "取消", style2: .cancel, confirmCallback2: {
                            
                            });
                        }
                    }

                    break;
                case 2:
                self.navigationController?.pushViewController(PatternLockManagerVC(), animated: true)

                    break;
                case 3:
                
                    break;
                
                case 4:
                    
                    Window?.rootViewController = LoginVC();
                    break;
                
                default:
                    break;
                }
            }
            
        }
    }
}

