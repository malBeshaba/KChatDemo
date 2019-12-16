//
//  AddVC.swift
//  KChat
//
//  Created by 王申宇 on 26/11/2019.
//  Copyright © 2019 王申宇. All rights reserved.
//
import UIKit

class AddVC: UIViewController {
    let label = UILabel()
    let usernameTXF = UITextField()
    let addButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        label.frame = CGRect(x: 40, y: 100, width: 200, height: 200)
        usernameTXF.frame = CGRect(x: 30, y: Screen.height / 3, width: Screen.width * 3 / 4, height: 40)
        addButton.frame = CGRect(x: 30, y: Screen.height / 3 + 100, width: 100, height: 40)
        initAddView()
        view.addSubview(label)
        view.addSubview(usernameTXF)
        view.addSubview(addButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ChatClient.share().setupNetworkCommunication()
    }

    func initAddView() {
        usernameTXF.layer.cornerRadius = 20
        usernameTXF.layer.borderColor = UIColor.lightGray.cgColor
        usernameTXF.layer.borderWidth = 0.5
        usernameTXF.placeholder = "   username"
        
        label.text = "who will you want?"

        addButton.layer.cornerRadius = 20
        addButton.backgroundColor = .brown
        addButton.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
    }
    
    @objc func addFriend() {
        ChatClient.share().addFriend(usernameTXF.text!)
    }
}
