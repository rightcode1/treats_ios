//
//  UserSupportDetailViewController.swift
//  spa
//
//  Created by 이동석 on 2023/01/09.
//

import UIKit

class UserSupportDetailViewController: BaseViewController {

  @IBOutlet var answeredLabel: UILabel!

  @IBOutlet var titleLabel: UILabel!

  @IBOutlet var createdAtLabel: UILabel!

  @IBOutlet var contentTextView: UITextView!
  @IBOutlet var answerTitleView: UIView!
  @IBOutlet var answerTItleLabel: UILabel!

  @IBOutlet var answerContentView: UIView!
  @IBOutlet var answerContentTextView: UITextView!

  var id: Int!

  override func viewDidLoad() {
    super.viewDidLoad()

    answerTitleView.isHidden = true
    answerContentView.isHidden = true

    answeredLabel.text = "-"
    titleLabel.text = "-"
    contentTextView.text = "-"

    getUserSupport()
  }
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
  }

  func getUserSupport() {
    showHUD()
    APIService.shared.userAPI.rx.request(.getUserSupport(id: id))
      .filterSuccessfulStatusCodes()
      .map(UserSupport.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.answeredLabel.text = response.answered ? "답변완료" : "미답변"
        self.answeredLabel.textColor = response.answered ? UIColor(hex: "#85d0c9") : UIColor(hex: "#ff7e7e")
        self.titleLabel.text = response.title
        self.contentTextView.text = response.content
        self.contentTextView.dataDetectorTypes = .link
        self.answerTItleLabel.text = response.answerTitle
        self.answerContentTextView.text = response.answerContent
        self.answerContentTextView.dataDetectorTypes = .link
        
        self.createdAtLabel.text = Date.dateFromISO8601String(response.createdAt)!.yyyyMMddDot
        
        self.answerTitleView.isHidden = !response.answered
        self.answerContentView.isHidden = !response.answered
      }, onFailure: { error in
        self.dismissHUD()
        self.callOkActionMSGDialog(message: "오류가 발생하였습니다\n\(error.localizedDescription)") {
          self.backPress()
        }
      })
      .disposed(by: disposeBag)
  }
}
