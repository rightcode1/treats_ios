//
//  ChatRoomVC.swift
//  everydayPay_Admin
//
//  Created by 이남기 on 2023/02/12.
//

import Foundation
import SocketIO
import UIKit
import Photos
import DKImagePickerController

class ChatRoomVC:BaseViewController{
  
  @IBOutlet weak var mainTableView: UITableView!
  
  @IBOutlet weak var inputTextView: UITextField!{
    didSet{
      if inputTextView.text != ""{
        sendMessageButton.tintColor = .blue
      }
    }
  }
  @IBOutlet weak var sendMessageButton: UIImageView!
  @IBOutlet weak var addFileButton: UIImageView!
  @IBOutlet weak var moreButton: UIBarButtonItem!
  @IBOutlet var introduceLabel: UILabel!
  
  var isMine: Bool = true
  var chatRoomId: Int = -1
  var RoomName: String = ""
  let socketManager = SocketIOManager.sharedInstance
  
  override func viewWillAppear(_ animated: Bool) {
      self.navigationController?.isNavigationBarHidden = false
    navigationItem.title = RoomName
    introduceLabel.text = "안녕하세요.\(RoomName)지점입니다.\n궁금하신내용이나 확인하실내용을 남겨주시면,\n지점과 채팅가능합니다."
  }
  
  var messageList: [ChatMessage] = []{
    didSet{
      //      print(messageList)
      mainTableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    extendedLayoutIncludesOpaqueBars = true
    super.viewDidLoad()
    initdelegate()
    initrx()
    socketOn(chatRoomId)
  }
  func initdelegate(){
    mainTableView.delegate = self
    mainTableView.dataSource = self
  }
  
  func socketOn(_ chatRoomid: Int) {
    socketManager.enterRoom(chatRoomId: chatRoomid) { ( messageList: [ChatMessage]) in
      self.messageList = messageList
      if !self.messageList.isEmpty{
        self.mainTableView.scrollToRow(at: IndexPath(row: self.messageList.count - 1 , section: 0), at: .bottom, animated: true)
      }
    }
    
    socketManager.messageRefresh { messageData in
      self.messageList.append(messageData)
      self.mainTableView.scrollToRow(at: IndexPath(row: self.messageList.count - 1 , section: 0), at: .bottom, animated: true)
    }
    self.socketManager.sendMessage(message: self.inputTextView.text!)
    self.finishSendMessageEvent()
  }
  
  func initrx(){
    addFileButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.showImagePicker(from: self,maxSelectableCount: 1) { selectedImage in
        }
      })
      .disposed(by: disposeBag)
    sendMessageButton.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          guard let self = self else { return }
          if self.inputTextView.text != nil{
            self.socketManager.sendMessage(message: self.inputTextView.text!)
            self.finishSendMessageEvent()
          }
        })
        .disposed(by: disposeBag)
  }
//  func uploadMessageFile(image: UIImage) {
//    APIProvider.shared.chatAPI.rx.request(.chatMessageFileRegister(chatRoomId: chatRoomId, image: image))
//      .filterSuccessfulStatusCodes()
//      .map(RegistChatMessageImageResponse.self)
//      .subscribe(onSuccess: { response in
//        self.socketManager.sendImage(chatRoomId: self.chatRoomId, messageId: response.data.id)
//          self.messageList.append(MessageData.init(dict: response.data.dictionary ?? [:]))
//      }, onError: { error in
//      })
//      .disposed(by: disposeBag)
//  }
  
    func finishSendMessageEvent() {
      inputTextView.text = nil
      self.view.endEditing(true)
    }
  
}
extension ChatRoomVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messageList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let dict = messageList[indexPath.item]
    if dict.type == "system"{
      let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "enterUser", for: indexPath)
      guard let systemMessage = cell.viewWithTag(1) as? UILabel else { return cell }
      let dict = messageList[indexPath.item]
      systemMessage.text = dict.message
      return cell
    }else{
      if dict.userId == DataHelperTool.userId{
        let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "myMessageCell", for: indexPath) as! MyMessageCell
        cell.initupdate(data: dict)
        return cell
      }else{
        let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! MessageCell
        cell.initupdate(data: dict,roomName: RoomName)
        return cell
      } 
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let dict = messageList[indexPath.item]
    if dict.userId == DataHelperTool.userId{
      return UITableView.automaticDimension
    }else{
      return 83.5
    }
  }
  
  
}

