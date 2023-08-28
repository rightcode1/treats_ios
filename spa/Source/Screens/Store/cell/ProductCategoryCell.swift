//
//  ProductCategoryCell.swift
//  spa
//
//  Created by 이동석 on 2023/01/04.
//

import UIKit

protocol ProductCategoryCellDelegate: AnyObject {
  func didSelectProduct(_ product: Store.Product, cell: ProductCategoryCell)
}

class ProductCategoryCell: UITableViewCell {
  @IBOutlet var tableView: UITableView!
  @IBOutlet var categoryNameLabel: UILabel!

  weak var delegate: ProductCategoryCellDelegate?

  var bedList = [Bed]()
  var selectedProductCategory: Store.ProductCategory?
  var selectedProduct: Store.Product?
  var selectedTime: Date?
  var selectedBedCount: Int?

  var productList = [Store.Product]()

  override func awakeFromNib() {
    super.awakeFromNib()

    tableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "cell")
    tableView.dataSource = self
    tableView.delegate = self
  }

  func checkAvailableProduct(_ product: Store.Product) -> Bool {
    guard let selectedTime = selectedTime, let selectedBedCount = selectedBedCount else { return false }
    var timeList = [Date]()
    for i in 1...product.time / 30 {
      timeList.append(selectedTime.addingTimeInterval(TimeInterval(60*30*(i-1))))
    }

    var availableBedCount = 0
    bedList.forEach { bed in
      var isAvailable = true

      timeList.forEach { date in
        if !(bed.schedules ?? []).contains(where: { Date.dateFromISO8601String($0.date)!.isSameTime(date) }) {
          isAvailable = false
        }
      }

      if isAvailable {
        availableBedCount += 1
      }
    }
    return availableBedCount >= selectedBedCount
  }

//  func generateAvailableTimeList(bedList: [Bed], bedCount: Int, timeCount: Int) {
//    var timeList = [Date]()
//    bedList.forEach { bed in
//
//    }
//  }
}

extension ProductCategoryCell: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return productList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductCell
    let product = productList[indexPath.row]

    cell.nameLabel.text = product.name
    cell.timeLabel.text = "\(product.time)분"
    cell.priceLabel.text = "\(product.price.formattedDecimalString())원"
    cell.contentLabel.text = product.content

    if checkAvailableProduct(product) {
      cell.unavailableBadge.isHidden = true
      cell.cardView.backgroundColor = .white
      cell.nameLabel.textColor = .black
      cell.timeLabel.textColor = .black
      cell.priceLabel.textColor = .black
      cell.contentLabel.textColor = .black
    } else {
      cell.unavailableBadge.isHidden = false
      cell.cardView.backgroundColor = UIColor(hex: "#f6f6f6")
      cell.nameLabel.textColor = UIColor(hex: "#c6c6c6")
      cell.timeLabel.textColor = UIColor(hex: "#c6c6c6")
      cell.priceLabel.textColor = UIColor(hex: "#c6c6c6")
      cell.contentLabel.textColor = UIColor(hex: "#c6c6c6")
    }

    cell.cardView.borderColor = selectedProduct?.id == product.id ? .black : UIColor(hex: "f6f6f6")

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.didSelectProduct(productList[indexPath.row], cell: self)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 115
  }
}
