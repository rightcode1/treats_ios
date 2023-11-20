//
//  PointViewController.swift
//  spa
//
//  Created by 이동석 on 2023/02/02.
//

import UIKit

class PointViewController: BaseViewController {
  @IBOutlet var pointLabel: UILabel!
  @IBOutlet var tableView: UITableView!

  var pointList = [Point]()

  var start = 0
  var isLoadOver = false

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView?.frame.size.height = 0

    getPointList(refresh: true)
  }

  func getPointList(refresh: Bool) {
    if refresh {
      start = 0
      isLoadOver = false
      pointList = []
    }

    let param = ListRequest(start: start, perPage: 10)
    APIService.shared.userAPI.rx.request(.getPointList(param: param))
      .filterSuccessfulStatusCodes()
      .map(GetPointListResponse.self)
      .subscribe(onSuccess: { response in
        if response.data.isEmpty {
          self.isLoadOver = true
        }

        if refresh && response.data.isEmpty {
          self.tableView.tableFooterView?.frame.size.height = 300
        }

        self.pointLabel.text = response.point.formattedDecimalString()
        self.pointList += response.data
        self.start += 10
        self.tableView.reloadData()
      }, onFailure: { error in
        log.error(error)
      })
      .disposed(by: disposeBag)
  }
}

extension PointViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pointList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let point = pointList[indexPath.row]

    (cell.viewWithTag(1) as! UILabel).text = (point.point > 0 ? "적립" : "사용") + " | \((point.point < 0 ? -point.point : point.point).formattedDecimalString())"
    (cell.viewWithTag(2) as! UILabel).text = point.title
    (cell.viewWithTag(3) as! UILabel).text = Date.dateFromISO8601String(point.createdAt)?.yyyyMMddHHmm
    (cell.viewWithTag(4) as! UILabel).text = point.point > 0 ? "+\(point.point.formattedDecimalString())적립" : "\(point.point.formattedDecimalString())차감"
    (cell.viewWithTag(4) as! UILabel).textColor = point.point > 0 ? UIColor(hex: "#1db0ab") : UIColor(hex: "#f76161")

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 66
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == pointList.count - 1 && !isLoadOver {
      getPointList(refresh: false)
    }
  }
}
