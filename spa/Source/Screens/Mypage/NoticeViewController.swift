//
//  NoticeViewController.swift
//  spa
//
//  Created by 이동석 on 2023/01/09.
//

import UIKit

class NoticeViewController: BaseViewController {
  @IBOutlet var tableView: UITableView!

  var noticeList = [Notice]()

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView?.frame.size.height = 0
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    getNoticeList()
  }

  func getNoticeList(_ refresh: Bool = true) {
    APIService.shared.commonAPI.rx.request(.getNoticeList(param: ListRequest(start: 0, perPage: 50)))
      .filterSuccessfulStatusCodes()
      .map(ListResponse<Notice>.self)
      .subscribe(onSuccess: { response in
        self.noticeList = response.data
        self.tableView.reloadData()
      }, onFailure: { error in

      })
      .disposed(by: disposeBag)
  }
}

extension NoticeViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return noticeList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let notice = noticeList[indexPath.row]

    (cell.viewWithTag(1) as! UILabel).text = notice.title
    (cell.viewWithTag(2) as! UILabel).text = Date.dateFromISO8601String(notice.createdAt)?.yyyyMMddDot

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "noticeDetail") as! NoticeDetailViewController
    vc.id = noticeList[indexPath.row].id
    navigationController?.pushViewController(vc, animated: true)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
}
