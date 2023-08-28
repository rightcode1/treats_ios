//
//  PaymentCompleteViewController.swift
//  spa
//
//  Created by 이동석 on 2022/12/06.
//

import UIKit

class PaymentCompleteViewController: BaseViewController {
  @IBOutlet weak var orderHistoryButton: UIButton!

  var orderSheet: OrderSheet!
  var amount = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()

//    storeImageView.kf.setImage(with: URL(string: orderSheet.store.titleImage)!)
//    storeAddressLabel.text = orderSheet.store.address
//    storeNameLabel.text = orderSheet.store.name
//    productNameLabel.text = orderSheet.product.name
//    amountLabel.text = "\(amount.formattedDecimalString())원"

    orderHistoryButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = (self.tabBarController?.viewControllers?.first as! UINavigationController).viewControllers.first as! HomeViewController
        vc.shouldGoOrderHistory = true
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: false)
      })
      .disposed(by: disposeBag)
  }
}
