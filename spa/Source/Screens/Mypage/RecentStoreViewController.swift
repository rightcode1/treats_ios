//
//  RecentStoreViewController.swift
//  spa
//
//  Created by 이동석 on 2023/01/09.
//

import UIKit

class RecentStoreViewController: BaseViewController {
  @IBOutlet var tableView: UITableView!
  @IBOutlet var deleteAllButton: UIButton!

  var storeList = [Store]()

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView?.frame.size.height = 0

    deleteAllButton.rx.tap
      .bind(onNext: { [weak self] in
        DataHelper<Any>.remove(forKey: .recentStores)
        self?.getLikedStoreList()
      })
      .disposed(by: disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    getLikedStoreList()
  }

  func getLikedStoreList() {
    storeList = DataHelper<Any>.getRecentStores()
    tableView.reloadData()
  }
}

extension RecentStoreViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    tableView.tableFooterView?.frame.size.height = storeList.isEmpty ? tableView.frame.height - 100 : 0
    return storeList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecentStoreCell

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

extension RecentStoreViewController: UnlikeStorePopupDelegate {
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

extension RecentStoreViewController: RecentStoreCellDelegate {
  func didDeleteButtonTapped(_ cell: RecentStoreCell) {
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    DataHelper<Any>.deleteRecentStore(storeId: storeList[index].id)
    getLikedStoreList()
  }
}
