//
//  ChatClient.swift
//  KChat
//
//  Created by 王申宇 on 21/11/2019.
//  Copyright © 2019 王申宇. All rights reserved.
//
import UIKit
import ImageIO
import FileProvider

protocol ChatClientDelegate: class {
    func received(message: Message)
    func received(file: File)
    func received(image: UIImage)
}
var friendList = [String]()
class ChatClient: NSObject {
    private static let shareClient: ChatClient = {
        let shared = ChatClient()
        return shared
    }()
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    weak var delegate: ChatClientDelegate?
    
    var userInfo: UserInfo!
    var message: String!
    
    var username = ""
    var password = ""
    
    var friendUsername = ""
    var index = 0
    
    let maxReadLength = 4096
    
    class func share() -> ChatClient {
        return shareClient
    }
    
    func setupNetworkCommunication() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           "localhost" as CFString,
                                           80,
                                           &readStream,
                                           &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
    }
    
    func setupNetworkCommunication(port: Int) {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           "localhost" as CFString,
                                           UInt32(port),
                                           &readStream,
                                           &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
    }
    
    func sendData( _ data: Data) {
        _ = data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
                else {
                    print("error to signup")
                    return
            }
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    func getFriendList(_ username: String) {
        let prefix = "007".data(using: .utf8)!
        sendData(prefix)
        print("007")
    }
    
    func signup(info: UserInfo) {
        self.userInfo = info
        let prefix = "001".data(using: .utf8)!
        sendData(prefix)
    }
    
    func login(info: UserInfo) {
        self.userInfo = info
        let prefix = "002".data(using: .utf8)!
        sendData(prefix)
    }
    
    func sendUserInfo() {
        let data = "\(self.userInfo.username),\(self.userInfo.password)".data(using: .utf8)!
        sendData(data)
    }
    
    func  beginToMessage(index: Int) {
        self.index = index
        let data = "003".data(using: .utf8)!
        sendData(data)
    }
  
    func send(message: String) {
        self.message = message
        sendMessage()
    }
    
    func sendLine(from: String, to: String) {
        let line = "from:\(from),to:\(to)".data(using: .utf8)!
        sendData(line)
    }
    
    func sendMessage() {
        let data = self.message.data(using: .utf8)!
        sendData(data)
    }
    
    func send(file: String) {
        let manager = FileManager.default
        let urlsForDocDirectory = manager.urls(for: .documentDirectory, in: .userDomainMask)
        let docPath = urlsForDocDirectory[0]
        let kFile = docPath.appendingPathComponent(file)
        let data = manager.contents(atPath: kFile.path)!
        sendData(data)
    }
    
    func send(image: UIImage) {
        let data = image.jpegData(compressionQuality: 0.7)!
        sendData(data)
    }
    
    func send(forFriendList user: String) {
        let username = user.data(using: .utf8)!
        sendData(username)
    }
    
    func addFriend( _ username: String) {
        let prefix = "006".data(using: .utf8)!
        self.friendUsername = username
        sendData(prefix)
    }
    
    func sendFriendInfo() {
        let friendInfo = "\(User.username),\(self.friendUsername)"
        let data = friendInfo.data(using: .utf8)!
        sendData(data)
    }
  
    func stopChatSession() {
        inputStream.close()
        outputStream.close()
    }
}

extension ChatClient: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            print("new message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            print("new message received")
            stopChatSession()
        case .errorOccurred:
            print("error occurred")
        case .hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
        }
    }
    private func readAvailableBytes(stream: InputStream) {
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
      
            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }
            if let tempString = String(bytesNoCopy: buffer, length: numberOfBytesRead, encoding: .utf8, freeWhenDone: true)?.components(separatedBy: ":") {
                switch tempString.first {
                case "001":
                    processedSignupOrLogin(strArr: tempString)
                    print("to signup")
                case "002":
                    processedSignupOrLogin(strArr: tempString)
                    print("to login")
                case "003":
                    processedMessageString(strArr: tempString)
                    print("message")
                case "004":
                    processedFile(strArr: tempString)
                case "005":
                    processedImage(strArr: tempString)
                case "006":
                    processedFriend(strArr: tempString)
                case "007":
                    processedFriendList(strArr: tempString)
                case "list":
                    postFriendList(tempString[1])
                case "msg":
                    receiveMessage(strArr: tempString)
                default:
                    print("error to read:\(tempString)")
                }
            }
        }
    }
    
    func processedSignupOrLogin(strArr: [String]) {
        if strArr.last == "isready" {
            sendUserInfo()
        }else {
            print("fail to send or server not ready")
        }
    }
  
    private func processedMessageString(strArr: [String]) {
        if strArr[1] == "isready" {
            sendLine(from: User.username, to: friendList[index])
            
        }else if strArr[1] == "receive"{
            DialogueViewController.receiveClient.setupNetworkCommunication(port: 8888)
            print("receive connect")
        }
    }
    
    func receiveMessage(strArr: [String]) {
        delegate?.received(message: Message(message: strArr[2], senderUsername: strArr[1], sender: .someoneElse))
        print("receive success")
    }
    
    func processedFile(strArr: [String]) {
        if strArr[1] == "ready" {
            send(file: "/Document/dic/file/文件.txt")
        }else if strArr[1] == "receive" {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
            let _ = inputStream.read(buffer, maxLength: maxReadLength)
            let manager = FileManager.default
            manager.createFile(atPath: "/Document/dic/file", contents: Data(buffer: UnsafeMutableBufferPointer(start: buffer, count: maxReadLength)), attributes: .none)
            delegate?.received(file: File(fileName: "文件", data: URL(fileURLWithPath: "/Document/dic/file/文件.txt")))
        }
    }
    
    func processedImage(strArr: [String]) {
        if strArr[1] == "ready" {
            
        }else if strArr[1] == "receive" {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
            let _ = inputStream.read(buffer, maxLength: maxReadLength)
            let image = UIImage(data: Data(buffer: UnsafeMutableBufferPointer(start: buffer, count: maxReadLength)))
            delegate?.received(image: image!)
        }
    }
    
    func processedFriend(strArr: [String]) {
        if strArr[1] == "isready" {
            sendFriendInfo()
        }
    }
    func processedFriendList(strArr: [String]) {
        if strArr[1] == "isready" {
            let data = User.username.data(using: .utf8)!
            sendData(data)
        }
    }
    
    func postFriendList( _ str: String) {
        let arr = str.components(separatedBy: ",")
        for i in 0..<arr.count {
            friendList.append(arr[i])
        }
    }
}
