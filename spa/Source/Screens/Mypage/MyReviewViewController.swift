//
//  MyReviewViewController.swift
//  spa
//
//  Created by 이동석 on 2023/01/15.
//

import UIKit

class MyReviewViewController: BaseViewController {
  @IBOutlet var tableView: UITableView!

  var reviewList = [Review]()

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "cell")
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.tableView.tableFooterView?.frame.size.height = 0
    getReviewList()
  }

  func getReviewList() {
    let param = GetReviewListRequest(
      start: 0,
      perPage: 50,
      userId: DataHelperTool.userId!
    )

    APIService.shared.reviewAPI.rx.request(.getReviewList(query: param))
      .filterSuccessfulStatusCodes()
      .map(ListResponse<Review>.self)
      .subscribe(onSuccess: { response in
        self.reviewList = response.data
        if self.reviewList.isEmpty {
          self.tableView.tableFooterView?.frame.size.height = self.tableView.frame.height
        }else{
          self.tableView.tableFooterView?.frame.size.height = 0
        }
        self.tableView.reloadData()
      }, onFailure: { error in

      })
      .disposed(by: disposeBag)
  }
}

extension MyReviewViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reviewList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReviewCell
    let review = reviewList[indexPath.row]
    cell.initWithReview(review)
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 200
  }
}
