//
//  LoginViewController.swift
//  KChat
//
//  Created by 王申宇 on 22/11/2019.
//  Copyright © 2019 王申宇. All rights reserved.
//

import UIKit

struct Screen {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
}

class LoginViewController: UIViewController {
    
    let usernameTXF = UITextView()
    let passwordTXF = UITextView()
    let signUpBtn = UIButton()
    let signInBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChatClient.share().setupNetworkCommunication()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        initLoginView()
        view.backgroundColor = .white
        usernameTXF.frame = CGRect(x: 30, y: Screen.height / 3, width: Screen.width * 3 / 4, height: 40)
        passwordTXF.frame = CGRect(x: 30, y: Screen.height / 3 + 70, width: Screen.width * 3 / 4, height: 40)
        view.addSubview(usernameTXF)
        view.addSubview(passwordTXF)
    }
    
    func initLoginView() {
        usernameTXF.layer.cornerRadius = 20
        usernameTXF.layer.borderColor = UIColor.lightGray.cgColor
        usernameTXF.layer.borderWidth = 0.5
        passwordTXF.layer.cornerRadius = 20
        passwordTXF.layer.borderColor = UIColor.lightGray.cgColor
        passwordTXF.layer.borderWidth = 0.5
        
        signUpBtn.backgroundColor = .clear
        signUpBtn.setTitle("注册账号？", for: .normal)
        signUpBtn.addTarget(self, action: #selector(signup), for: .touchUpInside)
        
        signInBtn.backgroundColor = UIColor.systemGreen
        signInBtn.setTitle("登陆", for: .normal)
        signInBtn.addTarget(self, action: #selector(signin), for: .touchUpInside)
    }
    
    @objc func signup() {
        let info = UserInfo(username: usernameTXF.text, password: passwordTXF.text)
        ChatClient.share().signup(info: info)
    }
    
    @objc func signin() {
        
    }
}
