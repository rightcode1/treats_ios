//
//  StoreCell.swift
//  spa
//
//  Created by 이동석 on 2022/11/15.
//

import UIKit

protocol StoreCellDelegate: AnyObject {
  func didLikeButtonTapped(_ cell: StoreCell)
  func didSelect(_ cell: StoreCell,_ date: Date)
}

class StoreCell: UITableViewCell {
  @IBOutlet weak var titleImageView: UIImageView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var introLabel: UILabel!
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet var distanceLabel: UILabel!
  @IBOutlet var ratingLabel: UILabel!
  @IBOutlet var collectionView: UICollectionView!

  var timeList = [Date]()
  var selectedDate: Date?

  weak var delegate: StoreCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    collectionView.register(UINib(nibName: "StoreTimeCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    collectionView.dataSource = self
    collectionView.delegate = self
  }

  func initWithStore(_ store: Store) {
    if let url = URL(string: store.titleImage) {
      titleImageView.kf.setImage(with: url)
    } else {
      titleImageView.image = nil
    }

    addressLabel.text = store.address
    nameLabel.text = store.name
    introLabel.text = store.summary

    likeButton.setImage(store.liked ?? false ? UIImage(named: "iconBookmarkOn") : UIImage(named: "iconBookmarkOff"), for: .normal)
    if let distance = store.distance {
      self.distanceLabel.text = String(format: "%.1f", distance) + "km"
    } else {
      self.distanceLabel.text = ""
    }

    ratingLabel.text = String(format: "%.1f", store.rating)
  }

  @IBAction func likeButtonTapped(_ sender: Any) {
    delegate?.didLikeButtonTapped(self)
  }
}

extension StoreCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return timeList.count > 4 ? 4 : timeList.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    if timeList.count > 4 && indexPath.row > 2{
      (cell.viewWithTag(2) as! UIImageView).isHidden = false
    }else{
      (cell.viewWithTag(1) as! UILabel).text = timeList[indexPath.row].ahhmm
      (cell.viewWithTag(2) as! UIImageView).isHidden = true
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    var selectedTime = Date()
    if indexPath.row == 3{
      if Date().minute < 30 {
        selectedTime = DateComponents(calendar: Calendar.current, year: Date().year, month: Date().month, day: Date().day, hour: Date().hour, minute: 30).date ?? Date()
      } else {
        selectedTime = DateComponents(calendar: Calendar.current, year: Date().year, month: Date().month, day: Date().day, hour: Date().hour+1, minute: 0).date ?? Date()
      }
    }else{
      selectedTime = timeList[indexPath.row]
    }
    delegate?.didSelect(self, selectedTime)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    if timeList.count > 4 && indexPath.row > 2{
      return CGSize(width: 62, height: 30)
    }else{
      return CGSize(width: 80, height: 30)
    }
  }
  
}
