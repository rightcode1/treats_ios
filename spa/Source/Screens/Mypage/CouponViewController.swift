//
//  CouponViewController.swift
//  spa
//
//  Created by 이동석 on 2023/01/31.
//

import UIKit
import RxSwift

class CouponViewController: BaseViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var statusCollectionView: UICollectionView!

  var start = 0

  var couponStatusList:[Coupon.Status] = [.ready, .used, .expired]
  var couponList = [Coupon]()

  let selectedCouponStatus = BehaviorSubject<Coupon.Status>(value: .ready)

  var isLoadOver = false

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView?.frame.size.height = 0

    bindOutput()
  }

  func getCouponList(refresh: Bool = true) {
    if refresh {
      start = 0
      isLoadOver = false
      couponList = []
    }

    let param = GetCouponListReq(
      status: try! selectedCouponStatus.value(),
      start: start,
      perPage: 10
    )

    APIService.shared.couponAPI.rx.request(.getCouponList(param: param))
      .filterSuccessfulStatusCodes()
      .map(ListResponse<Coupon>.self)
      .subscribe(onSuccess: { response in
        if refresh {
          self.tableView.tableFooterView?.frame.size.height = response.data.isEmpty ? self.tableView.frame.height - 100 : 0
        }

        self.couponList += response.data
        self.tableView.reloadData()
        self.start += 10
      }, onFailure: { error in

      })
      .disposed(by: disposeBag)
  }

  func bindOutput() {
    selectedCouponStatus.bind(onNext: { [weak self] status in
      self?.statusCollectionView.reloadData()
      self?.getCouponList()
    })
    .disposed(by: disposeBag)
  }
}

extension CouponViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return couponStatusList.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    let status = couponStatusList[indexPath.item]
    let selectedStatus = try! selectedCouponStatus.value()

    (cell.viewWithTag(1) as! UILabel).text = status.getString()

    if status == selectedStatus {
      cell.backgroundColor = .black
      (cell.viewWithTag(1) as! UILabel).textColor = .white
    } else {
      cell.backgroundColor = UIColor(hex: "#eff2f8")
      (cell.viewWithTag(1) as! UILabel).textColor = UIColor(hex: "#2d2d2d")
    }

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedCouponStatus.onNext(couponStatusList[indexPath.item])
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 70, height: 30)
  }
}

extension CouponViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return couponList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StoreCouponCell
    let coupon = couponList[indexPath.row]

    switch try! selectedCouponStatus.value() {
    case .ready:
      cell.couponImageView.image = UIImage(named: "couponAvailable")
    case .used:
      cell.couponImageView.image = UIImage(named: "couponUsed")
    case .expired:
      cell.couponImageView.image = UIImage(named: "couponExpired")
    }

    cell.priceLabel.text = coupon.name
    cell.nameLabel.text = coupon.contents
    let startDate = Date.dateFromISO8601String(coupon.startDate)!
    let endDate = Date.dateFromISO8601String(coupon.endDate)!
    cell.periodLabel.text = "\(startDate.yyyyMMddDot) ~ \(endDate.yyyyMMddDot)"

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let height = ((UIScreen.main.bounds.width - 40) / 320 * 127) + 20
    return height
  }
}
