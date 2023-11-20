//
//  StoreViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/01.
//

import UIKit
import RxSwift


class StoreViewController: BaseViewController , UITabBarControllerDelegate {
  @IBOutlet weak var tableView: UITableView!

  @IBOutlet var locationView: UIView!
  @IBOutlet var currentLocationLabel: UILabel!

  @IBOutlet weak var storeInfoView: UIView!
  @IBOutlet weak var selectedDateLabel: UILabel!
  @IBOutlet weak var selectedBedCountLabel: UILabel!
  @IBOutlet weak var selectedTimeLabel: UILabel!

  @IBOutlet weak var parentCategoryView: UIView!
  @IBOutlet weak var parentCategoryLabel: UILabel!

  @IBOutlet weak var childCategoryView: UIView!
  @IBOutlet weak var childCategoryLabel: UILabel!

  @IBOutlet var reservationableButton: UIView!
  @IBOutlet var reservationableButtonLabel: UILabel!
  @IBOutlet var searchButton: UIImageView!
  
  var categoryList = [Category]()
  var selectedParentCategory: Category?
  var selectedChildCategory: Category?

  var storeList = [Store]()

  var selectedDate = Date()
  var selectedBedCount = 1
  var selectedTime = Date()
  var selectedCoupleRoom : Bool?

  var selectedHomeParentCategory: Category?

  var reservationable : String = "false"

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.tabBarController?.delegate = self
    
    showHUD()

    tableView.register(UINib(nibName: "StoreCell", bundle: nil), forCellReuseIdentifier: "cell")

    if Date().minute < 30 {
      selectedTime = DateComponents(calendar: Calendar.current, year: Date().year, month: Date().month, day: Date().day, hour: Date().hour, minute: 30).date ?? Date()
    } else {
      selectedTime = DateComponents(calendar: Calendar.current, year: Date().year, month: Date().month, day: Date().day, hour: Date().hour+1, minute: 0).date ?? Date()
    }

    selectedDateLabel.text = selectedDate.yyyyMMddKR
    selectedBedCountLabel.text = "\(selectedBedCount)명"
    selectedTimeLabel.text = selectedTime.ahmm

    childCategoryView.isHidden = true
    bindInput()

    getCategoryList()
  }
  
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    if tabBarController.selectedIndex == 1{
      selectedDate = Date()
      selectedBedCount = 1
      selectedTime = Date()
      if Date().minute < 30 {
        selectedTime = DateComponents(calendar: Calendar.current, year: Date().year, month: Date().month, day: Date().day, hour: Date().hour, minute: 30).date ?? Date()
      } else {
        selectedTime = DateComponents(calendar: Calendar.current, year: Date().year, month: Date().month, day: Date().day, hour: Date().hour+1, minute: 0).date ?? Date()
      }
      
      selectedDateLabel.text = selectedDate.yyyyMMddKR
      selectedBedCountLabel.text = "\(selectedBedCount)명"
      selectedTimeLabel.text = selectedTime.ahmm
      selectedParentCategory = nil
      selectedChildCategory = nil
      childCategoryView.isHidden = true
      parentCategoryLabel.text = "전체"
      getStoreList()
    }
//    
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let selectedHomeParentCategory = selectedHomeParentCategory {
      storeList = []
      tableView.reloadData()

      
      selectedParentCategory = selectedHomeParentCategory
      selectedChildCategory = nil
      parentCategoryLabel.text = selectedHomeParentCategory.name
      childCategoryView.isHidden = (selectedHomeParentCategory.children ?? []).isEmpty
      childCategoryLabel.text = "전체"
      self.selectedHomeParentCategory = nil
    }

    currentLocationLabel.text = LocationManager.shared.currentAddress

    getStoreList()
  }

  func bindInput() {
    searchButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "search") as! SearchStoreViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    locationView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "selectLocation") as! SelectLocationViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    storeInfoView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "selectStoreInfo") as! SelectStoreInfoViewController
        vc.delegate = self
        vc.selectedDate = self.selectedDate
        vc.selectedBedCount = self.selectedBedCount
        vc.selectedTime = self.selectedTime
        self.present(vc, animated: true)
      })
      .disposed(by: disposeBag)

    parentCategoryView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "selectCategory") as! SelectCategoryViewController
        vc.delegate = self
        vc.categoryList = self.categoryList
        vc.selectedParentCategory = self.selectedParentCategory
        vc.isParent = true
        self.present(vc, animated: false)
      })
      .disposed(by: disposeBag)

    childCategoryView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "selectCategory") as! SelectCategoryViewController
        vc.delegate = self
        vc.categoryList = self.categoryList
        vc.selectedParentCategory = self.selectedParentCategory
        vc.selectedChildCategory = self.selectedChildCategory
        vc.isParent = false
        self.present(vc, animated: false)
      })
      .disposed(by: disposeBag)

    reservationableButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if self.reservationable == "false" {
          self.reservationableButton.borderColor = .black
          self.reservationableButtonLabel.textColor = .black
          self.reservationable = "true"
        } else {
          self.reservationableButton.borderColor = UIColor(hex: "#E3E6EC")
          self.reservationableButtonLabel.textColor = UIColor(hex: "#9298aa")
          self.reservationable = "false"
        }
        self.getStoreList()
      })
      .disposed(by: disposeBag)
  }

  func getCategoryList() {
    APIService.shared.storeAPI.rx.request(.getCategoryList)
      .map(GetCategoryListResponse.self)
      .subscribe(onSuccess: { response in
        self.categoryList = response.data
      }, onFailure: { error in
        log.error(error)
      })
      .disposed(by: disposeBag)
  }

  func getStoreList() {
    let param = GetStoreListRequest(
      date: selectedDate.yyyyMMdd,
      latitude: LocationManager.shared.currentLocation?.latitude,
      longitude: LocationManager.shared.currentLocation?.longitude,
      categoryId: selectedChildCategory?.id ?? selectedParentCategory?.id,
      reservationable: reservationable
    )
    APIService.shared.storeAPI.rx.request(.getStoreList(param: param))
      .filterSuccessfulStatusCodes()
      .map(GetStoreListResponse.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.storeList = response.data
        self.tableView.reloadData()
      }, onFailure: { error in
        self.dismissHUD()
        log.error(error)
      })
      .disposed(by: disposeBag)
  }
}

extension StoreViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return storeList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StoreCell
    let store = storeList[indexPath.row]
    var timeList = store.schedules?.filter({ $0.bedCount >= selectedBedCount }).map({ Date.dateFromString("\(selectedDate.yyyyMMdd) \($0.time):00", dateFormat: .yyyyMMddHHmmss, timeZone: TimeZone(identifier: "GMT")) }).sorted(by: { $0 < $1 }) ?? []
    //.getTimeList(bedCount: selectedBedCount)
    timeList = timeList.filter({$0 >= selectedTime})
    cell.collectionView.isHidden = timeList.isEmpty
    cell.timeList = timeList
    cell.selectedDate = selectedDate
    cell.collectionView.reloadData()
    cell.delegate = self
    cell.initWithStore(storeList[indexPath.row])

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
    vc.storeId = storeList[indexPath.row].id
    vc.selectedDate = selectedDate
//    vc.selectedTime = selectedTime
    vc.selectedCoupleRoom = selectedCoupleRoom
    vc.selectedBedCount = selectedBedCount
    navigationController?.pushViewController(vc, animated: true)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 140
  }
//
//  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    let store = storeList[indexPath.row]
//    var timeList = store.schedules?.filter({ $0.bedCount >= selectedBedCount }).map({ Date.dateFromString("\(selectedDate.yyyyMMdd) \($0.time):00", dateFormat: .yyyyMMddHHmmss, timeZone: TimeZone(identifier: "KST")) }).sorted(by: { $0 < $1 }) ?? []
//    timeList = timeList.filter({$0 >= Date()})
//    if let time = timeList.filter({ $0 > Date() }).first {
//      if let index = timeList.firstIndex(where: { $0 == time }) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//          (cell as! StoreCell).collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .left, animated: false)
//        }
//      }
//    }
//  }
}

extension StoreViewController: SelectCategoryDelegate {
  func didSelectCategory(parentCategory: Category?, childCategory: Category?, isParent: Bool) {
    selectedParentCategory = parentCategory
    selectedChildCategory = childCategory
    if isParent {
      selectedChildCategory = nil
      parentCategoryLabel.text = parentCategory?.name ?? "전체"
      childCategoryView.isHidden = (parentCategory?.children ?? []).isEmpty
      childCategoryLabel.text = "전체"
    } else {
      childCategoryLabel.text = childCategory?.name ?? "전체"
    }

    getStoreList()
  }
}

extension StoreViewController: SelectStoreInfoDelegate {
  
  func didApplyFilter(date: Date, bedCount: Int, time: Date, isCouple: Bool?) {
    selectedDate = date
    selectedBedCount = bedCount
    selectedTime = time
    selectedCoupleRoom = isCouple
    selectedDateLabel.text = selectedDate.yyyyMMddKR
    selectedBedCountLabel.text = "\(selectedBedCount)명"
    selectedTimeLabel.text = selectedTime.ahmm
  }
}

extension StoreViewController: StoreCellDelegate {
  func didSelect(_ cell: StoreCell, _ date: Date) {
    print("!!!")
    print(date)
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    let store = storeList[index]
    let vc = storyboard?.instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
    vc.storeId = store.id
    vc.selectedDate = selectedDate
    vc.selectedTime = date
    vc.selectedCoupleRoom = selectedCoupleRoom
    vc.selectedBedCount = selectedBedCount
    navigationController?.pushViewController(vc, animated: true)
  }
  
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

extension StoreViewController: UnlikeStorePopupDelegate {
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
