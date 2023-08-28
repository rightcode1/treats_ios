//
//  OrderDetailViewController.swift
//  spa
//
//  Created by 이동석 on 2023/01/09.
//

import UIKit

class OrderDetailViewController: BaseViewController {
  @IBOutlet var storeNameLabel: UILabel!
  @IBOutlet var storeCategoryLabel: UILabel!
  @IBOutlet var orderStatusLabel: UILabel!

  @IBOutlet var reservationDateLabel: UILabel!
  @IBOutlet var reservationTimeLabel: UILabel!
  @IBOutlet var bedCountLabel: UILabel!

  @IBOutlet var productCategoryLabel: UILabel!
  @IBOutlet var productNameLabel: UILabel!
  @IBOutlet var productTimeLabel: UILabel!
  @IBOutlet var productPriceLabel: UILabel!
  @IBOutlet var totalProductPriceLabel: UILabel!

  @IBOutlet weak var optionTableView: UITableView!
  @IBOutlet weak var optionTableViewHeight: NSLayoutConstraint!

  @IBOutlet var userNameLabel: UILabel!
  @IBOutlet var userPhoneLabel: UILabel!

  @IBOutlet var paymentMethodLabel: UILabel!
  @IBOutlet var paymentCreatedAtLabel: UILabel!
  @IBOutlet var amountLabel2: UILabel!

  @IBOutlet var amountLabel3: UILabel!
  @IBOutlet var productAmountLabel: UILabel!
  @IBOutlet var optionAmountLabel: UILabel!
  @IBOutlet var discountAmountLabel: UILabel!

  @IBOutlet var totalBedCountLabel1: UILabel!
  @IBOutlet var totalBedCountLabel2: UILabel!

  @IBOutlet var canceledView: UIView!
  @IBOutlet var cancelMemoLabel: UILabel!
  @IBOutlet var cancelAmountLabel: UILabel!
  @IBOutlet var cancelledAtLabel: UILabel!
  @IBOutlet var cancelledAtLabel2: UILabel!

  @IBOutlet var refundView: UIView!
  @IBOutlet var refundButton: UIButton!

  var id: Int!

  var order: Order?

  override func viewDidLoad() {
    super.viewDidLoad()

    storeNameLabel.text = "-"
    storeCategoryLabel.text = "-"
    orderStatusLabel.text = "-"

    reservationDateLabel.text = "-"
    reservationTimeLabel.text = "-"
    bedCountLabel.text = "-"

    productCategoryLabel.text = "-"
    productNameLabel.text = "-"
    productTimeLabel.text = "-"
    productPriceLabel.text = "-"
    totalProductPriceLabel.text = "-"

    userNameLabel.text = "-"
    userPhoneLabel.text = "-"

    paymentMethodLabel.text = "-"
    paymentCreatedAtLabel.text = "-"
    amountLabel2.text = "-"
    amountLabel3.text = "-"
    productAmountLabel.text = "-"
    optionAmountLabel.text = "-"
    discountAmountLabel.text = "-"
    refundView.isHidden = true

    bindInput()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    getOrder()
  }

  func bindInput() {
    refundButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        guard let order = self.order else { return }
        if self.checkRefundableTime() {
          self.callOkCancelMSGDialog(message: "환불 진행하시겠습니까?") {
            APIService.shared.orderAPI.rx.request(.cancelOrder(id: order.id))
              .filterSuccessfulStatusCodes()
              .subscribe(onSuccess: { response in
                self.getOrder()
                self.callOkActionMSGDialog(message: "환불 처리가 완료되었습니다") {
//                  self.backPress()
                }
              }, onFailure: { error in
                if error.serverMessage == "invalidate_date" {
                  let vc = self.storyboard?.instantiateViewController(withIdentifier: "CancelPopup") as! CancelDialog
                    self.present(vc, animated: true)
                } else {
                  self.callMSGDialog(message: "오류가 발생하였습니다")
                }
              })
              .disposed(by: self.disposeBag)
          }
        } else {
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "CancelPopup") as! CancelDialog
            self.present(vc, animated: true)
        }
      })
      .disposed(by: disposeBag)
  }

  func checkRefundableTime() -> Bool {
    return true
  }

  func getOrder() {
    showHUD()
    APIService.shared.orderAPI.rx.request(.getOrderDetail(id: id))
      .filterSuccessfulStatusCodes()
      .map(Order.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.order = response
        self.initWithOrder()
      }, onFailure: { error in
        self.dismissHUD()
        self.callOkActionMSGDialog(message: "오류가 발생하였습니다") {
          self.backPress()
        }
        log.error(error)
      })
      .disposed(by: disposeBag)
  }

  func initWithOrder() {
    guard let order = order else { return }
    storeNameLabel.text = order.store.name
    storeCategoryLabel.text = order.store.categories?.filter({$0.isParent == true}).map({$0.name}).joined(separator: " • ")
    orderStatusLabel.text = order.status.getString()
    orderStatusLabel.textColor = order.status.getTextColor()

    let reservationDate = Date.dateFromISO8601String(order.reservationDate)
    reservationDateLabel.text = reservationDate?.yyyyMMddeDot
    reservationTimeLabel.text = reservationDate?.ahhmm
    bedCountLabel.text = "\(order.bedCount)명"

    productCategoryLabel.text = order.product.category?.name
    productNameLabel.text = order.product.name
    productTimeLabel.text = "\(order.product.time)분"
    productPriceLabel.text = "\(order.product.price.formattedDecimalString())원"
    totalProductPriceLabel.text = "\(order.productAmount.formattedDecimalString())원"

    optionTableViewHeight.constant = CGFloat(max(1, order.options.count) * 48)
    optionTableView.reloadData()

    userNameLabel.text = order.buyerName
    userPhoneLabel.text = order.buyerTel

    paymentMethodLabel.text = order.payment?.method.getString() ?? "포인트 사용"
    paymentCreatedAtLabel.text = Date.dateFromISO8601String(order.payment?.createdAt ?? order.createdAt)?.yyyyMMddHHmm
    amountLabel2.text = order.amount.formattedDecimalString() + "원"
    amountLabel3.text = order.amount.formattedDecimalString() + "원"
    productAmountLabel.text = order.amount.formattedDecimalString() + "원"
    discountAmountLabel.text = "0원"

    totalBedCountLabel1.text = "(x\(order.bedCount)인)"
    totalBedCountLabel2.text = "(x\(order.bedCount)인)"

    var totalAmount = order.productAmount * order.bedCount
    order.options.forEach { option in
      totalAmount += option.quantity * option.option.price
    }

    optionAmountLabel.text = totalAmount.formattedDecimalString() + "원"

    canceledView.isHidden = order.cancelledMemo != nil ? false : true
    refundView.isHidden = true
    if order.status == .ready || order.status == .noReady{
      refundView.isHidden = false
      refundButton.setTitle("예약금 \(order.amount.formattedDecimalString())원 환불하기", for: .normal)
    } else if order.status == .cancelled {
      cancelMemoLabel.text = order.cancelledMemo
      cancelAmountLabel.text = order.amount.formattedDecimalString() + "원"
      if let date = Date.dateFromISO8601String(order.cancelledAt ?? "") {
        cancelledAtLabel.text = date.yyyyMMddHHmm
        cancelledAtLabel2.text = date.yyyyMMddHHmm
      }
    }
  }
}

extension OrderDetailViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return max((order?.options ?? []).count, 1)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let options = order?.options ?? []
    if options.isEmpty {
      let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)

      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      let option = options[indexPath.row]

      (cell.viewWithTag(1) as! UILabel).text = "\(option.option.name) /\(option.quantity)개"
      (cell.viewWithTag(2) as! UILabel).text = "\((option.option.price*option.quantity).formattedDecimalString())원"

      return cell
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 48
  }
}
