//
//  XCNetwork.swift
//  renrendai-swift
//
//  Created by 周希财 on 2019/8/9.
//  Copyright © 2019 VIC. All rights reserved.
//

import Foundation
import Alamofire
import Toast_Swift
import PKHUD

typealias successBlock = (Any)->()
typealias errorBlock = (Any)->()
typealias NetworkStatus = (_ XCNetworkStatus: Int32) -> ()

enum Encoding {
    case URL
    case JSON
}


/*
 * 配置网络环境
 */
enum  NetworkEnvironment{
    case Development
    case sitTest
    case standbySitTest
    case uatTest
    case Distribution
    case SimulationDistribution
}

// 登录服务
private var Base_Url = "" 


//修改此处更换域名
private let CurrentNetWork : NetworkEnvironment = .Development


private var xcNetworkStatus : XCNetworkStatus = XCNetworkStatus.wifi

/// 传参方式
//    1、JSONEncoding.default 是放在HttpBody内的，   比如post请求
//    2、URLEncoding.default 在GET中是拼接地址的，    比如get请求
//    3、URLEncoding(destination: .methodDependent) 是自定义的URLEncoding，methodDependent的值如果是在GET 、HEAD 、DELETE中就是拼接地址的。其他方法方式是放在httpBody内的。
//    4、URLEncoding(destination: .httpbody)是放在httpbody内的



/*
 * 当前网络
 */
@objc enum XCNetworkStatus: Int32 {
    case unknown          = -1//未知网络
    case notReachable     = 0//网络无连接
    case wwan             = 1//2，3，4G网络
    case wifi             = 2//wifi网络
}


class XCNetWorkTools: NSObject {
    private var sessionManager: SessionManager?
    static let share = XCNetWorkTools()
    
    override init() {
        super.init()
        sessionManager = SessionManager.default
        
    }
}


private func XCNetwork(network : NetworkEnvironment = CurrentNetWork){
    
    if(network == .Development){
        
        Base_Url = "http://192.168.88.94:8888"
        
    }else if(network == .sitTest){
        
        Base_Url = "http://10.215.85.11:8087/zlhj_interface/appHelper/"
        
    }else if(network == .standbySitTest){
        
        Base_Url = "http://192.168.88.62:8080/zlhj_interface/appHelper/"
        
    }else if(network == .uatTest){
        
        Base_Url = "http://10.215.85.12:8080/zlhj_interface/appHelper/"
        

    }else if(network == .SimulationDistribution){
        
        Base_Url = "http://192.168.90.101:8080/zlhj_interface/appHelper/"
        
    }else{
        
        Base_Url = "https://www.huijiefinance.net/zlhj_interface/appHelper/"
    }
}

/// 设置请求头
let headers :HTTPHeaders = [
    "Accept": "application/json",
    "Content-Type" : "application/json",
    "token":Utils.getToken()
    
]

extension XCNetWorkTools {
    ///监听网络状态
    public func detectNetwork(netWorkStatus: @escaping NetworkStatus) {
        let reachability = NetworkReachabilityManager()
        reachability?.startListening()
        reachability?.listener = { status in
            if reachability?.isReachable ?? false {
                switch status {
                case .notReachable:
                    xcNetworkStatus = XCNetworkStatus.notReachable
                case .unknown:
                    xcNetworkStatus = XCNetworkStatus.unknown
                case .reachable(.wwan):
                    xcNetworkStatus = XCNetworkStatus.wwan
                case .reachable(.ethernetOrWiFi):
                    xcNetworkStatus = XCNetworkStatus.wifi
                }
            } else {
                xcNetworkStatus = XCNetworkStatus.notReachable
            }
            netWorkStatus(xcNetworkStatus.rawValue)
        }
    }
    ///监听网络状态
    public func obtainDataFromLocalWhenNetworkUnconnected() {
        self.detectNetwork { (_) in
        }
    }
    
    //网络请求
    func requestData(type: HTTPMethod = .post,
                     api: String,
                     encoding: Encoding = .JSON,
                     parameters: Dictionary<String, Any>,
                     success: @escaping successBlock,
                     faild: @escaping errorBlock) -> () {
        
            //拼接URL
            XCNetwork();
            let url = Base_Url + api;
            var paramEncoding : ParameterEncoding
            
            if encoding == .URL{
                paramEncoding = URLEncoding.default
            }else{
                paramEncoding = JSONEncoding.default
            }

            self.sessionManager!.request(url,
                                         method: type,
                                         parameters: parameters,
                                         encoding: paramEncoding,
                                         headers: headers)
                .responseJSON(completionHandler: { (resJson) in
                    
                    print("url:\(String(describing: resJson.request))"  + "isSuccess?:\(resJson.result)")  // 原始的URL请求
                    print(resJson.result.value as Any)   // 响应序列化结果，在这个闭包里，存储的是JSON数据
                    
                    switch resJson.result {
                        
                    case .success:
                        if let value = resJson.result.value {
                            let dic = value as! [String:Any]
                            let data = dic["data"] as! [String:Any]
                            let code = dic["code"] as! Int
                            let msg = dic["message"] as! String
                            if code == 200 {
                                success(data)
                            }else if code == 9999 {
                                HUD.hide()
                                
//                                let message = msg
//                                let msg = message["updateMsg"] as! String
//                                let versionName = message["versionName"] as! String
//                                AppUpdateAlert.showUpdateAlert(version: versionName, description: msg)
                                
                            }
                            else
                            {
                               
                                BaseViewController.currentViewController()?.showToast(msg)
                                
                                faild(msg)
                                HUD.hide()
                                
                            }
                        }
                        
                    case .failure(let error):
                        
                        print("GetErrorUrl:\(String(describing: resJson.request))")
                        print("GetError:\(error)")
                        faild(error.localizedDescription)
                        HUD.flash(.error)
                        
                    }
                })
            
        }
            
   
}




