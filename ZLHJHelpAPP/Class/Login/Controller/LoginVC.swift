//
//  LoginVC.swift
//  ZLHJHelpAPP
//
//  Created by 周希财 on 2019/9/11.
//  Copyright © 2019 VIC. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class LoginVC: BaseViewController {


    @IBOutlet weak var isShowPassword: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var getCode: UIButton!
    @IBOutlet weak var forgetPassword: UIButton!
    var iSTouchIDOrFaceID = false
    /** 默认倒计时间60s */
    fileprivate var timeCount:Int = 60
    override func viewDidLoad() {
        super.viewDidLoad()
     
        #if DEBUG
           name.text = "admin"
           password.text = "admin"
           code.text = "123"
        #endif
        
        password.isSecureTextEntry = true
        versionLabel.text = "版本号：" + Utils.appVersion()
        if iSTouchIDOrFaceID {
            FingureCheckTool.userFigerprintAuthenticationTipStr(withtips: "验证登录") { (result) in
                if result == .success {
                    
                    let param = ["SERVICE_NAME": "SIGNAL_LOGIN",
                                 "CORE_SERVICENAME": "verifyUsernameAndPassword.user",
                                 "actType": "4"]
                    main{
                        HUD.show(.progress)

                    }
                    XCNetWorkTools().requestData(type: .post, api: "signalLogin", encoding: .JSON, parameters: param, success: { (value) in
                        let value = (value as! Dictionary<String, Any>)
                      

                        main {
                            HUD.flash(.success, delay: 1.0) { finished in
//                                Window?.rootViewController = BaseTabbarController()
                            }
                        }
                        
                    }) { (error) in
                        
                    }
                }
            }
        }
    }
   
    
    @IBAction func showPassword(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            sender.setImage(UIImage(named: "睁眼"), for: .normal)
            password.isSecureTextEntry = false
            
        }else{
            sender.setImage(UIImage(named: "闭眼"), for: .normal)
            password.isSecureTextEntry = true
        }
        
    }
    
    @IBAction func forgetPasswordAction(_ sender: Any) {
        
        let vc = ForgetPasswordOneVC()
        vc.type = .forget
        vc.name = name.text
        let nav = BaseNavigationController(rootViewController:vc)
        self.present(nav, animated: true, completion: nil)
        
    }
    @IBAction func getCode(_ sender: UIButton) {
        
        if name.text == "" || password.text == ""{
            showToast("请将用户名密码填写完整！")
            return
        }
        sender.countDownWithInterval(text: "获取验证码")
        ZLHJGCDCountBtn.share.scheduledDispatchTimer(withName: "loginCountBtn", timeInterval: 1, queue: .main, repeats: true) { 
            self.timeCount -= 1
            sender.setTitle("\(self.timeCount)s", for: .normal)
            sender.setTitleColor(.white, for: .normal)
            sender.backgroundColor = textGrayColor
            sender.isEnabled = false
            
            if self.timeCount <= 0 {
                ZLHJGCDCountBtn.share.destoryTimer(withName: "loginCountBtn") {
                    self.timeCount = 60
                    sender.setTitle("重新获取", for: .normal)
                    sender.setTitleColor(.white, for: .normal)
                    sender.backgroundColor = systemColor
                    sender.isEnabled = true
                }
            }
        }
        
        
        let param:[String: Any] = [
            "SERVICE_NAME": "APP_APPLYCODE",
            "CORE_SERVICENAME": "verifyUsernameAndPassword.user",
            "actType": "4",
            "password": password.text ?? "",
            "username": name.text!.removeAllSapce(),
            "uid": name.text ?? ""
            ]
        HUD.flash(.progress)
        XCNetWorkTools().requestData( api: "old", parameters: param, success: { (value) in

            HUD.flash(.success, delay: 1)

            self.showToast((value as! Dictionary)["result"])
        }) { (error) in
            
        }

    }
    @IBAction func login(_ sender: Any) {
        name.resignFirstResponder()
        password.resignFirstResponder()
        code.resignFirstResponder()
        if name.text == "" || password.text == "" {
            showToast("请将用户名密码填写完整！")
            return
        }
        if code.text == "" {
            showToast("请将验证码填写完整！")
            return
        }
        let param = [
            "code": code.text!,
            "verifyToken":"",
            "username": name.text!.removeAllSapce(),
            "password": password.text!,
            ]
        
        HUD.show(.progress)
        XCNetWorkTools().requestData(type: .post, api: "/api/login", encoding: .JSON, parameters: param, success: { (res) in

            print(res)
            let value = (res as! Dictionary<String, Any>)
            
            Utils.userDefaultSave(Key: "isLogin", Value: true)
            Utils.userDefaultSave(Key: "USER", Value: value)
            Utils.savePassword(Password: self.password.text!)
            Utils.saveMaxErrorCount(count: 5)
            
            HUD.flash(.success, delay: 1.0) { finished in
                Window?.rootViewController =  BaseNavigationController(rootViewController: H5())
            }
            ZLHJGCDCountBtn.share.destoryTimer(withName: "loginCountBtn") {
                self.timeCount = 60
                self.getCode.setTitle("获取验证码", for: .normal)
                self.getCode.setTitleColor(.white, for: .normal)
                self.getCode.backgroundColor = systemColor
                self.getCode.isEnabled = true
            }
        }) { (error) in
            HUD.flash(.error, delay: 1.0)

        }
    }
   
}
