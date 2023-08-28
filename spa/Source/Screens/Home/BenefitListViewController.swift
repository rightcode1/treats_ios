//
//  BenefitListViewController.swift
//  spa
//
//  Created by 이남기 on 2023/08/18.
//

import Foundation

class BenefitListViewController: BaseViewController{
  
  @IBOutlet var mainTableView: UITableView!
  
  var benefitList: [Advertisement] = []{
    didSet{
      mainTableView.reloadData()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    getList()
  }
  func getList() {
    mainTableView.delegate = self
    mainTableView.dataSource = self
    APIService.shared.homeAPI.rx.request(.getAdvertisements)
      .map(AdvertisementResponse.self)
      .subscribe(onSuccess: { response in
        self.benefitList = response.data
      }, onFailure: { error in
        log.error(error)
      })
      .disposed(by: disposeBag)
  }
}

extension BenefitListViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return benefitList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let benefit = benefitList[indexPath.row]
    if let url = URL(string: benefit.thumbnail) {
      (cell.viewWithTag(1) as! UIImageView).kf.setImage(with: url)
    } else {
      (cell.viewWithTag(1) as! UIImageView).image = nil
    }

    (cell.viewWithTag(2) as! UILabel).text = benefit.name
    (cell.viewWithTag(3) as! UILabel).text = benefit.description
    (cell.viewWithTag(4) as! UILabel).text = benefit.price
    (cell.viewWithTag(5) as! UILabel).text = benefit.percent
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let banner = benefitList[indexPath.row]
      switch banner.division {
      case .url:
        let vc = storyboard?.instantiateViewController(withIdentifier: "urlAD") as! UrlADViewController
        vc.advertisement = banner
        navigationController?.pushViewController(vc, animated: true)
      case .image:
        let vc = storyboard?.instantiateViewController(withIdentifier: "imageAD") as! ImageADViewController
        vc.advertisement = banner
        navigationController?.pushViewController(vc, animated: true)
      case .store:
        let vc = storyboard?.instantiateViewController(withIdentifier: "storeAD") as! StoreADViewController
        vc.advertisement = banner
        navigationController?.pushViewController(vc, animated: true)
      }
    
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 141

  }
}
