//
//  FriendListViewController.swift
//  KChat
//
//  Created by 王申宇 on 25/11/2019.
//  Copyright © 2019 王申宇. All rights reserved.
//

import UIKit

class FriendListViewController: UIViewController {
    var tableView: UITableView!
    var user: UserInfo!
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
//        loadData()
        initTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    func initNavigation() {
        navigationItem.title = "Run!"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadData))
    }
    
    func initTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    @objc func loadData() {
        ChatClient.share().getFriendList(User.username)
        tableView.reloadData()
    }
    
    @objc func addFriend() {
        let addVc = AddVC()
        navigationController?.pushViewController(addVc, animated: true)
    }
}

extension FriendListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = friendList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatview = DialogueViewController()
        ChatClient.share().beginToMessage(index: indexPath.row)
        navigationController?.pushViewController(chatview, animated: true)
    }
}
