//
//  OrderHistoryViewController.swift
//  spa
//
//  Created by 이동석 on 2022/12/03.
//

import UIKit
import RxSwift

class OrderHistoryViewController: BaseViewController {
  @IBOutlet weak var tableView: UITableView!

  @IBOutlet var purchaseView: UIView!
  @IBOutlet var cancelView: UIView!
  @IBOutlet var orderStatusListView: UIView!
  @IBOutlet var orderStatusCollectionView: UICollectionView!
  @IBOutlet var emptyIcon: UIImageView!

  var orderList = [OrderList]()

  var selectedOrderStatus = BehaviorSubject<Order.Status?>(value: nil)
  let orderStatusList: [Order.Status?] = [nil, .noReady, .ready, .used]

  var start = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView?.frame.size.height = 0

    bindInput()
    bindOutput()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    getOrderList(refresh: true)
  }

  func bindInput() {
    purchaseView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.selectedOrderStatus.onNext(nil)
      })
      .disposed(by: disposeBag)

    cancelView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.selectedOrderStatus.onNext(.cancelled)
      })
      .disposed(by: disposeBag)
  }

  func bindOutput() {
    selectedOrderStatus.distinctUntilChanged().bind { [weak self] orderStatus in
      guard let self = self else { return }
      switch orderStatus {
      case .none:
        self.emptyIcon.image = UIImage(named: "emptyOrder")
        (self.purchaseView.viewWithTag(1) as! UILabel).textColor = .black
        self.purchaseView.viewWithTag(2)?.isHidden = false
        (self.cancelView.viewWithTag(1) as! UILabel).textColor = UIColor(hex: "#666666")
        self.cancelView.viewWithTag(2)?.isHidden = true
        self.orderStatusListView.isHidden = false
      case .noReady:
        self.emptyIcon.image = UIImage(named: "emptyOrder")
        break
      case .ready:
        self.emptyIcon.image = UIImage(named: "emptyOrder")
        break
      case .used:
        self.emptyIcon.image = UIImage(named: "emptyOrder")
        break
      case .cancelled:
        self.emptyIcon.image = UIImage(named: "emptyCancelOrder")
        (self.purchaseView.viewWithTag(1) as! UILabel).textColor = UIColor(hex: "#666666")
        self.purchaseView.viewWithTag(2)?.isHidden = true
        (self.cancelView.viewWithTag(1) as! UILabel).textColor = .black
        self.cancelView.viewWithTag(2)?.isHidden = false
        self.orderStatusListView.isHidden = true
      }
      self.orderStatusCollectionView.reloadData()
      self.getOrderList(refresh: true)
    }
    .disposed(by: disposeBag)
  }

  func getOrderList(refresh: Bool) {
    if refresh {
      start = 0
    }

    let param = GetOrderListReqeust(start: start, perPage: 20, status: try? selectedOrderStatus.value())
    APIService.shared.orderAPI.rx.request(.getOrderList(param: param))
      .map(ListResponse<OrderList>.self)
      .subscribe(onSuccess: { response in
        if refresh {
          self.tableView.tableFooterView?.frame.size.height = response.data.isEmpty ? self.tableView.frame.height - 100 : 0
        }
        self.orderList = response.data
        self.tableView.reloadData()
      }, onFailure: { error in

      })
      .disposed(by: disposeBag)
  }
}

extension OrderHistoryViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return orderList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderCell
    let order = orderList[indexPath.row]
    var prevOrder: OrderList?

    if indexPath.row == 0 {
      cell.dividerView.isHidden = true
      cell.dateView.isHidden = false
    } else {
      cell.dividerView.isHidden = false
      if orderList.indices.contains(indexPath.row - 1) {
        prevOrder = orderList[indexPath.row - 1]
      }
    }

    let date = Date.dateFromISO8601String(order.createdAt)!
    let prevDate = Date.dateFromISO8601String(prevOrder?.createdAt)

    if let prevDate = prevDate {
      if date.year == prevDate.year && date.month == prevDate.month && date.day == prevDate.day {
        cell.dividerView.isHidden = true
        cell.dateView.isHidden = true
      } else {
        cell.dividerView.isHidden = false
        cell.dateView.isHidden = false
      }
    } else {
      cell.dividerView.isHidden = false
      cell.dateView.isHidden = false
    }


    if !order.reviewed && order.status == .used {
      cell.reviewView.isHidden = false
    } else {
      cell.reviewView.isHidden = true
    }

    cell.delegate = self

    cell.initWithOrderList(order)

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 160
  }
}

extension OrderHistoryViewController: OrderCellDelegate {
  func didDetailButtonTapped(_ cell: UITableViewCell) {
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    let vc = storyboard?.instantiateViewController(withIdentifier: "orderDetail") as! OrderDetailViewController
    vc.id = orderList[index].id
    navigationController?.pushViewController(vc, animated: true)
  }

  func didReviewButtonTapped(_ cell: UITableViewCell) {
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    let vc = storyboard?.instantiateViewController(withIdentifier: "editReview") as! EditReviewViewController
    vc.order = orderList[index]
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension OrderHistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return orderStatusList.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    let status = orderStatusList[indexPath.item]
    let selectedStatus = try! selectedOrderStatus.value()

    (cell.viewWithTag(1) as! UILabel).text = status?.getString() ?? "전체"
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
    selectedOrderStatus.onNext(orderStatusList[indexPath.item])
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 70, height: 30)
  }
}
