//
//  ViewController.swift
//  KChat
//
//  Created by 王申宇 on 21/11/2019.
//  Copyright © 2019 王申宇. All rights reserved.
//

import UIKit

struct User {
    static var username = ""
    static var password = ""
}

class ViewController: UIViewController {
    
    let usernameTXF = UITextField()
    let passwordTXF = UITextField()
    let signUpBtn = UIButton()
    let signInBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        usernameTXF.frame = CGRect(x: 30, y: Screen.height / 3, width: Screen.width * 3 / 4, height: 40)
        passwordTXF.frame = CGRect(x: 30, y: Screen.height / 3 + 70, width: Screen.width * 3 / 4, height: 40)
        signInBtn.frame = CGRect(x: 40, y: Screen.height / 3 + 150, width: 100, height: 40)
        signUpBtn.frame = CGRect(x: 200, y: Screen.height / 3 + 150, width: 100, height: 40)
        initLoginView()
        view.addSubview(usernameTXF)
        view.addSubview(passwordTXF)
        view.addSubview(signInBtn)
        view.addSubview(signUpBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ChatClient.share().setupNetworkCommunication()
    }

    func initLoginView() {
        usernameTXF.layer.cornerRadius = 20
        usernameTXF.layer.borderColor = UIColor.lightGray.cgColor
        usernameTXF.layer.borderWidth = 0.5
        usernameTXF.placeholder = "username"
        passwordTXF.layer.cornerRadius = 20
        passwordTXF.layer.borderColor = UIColor.lightGray.cgColor
        passwordTXF.layer.borderWidth = 0.5
        passwordTXF.placeholder = "password"
        signUpBtn.backgroundColor = .red
        signUpBtn.layer.cornerRadius = 20
        signUpBtn.setTitle("注册", for: .normal)
        signUpBtn.addTarget(self, action: #selector(signup), for: .touchUpInside)
        
        signInBtn.backgroundColor = UIColor.systemGreen
        signInBtn.layer.cornerRadius = 20
        signInBtn.setTitle("登陆", for: .normal)
        signInBtn.addTarget(self, action: #selector(signin), for: .touchUpInside)
    }
    
    @objc func signup() {
        let info = UserInfo(username: usernameTXF.text!, password: passwordTXF.text!)
        ChatClient.share().signup(info: info)
//        pushToFriendListAnyway()
    }
    
    @objc func signin() {
        let info = UserInfo(username: usernameTXF.text!, password: passwordTXF.text!)
        ChatClient.share().login(info: info)
        User.username = usernameTXF.text!
        User.password = passwordTXF.text!
        pushToFriendListAnyway()
    }
    
    @objc func pushToFriendListAnyway() {
        let friendlist = FriendListViewController()
        navigationController?.pushViewController(friendlist, animated: true)
    }
    
    @objc func pushToChatViewAnyway() {
        let chatview = DialogueViewController()
        navigationController?.pushViewController(chatview, animated: true)
    }
}
