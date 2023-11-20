//
//  SelectOptionViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/15.
//

import UIKit

protocol SelectOptionDelegate: AnyObject {
  func didSelectOptions(_ selectedOptionList: [(Store.Option, Int)])
}

class SelectOptionViewController: BaseViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var sheetView: UIView!
  @IBOutlet weak var noOptionButton: UIImageView!
  @IBOutlet weak var optionHeight: NSLayoutConstraint!
  @IBOutlet weak var recyclerViewHeight: NSLayoutConstraint!
  
  weak var delegate: SelectOptionDelegate?

  var optionList = [(Store.Option, Int)]()

  override func viewDidLoad() {
    super.viewDidLoad()
    print(optionList.count)
    print(optionList.count * 41)
    recyclerViewHeight.constant = CGFloat((optionList.count + 1) * 41)
    print(recyclerViewHeight.constant)
    optionHeight.constant = CGFloat(160 + recyclerViewHeight.constant)
    sheetView.layer.cornerRadius = 10
    sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

    nextButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.dismiss(animated: false) {
          self.delegate?.didSelectOptions(self.optionList)
        }
      })
      .disposed(by: disposeBag)
    
    noOptionButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if self.noOptionButton.image != UIImage(named: "iconCheckOn"){
          self.optionList = self.optionList.map { ($0.0, 0) }
          self.tableView.reloadData()
          self.noOptionButton.image = UIImage(named: "iconCheckOn")
        }else{
          self.noOptionButton.image = UIImage(named: "iconCheckOff")
        }
      })
      .disposed(by: disposeBag)
  }
}

extension SelectOptionViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return optionList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StoreOptionCell
    let option = optionList[indexPath.row].0
    let quantity = optionList[indexPath.row].1

    cell.delegate = self
    cell.nameLabel.text = option.name
    cell.quantityLabel.text = quantity.formattedDecimalString()
//    cell.amountLabel.isHidden = quantity == 0
    cell.amountLabel.text = option.price == 0 ? "" : "\(option.price.formattedDecimalString())원"

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 41
  }
}

extension SelectOptionViewController: StoreOptionCellDelegate {
  func didPlusButtonTapped(_ cell: StoreOptionCell) {
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    optionList[index].1 += 1
    self.noOptionButton.image = UIImage(named: "iconCheckOff")
    tableView.reloadData()
  }

  func didMinusButtonTapped(_ cell: StoreOptionCell) {
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    if optionList[index].1 > 0 {
      optionList[index].1 -= 1
      self.noOptionButton.image = UIImage(named: "iconCheckOff")
      tableView.reloadData()
    }
  }
}
