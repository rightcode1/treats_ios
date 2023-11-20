//
//  UserSupportViewController.swift
//  spa
//
//  Created by 이동석 on 2022/12/18.
//

import UIKit

class UserSupportViewController: BaseViewController {
  @IBOutlet var tableView: UITableView!
  @IBOutlet var editButton: UIButton!

  var userSupportList = [UserSupport]()
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView?.frame.size.height = 0

    editButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "editUserSupport") as! EditUserSupportViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = false
    getUserSupportList()
  }
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = true
  }
  func getUserSupportList(_ refresh: Bool = true) {
    APIService.shared.userAPI.rx.request(.getUserSupportList(param: ListRequest(start: 0, perPage: 50)))
      .filterSuccessfulStatusCodes()
      .map(ListResponse<UserSupport>.self)
      .subscribe(onSuccess: { response in
        self.userSupportList = response.data
        if self.userSupportList.isEmpty {
          self.tableView.tableFooterView?.frame.size.height = self.tableView.frame.height
        }else{
          self.tableView.tableFooterView?.frame.size.height = 0
        }
        self.tableView.reloadData()
      }, onFailure: { error in
        log.error(error)
      })
      .disposed(by: disposeBag)
  }
}

extension UserSupportViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userSupportList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let userSupport = userSupportList[indexPath.row]

    (cell.viewWithTag(1) as! UILabel).text = userSupport.answered ? "답변완료" : "미답변"
    (cell.viewWithTag(1) as! UILabel).textColor = userSupport.answered ? UIColor(hex: "#1db0ab") : UIColor(hex: "#e96c68")

    (cell.viewWithTag(2) as! UILabel).text = userSupport.title
    (cell.viewWithTag(3) as! UILabel).text = Date.dateFromISO8601String(userSupport.createdAt)!.yyyyMMddDot
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "userSupportDetail") as! UserSupportDetailViewController
    vc.id = userSupportList[indexPath.row].id
    navigationController?.pushViewController(vc, animated: true)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
}
