//
//  ChatVC.swift
//  everydayPay_Admin
//
//  Created by 이남기 on 2023/02/12.
//

import Foundation
import UIKit

class ChatVC:BaseViewController{
  
  @IBOutlet weak var mainTableView: UITableView!
  
  
  var chatList: [ChatData] = []{
    didSet{
      mainTableView.reloadData()
    }
  }
  let socketManager = SocketIOManager.sharedInstance
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.isNavigationBarHidden = false
    self.navigationController?.isToolbarHidden = false
  }
  override func viewDidAppear(_ animated: Bool) {
    self.navigationController?.isToolbarHidden = true
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    initdelegate()
    initChatList()
  }
  func initdelegate(){
    socketManager.connection()
    mainTableView.delegate = self
    mainTableView.dataSource = self
  }
  
  func initChatList() {
    socketManager.getRoomList() { data in
      self.chatList.removeAll()
      self.chatList = data
      if self.chatList.isEmpty {
        self.mainTableView.tableFooterView?.frame.size.height = self.mainTableView.frame.height
      }else{
        self.mainTableView.tableFooterView?.frame.size.height = 0
      }
      print(self.chatList)
    }
  }
  
}
extension ChatVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chatList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    guard let profile = cell.viewWithTag(1) as? UIImageView,
          let name = cell.viewWithTag(2) as? UILabel,
          let content = cell.viewWithTag(3) as? UILabel,
          let time = cell.viewWithTag(4) as? UILabel else { return cell }
    let dict = chatList[indexPath.item]
    profile.kf.setImage(with: URL(string: dict.thumbnail ?? ""))
    name.text = dict.title ?? ""
    content.text = dict.message ?? ""
    time.text = dict.updatedAt ?? ""
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dict = chatList[indexPath.item]
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoomVC") as! ChatRoomVC
    vc.chatRoomId = dict.id!
    vc.RoomName = dict.title ?? ""
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//    return 182
    return UITableView.automaticDimension
  }
  
}
