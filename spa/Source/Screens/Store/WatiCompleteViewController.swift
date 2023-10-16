//
//  WatiCompleteViewController.swift
//  Treat
//
//  Created by 이남기 on 2023/08/28.
//

import Foundation
class WatiCompleteViewController: BaseViewController{
  
  @IBOutlet weak var orderHistoryButton: UIButton!
  
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
        vc.shouldGoWaitOrderHistory = true
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: false)
      })
      .disposed(by: disposeBag)
  }
}
