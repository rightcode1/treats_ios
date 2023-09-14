//
//  LikeViewController.swift
//  spa
//
//  Created by 이동석 on 2023/01/09.
//

import UIKit

class LikeViewController: BaseViewController {
  @IBOutlet var tableView: UITableView!

  var storeList = [Store]()

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UINib(nibName: "StoreCell", bundle: nil), forCellReuseIdentifier: "cell")
  }

  override func viewWillAppear(_ animated: Bool) {
    self.tableView.tableFooterView?.frame.size.height = 0
    getLikedStoreList()
  }

  func getLikedStoreList() {
    let param = GetStoreListRequest(liked: true, start: 0, perPage: 50)
    APIService.shared.storeAPI.rx.request(.getStoreList(param: param))
      .filterSuccessfulStatusAndRedirectCodes()
      .map(ListResponse<Store>.self)
      .subscribe(onSuccess: { response in
        self.storeList = response.data
        if self.storeList.isEmpty {
          self.tableView.tableFooterView?.frame.size.height = self.tableView.frame.height
        }else{
          self.tableView.tableFooterView?.frame.size.height = 0
        }
        self.tableView.reloadData()
      }, onFailure: { error in

      })
      .disposed(by: disposeBag)
  }
}

extension LikeViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return storeList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StoreCell

    cell.delegate = self
    cell.initWithStore(storeList[indexPath.row])

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
    vc.storeId = storeList[indexPath.row].id
//    vc.selectedDate = selectedDate
//    vc.selectedTime = selectedTime
//    vc.selectedBedCount = selectedBedCount
    navigationController?.pushViewController(vc, animated: true)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 140
  }
}

extension LikeViewController: StoreCellDelegate {
  func didSelect(_ cell: StoreCell,_ date: Date) {  }
  
  func didLikeButtonTapped(_ cell: StoreCell) {
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    let store = storeList[index]
    if store.liked ?? false {
      let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "unlikeStorePopup") as! UnlikeStorePopupViewController
      vc.storeId = storeList[index].id
      vc.delegate = self
      self.present(vc, animated: false)
    } else {
      storeList[index].liked = true
      APIService.shared.storeAPI.rx.request(.likeStore(id: store.id))
        .subscribe()
        .disposed(by: disposeBag)
      tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
  }
}

extension LikeViewController: UnlikeStorePopupDelegate {
  func didUnlikeButtonTapped(storeId: Int) {
    if let index = storeList.firstIndex(where: { $0.id == storeId }) {
      storeList[index].liked = false
      APIService.shared.storeAPI.rx.request(.unlikeStore(id: storeId))
        .subscribe()
        .disposed(by: disposeBag)
      tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
  }
}
