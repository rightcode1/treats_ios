//
//  StoreADViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/30.
//

import UIKit
import Kingfisher

class StoreADViewController: BaseViewController, StoreCellDelegate, UnlikeStorePopupDelegate {
  func didUnlikeButtonTapped(storeId: Int) {
    if let index = advertisement.stores?.firstIndex(where: { $0.id == storeId }) {
      advertisement.stores?[index].liked = false
      APIService.shared.storeAPI.rx.request(.unlikeStore(id: storeId))
        .subscribe()
        .disposed(by: disposeBag)
      tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
  }
  
  func didLikeButtonTapped(_ cell: StoreCell) {
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    let store = advertisement.stores?[index]
    if store?.liked ?? false {
      let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "unlikeStorePopup") as! UnlikeStorePopupViewController
      vc.storeId = store?.id
      vc.delegate = self
      self.present(vc, animated: false)
    } else {
      advertisement.stores?[index].liked = true
      APIService.shared.storeAPI.rx.request(.likeStore(id: store?.id ?? 0))
        .subscribe()
        .disposed(by: disposeBag)
      tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
  }
  
  func didSelect(_ cell: StoreCell,_ date: Date) {
    print("!!!")
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    let store = advertisement.stores?[index]
    let vc = storyboard?.instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
    vc.storeId = store?.id
    vc.selectedDate = selectedDate
    vc.selectedTime = date
    vc.selectedBedCount = selectedBedCount
    navigationController?.pushViewController(vc, animated: true)
  }
  

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var goStoreButton: UIButton!
  @IBOutlet var goStoreView: UIView!
  @IBOutlet weak var storeTitleLabel: UILabel!
  
  var selectedDate = Date()
  var selectedBedCount = 1
  var selectedTime = Date()
  
  @IBOutlet weak var titleLabel: UILabel!
  var advertisement: Advertisement!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.titleLabel.text = advertisement.name
    self.storeTitleLabel.text = advertisement.storeTitle
    
    tableView.register(UINib(nibName: "StoreCell", bundle: nil), forCellReuseIdentifier: "cell")

    if (self.advertisement.stores ?? []).count > 1 {
      self.goStoreView.isHidden = true
    }else{
      self.goStoreView.isHidden = false
    }
    if let url = URL(string: advertisement.detailImage ?? "") {
      KingfisherManager.shared.retrieveImage(with: url) { result in
        switch result {
        case .success(let image):
          self.imageView.image = image.image
          let image = image.image.resizeToWidth(newWidth: UIScreen.main.bounds.width)
          self.tableView.tableHeaderView?.frame.size.height = image.size.height
          self.tableView.reloadData()
        case .failure(let error):
          log.error(error)
          break
        }
      }
    }

    goStoreButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if let store = (self.advertisement.stores ?? []).first {
          let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
          vc.storeId = store.id
          //    vc.selectedDate = selectedDate
          //    vc.selectedTime = selectedTime
          //    vc.selectedBedCount = selectedBedCount
          self.navigationController?.pushViewController(vc, animated: true)
        }
      })
      .disposed(by: disposeBag)
  }
}

extension StoreADViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return advertisement.stores?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StoreCell
    let store = advertisement.stores?[indexPath.row]
    var timeList = store?.schedules?.filter({ $0.bedCount >= selectedBedCount }).map({ Date.dateFromString("\(selectedDate.yyyyMMdd) \($0.time):00", dateFormat: .yyyyMMddHHmmss, timeZone: TimeZone(identifier: "GMT")) }).sorted(by: { $0 < $1 }) ?? []//.getTimeList(bedCount: selectedBedCount)
      timeList = timeList.filter({$0 >= Date()})
      cell.collectionView.isHidden = timeList.isEmpty
      cell.timeList = timeList
      cell.selectedDate = Date()
      cell.collectionView.reloadData()
      cell.delegate = self
      cell.initWithStore(store!)
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let store = (advertisement.stores ?? [])[indexPath.row]
    let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
    vc.storeId = store.id
    //    vc.selectedDate = selectedDate
    //    vc.selectedTime = selectedTime
    //    vc.selectedBedCount = selectedBedCount
    navigationController?.pushViewController(vc, animated: true)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension

  }
}
