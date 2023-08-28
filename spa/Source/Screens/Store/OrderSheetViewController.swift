//
//  OrderSheetViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/16.
//

import UIKit
import iamport_ios

class OrderSheetViewController: BaseViewController {
  @IBOutlet weak var storeNameLabel: UILabel!
  @IBOutlet var storeCategoriesLabel: UILabel!

  @IBOutlet weak var reservationDateLabel: UILabel!
  @IBOutlet weak var reservationTimeLabel: UILabel!
  @IBOutlet weak var bedCountLabel: UILabel!

  @IBOutlet var productCategoryLabel: UILabel!
  @IBOutlet var productNameLabel: UILabel!
  @IBOutlet var productTimeLabel: UILabel!
  @IBOutlet var productPriceLabel: UILabel!
  @IBOutlet var productBedCountLabel: UILabel!
  @IBOutlet var productTotalPriceLabel: UILabel!

  @IBOutlet weak var optionTableView: UITableView!
  @IBOutlet weak var optionTableViewHeight: NSLayoutConstraint!

  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userTelLabel: UILabel!

  @IBOutlet var pointView: UIView!
  @IBOutlet var pointDividerView: UIView!
  @IBOutlet var pointTextField: UITextField!
  @IBOutlet var useMaxPointButton: UIButton!
  @IBOutlet var userPointLabel: UILabel!

  @IBOutlet weak var payMethodCollectionView: UICollectionView!

  @IBOutlet weak var totalPriceLabel: UILabel!
  @IBOutlet var totalBedCountLabel: UILabel!
  @IBOutlet weak var productPriceLabel2: UILabel!
  @IBOutlet weak var optionPriceLabel: UILabel!
  @IBOutlet weak var discountPriceLabel: UILabel!

  @IBOutlet var checkPaymentTermsButton: UIButton!
  @IBOutlet var showPaymentTermsButton: UIButton!

  @IBOutlet var paymentTermsView: UIView!

  @IBOutlet weak var paymentButton: UIButton!

  var sheetId: String!

//  var store: Store!
//  var product: Store.Product!
//  var date: Date!
//  var time: Date!
//  var selectedBedCount: Int!

  var orderSheet: OrderSheet?

  let payMethodList = ["카드결제", "휴대폰 결제", "실시간 계좌이체"]

  var amount = 0

  var isTemrsCheck = false

  override func viewDidLoad() {
    super.viewDidLoad()

    pointView.isHidden = true
    pointDividerView.isHidden = true
    paymentTermsView.isHidden = false

    bindInput()
    bindOutput()
    getOrderSheet()
  }

  func bindInput() {
    useMaxPointButton.rx.tap
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        guard let orderSheet = self.orderSheet else { return }
        let userPoint = orderSheet.user.point ?? 0
        let availablePoint = min(self.amount, userPoint)
        self.pointTextField.text = availablePoint.formattedDecimalString()
        self.setTotalAmountWithPoint(point: availablePoint)
      })
      .disposed(by: disposeBag)

    paymentButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }

        if !self.isTemrsCheck {
          self.callMSGDialog(message: "결제 이용 관련 약관에 동의해주세요")
          return
        }

        self.getHTMLString()
      })
      .disposed(by: disposeBag)

    checkPaymentTermsButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if self.isTemrsCheck {
          self.isTemrsCheck = false
          self.checkPaymentTermsButton.setImage(UIImage(named: "iconCheckOff"), for: .normal)
        } else {
          self.isTemrsCheck = true
          self.checkPaymentTermsButton.setImage(UIImage(named: "iconCheckOn"), for: .normal)
        }
      })
      .disposed(by: disposeBag)

    showPaymentTermsButton.rx.tap
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if self.paymentTermsView.isHidden {
          self.paymentTermsView.isHidden = false
          self.showPaymentTermsButton.setImage(UIImage(named: "iconArrowDown"), for: .normal)
        } else {
          self.paymentTermsView.isHidden = true
          self.showPaymentTermsButton.setImage(UIImage(named: "iconArrowUp"), for: .normal)
        }
      })
      .disposed(by: disposeBag)
  }

  func bindOutput() {
    pointTextField.rx.text.orEmpty
      .bind(onNext: { [weak self] text in
        self?.setTotalAmountWithPoint(point: 0)
        guard let self = self else { return }
        guard let orderSheet = self.orderSheet else { return }
        guard let point = Int(text.replacingOccurrences(of: ",", with: "")) else { return }
        let userPoint = orderSheet.user.point ?? 0
        let availablePoint = min(self.amount, userPoint)
        if availablePoint < point {
          self.pointTextField.text = availablePoint.formattedDecimalString()
          self.setTotalAmountWithPoint(point: availablePoint)
        } else {
          self.pointTextField.text = point.formattedDecimalString()
          self.setTotalAmountWithPoint(point: point)
        }
      })
      .disposed(by: disposeBag)
  }

  func setTotalAmountWithPoint(point: Int) {
    discountPriceLabel.text = "\(point.formattedDecimalString())원"
    totalPriceLabel.text = "\((amount - point).formattedDecimalString())원"
    paymentButton.setTitle("\((amount - point).formattedDecimalString())원 결제하기", for: .normal)
  }

  func getOrderSheet() {
    showHUD()
    APIService.shared.orderAPI.rx.request(.getOrderSheet(id: sheetId))
      .filterSuccessfulStatusCodes()
      .map(OrderSheet.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.orderSheet = response
        self.initWithOrderSheet()
      }, onFailure: { error in
        self.dismissHUD()
        log.error(error)
        self.callOkActionMSGDialog(message: "오류가 발생하였습니다") {
          self.backPress()
        }
      })
      .disposed(by: disposeBag)
  }

  func initWithOrderSheet() {
    guard let orderSheet = orderSheet else { return }
    storeNameLabel.text = orderSheet.store.name
    storeCategoriesLabel.text = orderSheet.store.categories?
      .filter({ $0.isParent == true })
      .map({ $0.name })
      .joined(separator: " • ")

    reservationDateLabel.text = Date.dateFromISO8601String(orderSheet.reservationDate)?.yyyyMMddeDot
    reservationTimeLabel.text = Date.dateFromISO8601String(orderSheet.reservationDate)?.ahhmm
    bedCountLabel.text = "\(orderSheet.bedCount)명"

    productCategoryLabel.text = orderSheet.product.category?.name
    productNameLabel.text = orderSheet.product.name
    productTimeLabel.text = String(orderSheet.product.time) + "분"
    productPriceLabel.text = orderSheet.product.price.formattedDecimalString() + "원"
    productBedCountLabel.text = "(x\(orderSheet.bedCount)인)"
    productTotalPriceLabel.text = "\((orderSheet.product.price * orderSheet.bedCount).formattedDecimalString())원"

    optionTableViewHeight.constant = CGFloat(max(1, orderSheet.options.count) * 48)
    optionTableView.reloadData()

    userNameLabel.text = orderSheet.user.name
    userTelLabel.text = orderSheet.user.phone?.insertPhoneHyphen

    var optionPrice = 0
    orderSheet.options.forEach { option in
      optionPrice += option.price * option.quantity
    }
    let totalProductPrice = orderSheet.product.price * orderSheet.bedCount
    let totalPrice = optionPrice + totalProductPrice

    let deposit = 30000 * orderSheet.bedCount

    totalBedCountLabel.text = "(x\(orderSheet.bedCount)인)"
    productPriceLabel2.text = "30,000원"
    optionPriceLabel.text = "\(totalPrice.formattedDecimalString())원"
    totalPriceLabel.text = "\(deposit.formattedDecimalString())원"
    paymentButton.setTitle("\(deposit.formattedDecimalString())원 결제하기", for: .normal)
    amount = deposit

    let userPoint = orderSheet.user.point ?? 0
    let availablePoint = min(totalPrice, userPoint)

    pointTextField.isEnabled = availablePoint > 0
    pointTextField.placeholder = "최대 \(availablePoint.formattedDecimalString())P 적용 가능"
    userPointLabel.text = "보유 포인트 \(userPoint.formattedDecimalString())P"
  }

  func getHTMLString() {
    let point = Int(pointTextField.text!.replacingOccurrences(of: ",", with: "")) ?? 0
    let param = PostOrderRequest(
      sheetId: sheetId,
      payMethod: .card,
      buyerEmail: orderSheet?.user.email ?? "test@test.com",
      buyerName: orderSheet?.user.name ?? "test",
      buyerTel: orderSheet?.user.phone ?? "01099596564",
      redirectUrl: "https://api.spa-dev.com/payments/complete",
      point: point
//      redirectUrl: "\(Environment.baseUrl)/payments/complete"
    )

    showHUD()
    if amount - point > 0 {

      APIService.shared.orderAPI.rx.request(.postOrderWebview(param: param))
        .filterSuccessfulStatusCodes()
        .map(IamportResponse.self)
        .subscribe(onSuccess: { response in
          self.dismissHUD()
          let request = IamPortRequest(
            pg: response.imp.pg,
            merchant_uid: response.imp.merchant_uid,
            amount: String(response.imp.amount))
            .then {
              $0.pay_method = PayMethod.card.rawValue
              $0.name = response.imp.name
              $0.buyer_email = response.imp.buyer_email
              $0.buyer_name = response.imp.buyer_name
              $0.app_scheme = Environment.urlScheme
            }
          Iamport.shared.payment(navController: self.navigationController!, userCode: response.impAccount, iamPortRequest: request) { [weak self] response in
            guard let self = self else { return }
            if response?.success == true {
              let vc = self.storyboard?.instantiateViewController(withIdentifier: "paymentComplete") as! PaymentCompleteViewController
              vc.orderSheet = self.orderSheet
              vc.amount = self.amount
              self.navigationController?.pushViewController(vc, animated: true)
            } else {
//              self.backPress()
            }
          }
        }, onFailure: { error in
          self.dismissHUD()
          log.error(error)
        })
        .disposed(by: disposeBag)
    } else {
      APIService.shared.orderAPI.rx.request(.postOrder(param: param))
        .filterSuccessfulStatusCodes()
        .subscribe(onSuccess: { response in
          self.dismissHUD()
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "paymentComplete") as! PaymentCompleteViewController
          vc.orderSheet = self.orderSheet
          vc.amount = self.amount
          self.navigationController?.pushViewController(vc, animated: true)
        }, onFailure: { error in
          self.dismissHUD()
        })
        .disposed(by: disposeBag)
    }
  }
}

extension OrderSheetViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return max((orderSheet?.options ?? []).count, 1)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let options = orderSheet?.options ?? []
    if options.isEmpty {
      let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)

      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      let option = options[indexPath.row]

      (cell.viewWithTag(1) as! UILabel).text = "\(option.name) /\(option.quantity)개"
      (cell.viewWithTag(2) as! UILabel).text = "\((option.price*option.quantity).formattedDecimalString())원"
//      (cell.viewWithTag(3) as! UILabel).text = "\((option.quantity * option.price).formattedDecimalString())원"

      return cell
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 48
  }
}

extension OrderSheetViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return payMethodList.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

    cell.borderColor = indexPath.item == 0 ? .black : UIColor(hex: "#c6c6c8")
    (cell.viewWithTag(1) as! UILabel).text = payMethodList[indexPath.item]
    (cell.viewWithTag(1) as! UILabel).textColor = indexPath.item == 0 ? .black : UIColor(hex: "#2D2D2D")

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (UIScreen.main.bounds.width - 60) / 3
    return CGSize(width: width, height: 40)
  }
}

