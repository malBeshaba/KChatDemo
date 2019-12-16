//
//  DialogueViewController.swift
//  KChat
//
//  Created by 王申宇 on 24/11/2019.
//  Copyright © 2019 王申宇. All rights reserved.
//

import UIKit

class DialogueViewController: UIViewController {
    let tableView = UITableView()
    let messageInputBar = MessageInputView()
    var messages = [Message]()
    var username = ""
    static let sendClient = ChatClient()
    static let receiveClient = ChatClient()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ChatClient.share().delegate = self
        DialogueViewController.receiveClient.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ChatClient.share().stopChatSession()
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
      
      loadViews()
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
      if let userInfo = notification.userInfo {
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue
        let messageBarHeight = messageInputBar.bounds.size.height
        let point = CGPoint(x: messageInputBar.center.x, y: endFrame.origin.y - messageBarHeight/2.0)
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: endFrame.size.height, right: 0)
        UIView.animate(withDuration: 0.25) {
          self.messageInputBar.center = point
          self.tableView.contentInset = inset
        }
      }
    }
    
    func loadViews() {
      navigationItem.backBarButtonItem?.title = "Run!"
       view.backgroundColor = UIColor(red: 24 / 255, green: 180 / 255, blue: 128 / 255, alpha: 1.0)
      
      tableView.dataSource = self
      tableView.delegate = self
      tableView.separatorStyle = .none
      
      view.addSubview(tableView)
      view.addSubview(messageInputBar)
      
      messageInputBar.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      let messageBarHeight:CGFloat = 60.0
      let size = view.bounds.size
      tableView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height - messageBarHeight - view.safeAreaInsets.bottom)
      messageInputBar.frame = CGRect(x: 0, y: size.height - messageBarHeight - view.safeAreaInsets.bottom, width: size.width, height: messageBarHeight)
    }
}

extension DialogueViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MessageTableViewCell(style: .default, reuseIdentifier: "MessageCell")
        cell.selectionStyle = .none
        cell.apply(message: messages[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MessageTableViewCell.height(for: messages[indexPath.row])
    }
    
    func insertNewMessageCell(_ message: Message) {
      messages.append(message)
      let indexPath = IndexPath(row: messages.count - 1, section: 0)
      tableView.beginUpdates()
      tableView.insertRows(at: [indexPath], with: .bottom)
      tableView.endUpdates()
      tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
}

extension DialogueViewController: MessageInputDelegate {
    func sendWasTapped(message: String) {
//        insertNewMessageCell(Message(message: "aaa", senderUsername: "A"))
//        ChatClient.share().send(message: "aaa")
        DialogueViewController.sendClient.setupNetworkCommunication(port: 10000)
        DialogueViewController.sendClient.sendData(message.data(using: .utf8)!)
        insertNewMessageCell(Message(message: message, senderUsername: User.username, sender: .ourself))
    }
}

extension DialogueViewController: ChatClientDelegate {
    func received(message: Message) {
        insertNewMessageCell(message)
    }
    
    func received(file: File) {
        
    }
    
    func received(image: UIImage) {
        
    }
    
    
}
