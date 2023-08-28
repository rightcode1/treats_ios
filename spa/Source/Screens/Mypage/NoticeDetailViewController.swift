//
//  NoticeDetailViewController.swift
//  spa
//
//  Created by 이동석 on 2023/01/09.
//

import UIKit

class NoticeDetailViewController: BaseViewController {
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var createdAtLabel: UILabel!
  @IBOutlet var contentLabel: UILabel!

  var id: Int!

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = "-"
    contentLabel.text = "-"

    getNotice()
  }

  func getNotice() {
    APIService.shared.commonAPI.rx.request(.getNotice(id: id))
      .filterSuccessfulStatusCodes()
      .map(Notice.self)
      .subscribe(onSuccess: { response in
        self.titleLabel.text = response.title
        self.createdAtLabel.text = Date.dateFromISO8601String(response.createdAt)?.yyyyMMddDot
        self.contentLabel.text = response.content
      }, onFailure: { error in

      })
      .disposed(by: disposeBag)
  }
}
