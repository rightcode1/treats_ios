//
//  StoreCouponViewController.swift
//  spa
//
//  Created by 이동석 on 2023/01/31.
//

import UIKit

class StoreCouponViewController: BaseViewController {
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet var sheetView: UIView!

  var parentVC: StoreDetailViewController?
  var couponList = [Coupon]()

  override func viewDidLoad() {
    super.viewDidLoad()

    sheetView.layer.cornerRadius = 10
    sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

    bottomConstraint.constant = -460
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    bottomConstraint.constant = 0
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
}

extension StoreCouponViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return couponList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StoreCouponCell
    let coupon = couponList[indexPath.row]

    if (parentVC?.downloadCouponIdList ?? []).contains(coupon.id) {
      cell.couponImageView.image = UIImage(named: "couponDownloaded")
    } else {
      cell.couponImageView.image = UIImage(named: "couponDownload")
    }

    cell.priceLabel.text = coupon.name
    cell.nameLabel.text = coupon.contents
    let startDate = Date.dateFromISO8601String(coupon.startDate)!
    let endDate = Date.dateFromISO8601String(coupon.endDate)!
    cell.periodLabel.text = "\(startDate.yyyyMMddDot) ~ \(endDate.yyyyMMddDot)"

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (parentVC?.downloadCouponIdList ?? []).contains(couponList[indexPath.row].id) {
      showToast(message: "이미 다운로드한 쿠폰입니다")
      return
    }

    APIService.shared.couponAPI.rx.request(.downloadCoupon(id: couponList[indexPath.row].id))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        self.parentVC?.downloadCouponIdList.append(self.couponList[indexPath.row].id)
        self.showToast(message: "다운로드 완료되었습니다")
        tableView.reloadData()
      }, onFailure: { error in
        self.showToast(message: "오류가 발생하였습니다")
      })
      .disposed(by: disposeBag)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let height = ((UIScreen.main.bounds.width - 40) / 320 * 127) + 20
    return height
  }
}
