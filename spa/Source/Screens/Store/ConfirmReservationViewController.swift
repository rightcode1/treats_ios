//
//  ConfirmReservationViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/15.
//

import UIKit

class ConfirmReservationViewController: BaseViewController {
  @IBOutlet weak var nextButton: UIButton!

  @IBOutlet weak var storeNameLabel: UILabel!
  @IBOutlet weak var storeSummaryLabel: UILabel!

  @IBOutlet weak var reservationDateLabel: UILabel!
  @IBOutlet weak var reservationTimeLabel: UILabel!
  @IBOutlet weak var bedCountLabel: UILabel!
  @IBOutlet weak var coupleRoomLabel: UILabel!
  @IBOutlet weak var coupleRoomView: UIView!

  @IBOutlet var productCategoryLabel: UILabel!
  @IBOutlet var productNameLabel: UILabel!
  @IBOutlet var productTimeLabel: UILabel!
  @IBOutlet var productPriceLabel: UILabel!
  @IBOutlet var productTotalLabel: UILabel!
  
  @IBOutlet weak var optionTableView: UITableView!
  @IBOutlet weak var optionTableViewHeight: NSLayoutConstraint!

  var store: Store!
  var productCategory: Store.ProductCategory?
  var product: Store.Product!
  var date: Date!
  var time: Date!
  var selectedReservationTime: Date!
  var selectedBedCount: Int!
  var selectedCoupleRoom: Bool! = false
  var optionList = [(Store.Option, Int)]()

  override func viewDidLoad() {
    super.viewDidLoad()

    if !optionList.isEmpty {
      optionTableViewHeight.constant = CGFloat(48 * optionList.count)
    } else {
      optionTableViewHeight.constant = 28
    }

    storeNameLabel.text = store.name
    storeSummaryLabel.text = store.categories?.filter({ $0.isParent ?? false }).map({ $0.name }).joined(separator: " • ")
    reservationDateLabel.text = date.yyyyMMddeDot
    reservationTimeLabel.text = selectedReservationTime.ahmm
    bedCountLabel.text = "\(selectedBedCount ?? 0)명"
    coupleRoomView.isHidden = selectedBedCount < 2
    if selectedBedCount > 1 {
      coupleRoomLabel.text = selectedCoupleRoom ? "사용" : "사용안함"
    }
    productCategoryLabel.text = productCategory?.name
    productNameLabel.text = product.name
    productTimeLabel.text = "\(product.time)분"
    productPriceLabel.text = "\(product.price.formattedDecimalString())원"
    productTotalLabel.text = "\((product.price * selectedBedCount).formattedDecimalString())원"

    nextButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "requestPayment") as! RequestPaymentViewController
        vc.delegate = self
        self.present(vc, animated: false)
      })
      .disposed(by: disposeBag)
  }
}

extension ConfirmReservationViewController: RequestPaymentDelegate {
  func didPaymentButtonTapped() {
    let param = CreateOrderSheetRequest(
      date: date.yyyyMMdd,
      time: selectedReservationTime.HHmm,
      bedCount: selectedBedCount,
      productId: product.id,
      options: optionList.map({ option in
        return CreateOrderSheetRequest.Option(id: option.0.id, quantity: option.1)
      }),
      coupleRoom: selectedCoupleRoom == nil ? nil : selectedCoupleRoom
    )
    APIService.shared.orderAPI.rx.request(.createOrderSheet(param: param))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        if let id = ((try? response.mapJSON()) as? [String: Any])?["id"] as? String {
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "orderSheet") as! OrderSheetViewController
          vc.sheetId = id
          self.navigationController?.pushViewController(vc, animated: true)
        }
      }, onFailure: { error in
        if error.serverMessage == "full_reservation" {
          self.callOkActionMSGDialog(message: "이미 예약중입니다") {
            self.backPress()
          }
        } else {
          self.callMSGDialog(message: "오류가 발생하였습니다")
        }
      })
      .disposed(by: disposeBag)
//
  }
}

extension ConfirmReservationViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return max(optionList.count, 1)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    if optionList.isEmpty {
      (cell.viewWithTag(1) as! UILabel).text = "없음"
      (cell.viewWithTag(2) as! UILabel).isHidden = true
    } else {
      let option = optionList[indexPath.row].0
      let quantity = optionList[indexPath.row].1
      (cell.viewWithTag(1) as! UILabel).isHidden = false
      (cell.viewWithTag(2) as! UILabel).isHidden = false

      (cell.viewWithTag(1) as! UILabel).text = "\(option.name) /\(quantity.formattedDecimalString())개"
      (cell.viewWithTag(2) as! UILabel).text = "\((quantity*option.price).formattedDecimalString())원"
    }

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 48
  }
}
