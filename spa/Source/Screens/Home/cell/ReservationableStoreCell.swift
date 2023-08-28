//
//  ReservationableStoreCell.swift
//  spa
//
//  Created by 이동석 on 2022/11/30.
//

import UIKit
import RxSwift


class ReservationableStoreCell: UICollectionViewCell {
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var companyNameLabel: UILabel!
  @IBOutlet var thumbnailView: UIImageView!
  @IBOutlet var averageLabel: UILabel!
  @IBOutlet var addressLabel: UILabel!
  @IBOutlet var moreButton: UIView!
  
  var timeList = [Date]()
  var id: Int = 0
  var Home: HomeViewController?
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    collectionView.register(UINib(nibName: "StoreTimeCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    collectionView.dataSource = self
    collectionView.delegate = self
  }
  func initWithStoreList(_ store: Store) {
    if let url = URL(string: store.titleImage) {
      thumbnailView.kf.setImage(with: url)
    } else {
      thumbnailView.image = nil
    }
    companyNameLabel.text = store.name
    averageLabel.text =  String(format: "%.1f", store.rating)
    addressLabel.text = "\(store.address.split(separator: " ")[0]) \(store.address.split(separator: " ")[1])" 
  }
  @IBAction func tapDetail(_ sender: Any) {
    let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
    vc.storeId = id
    Home?.navigationController?.pushViewController(vc, animated: true)
  }
  @IBAction func tapAll(_ sender: Any) {
    if let nav = Home?.tabBarController?.viewControllers?[1] as? UINavigationController {
      if let vc = nav.viewControllers.first as? StoreViewController {
        vc.reservationable = "true"
        Home?.tabBarController?.selectedIndex = 1
      }
    }
  }
}
extension ReservationableStoreCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return timeList.count > 3 ? 3 : timeList.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    if timeList.count > 3 && indexPath.row > 1{
      (cell.viewWithTag(2) as! UIImageView).isHidden = false
    }else{
      (cell.viewWithTag(1) as! UILabel).text = timeList[indexPath.row].ahhmm
      (cell.viewWithTag(2) as! UIImageView).isHidden = true
    }
    return cell
  }
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
    vc.storeId = id
    Home?.navigationController?.pushViewController(vc, animated: true)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    if timeList.count > 3 && indexPath.row > 1{
      return CGSize(width: 62, height: 30)
    }else{
      return CGSize(width: 80, height: 30)
    }
  }
}
