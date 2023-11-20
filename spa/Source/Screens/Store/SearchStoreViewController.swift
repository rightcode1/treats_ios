//
//  SearchStoreViewController.swift
//  spa
//
//  Created by 이남기 on 2023/06/15.
//

import Foundation
import RxSwift

class SearchStoreViewController: BaseViewController{
  @IBOutlet weak var tableView: UITableView!

  @IBOutlet var noStroe: UIImageView!
  @IBOutlet weak var recommandCollectionView: UICollectionView!
  @IBOutlet weak var bestCollectionView: UICollectionView!
  @IBOutlet weak var searchCollectionView: UICollectionView!
  @IBOutlet weak var searchCollectionViewHeight: NSLayoutConstraint!
  @IBOutlet weak var viewHeight: NSLayoutConstraint!
  
  @IBOutlet weak var storeInfoView: UIView!
  @IBOutlet weak var selectedDateLabel: UILabel!
  @IBOutlet weak var selectedBedCountLabel: UILabel!
  @IBOutlet weak var selectedTimeLabel: UILabel!

  @IBOutlet weak var parentCategoryView: UIView!
  @IBOutlet weak var parentCategoryLabel: UILabel!

  @IBOutlet weak var childCategoryView: UIView!
  @IBOutlet weak var childCategoryLabel: UILabel!

  @IBOutlet var searchButton: UIImageView!
  @IBOutlet var searchTextField: UITextField!
  
  @IBOutlet var reservationableButton: UIView!
  @IBOutlet var reservationableButtonLabel: UILabel!

  var categoryList = [Category]()
  var selectedParentCategory: Category?
  var selectedChildCategory: Category?

  var storeList = [Store]()
  var bestList = [storList]()
  var recommandList = [String]()
  var searhStringList = [String]()

  var selectedDate = Date()
  var selectedBedCount = 1
  var selectedTime = Date()

  var selectedHomeParentCategory: Category?

  var reservationable = "false"

  override func viewDidLoad() {
    super.viewDidLoad()
    
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
  override func viewWillAppear(_ animated: Bool) {
    searchTextField.delegate = self
    tableView.delegate = self
    tableView.dataSource = self
    recommandCollectionView.delegate = self
    recommandCollectionView.dataSource = self
    bestCollectionView.delegate = self
    bestCollectionView.dataSource = self
    searhStringList = DataHelperTool.searchKeywordHistoryList ?? []
    searchCollectionView.delegate = self
    searchCollectionView.dataSource = self
    getSearchDetail()
  }
  func bindInput() {
    searchButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if self.searchTextField.text == ""{
          self.callOkCancelMSGDialog(message: "검색어를 입력해주세요.") {
          }
          return
        }
        self.searhStringList = DataHelperTool.searchKeywordHistoryList ?? []
        self.searhStringList.append(self.searchTextField.text ?? "")
        DataHelper.set(self.searhStringList, forKey: .searchKeywordHistoryList)
        self.getStoreList()
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
      reservationable: reservationable,
      search: searchTextField.text ?? ""
    )
    APIService.shared.storeAPI.rx.request(.getStoreList(param: param))
      .filterSuccessfulStatusCodes()
      .map(GetStoreListResponse.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.tableView.isHidden = false
        if response.data.isEmpty{
          self.noStroe.isHidden = false
          return
        }
        self.noStroe.isHidden = true
        self.storeList = response.data
        self.tableView.reloadData()
      }, onFailure: { error in
        self.dismissHUD()
        log.error(error)
      })
      .disposed(by: disposeBag)
  }

  func getSearchDetail() {
    APIService.shared.homeAPI.rx.request(.getSearchInfo)
      .filterSuccessfulStatusCodes()
      .map(searchInfo.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.recommandList = response.searchList
        self.bestList = response.storeList
        self.recommandCollectionView.reloadData()
        self.bestCollectionView.reloadData()
      }, onFailure: { error in
        self.dismissHUD()
        log.error(error)
      })
      .disposed(by: disposeBag)
  }
  
  @objc
  func deleteSearchButton(_ sender: UIButton) {
    guard let cell = sender.superview?.superview as? UICollectionViewCell else {
        return
    }
    
    guard let indexPath = searchCollectionView.indexPath(for: cell) else {
        return
    }
    searhStringList.remove(at: indexPath.row)
    DataHelper.set(searhStringList, forKey: .searchKeywordHistoryList)
    searchCollectionView.reloadData()
  }
  
}

extension SearchStoreViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return storeList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StoreCell
    let store = storeList[indexPath.row]
    var timeList = store.schedules?.filter({ $0.bedCount >= selectedBedCount }).map({ Date.dateFromString("\(selectedDate.yyyyMMdd) \($0.time):00", dateFormat: .yyyyMMddHHmmss, timeZone: TimeZone(identifier: "GMT")) }).sorted(by: { $0 < $1 }) ?? []//.getTimeList(bedCount: selectedBedCount)
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
    vc.selectedTime = selectedTime
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

extension SearchStoreViewController: SelectCategoryDelegate {
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
    if searchTextField.text != ""{
      getStoreList()
    }
  }
}

extension SearchStoreViewController: SelectStoreInfoDelegate {
  func didApplyFilter(date: Date, bedCount: Int, time: Date, isCouple: Bool?) {
    selectedDate = date
    selectedBedCount = bedCount
    selectedTime = time

    selectedDateLabel.text = selectedDate.yyyyMMddKR
    selectedBedCountLabel.text = "\(selectedBedCount)명"
    selectedTimeLabel.text = selectedTime.ahmm
    getStoreList()
  }
}

extension SearchStoreViewController: StoreCellDelegate {
  func didSelect(_ cell: StoreCell,_ date: Date) {
    print("!!!")
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    let store = storeList[index]
    let vc = storyboard?.instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
    vc.storeId = store.id
    vc.selectedDate = selectedDate
    vc.selectedTime = date
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

extension SearchStoreViewController: UnlikeStorePopupDelegate {
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

extension SearchStoreViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView.isEqual(recommandCollectionView){
      return recommandList.count
    }else if collectionView.isEqual(bestCollectionView){
      return bestList.count
    }else{
      return searhStringList.count
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView.isEqual(recommandCollectionView){
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommandCell", for: indexPath)
      let textLabel = cell.viewWithTag(1) as! UILabel
      textLabel.text = recommandList[indexPath.row]
      return cell
    }else if collectionView.isEqual(bestCollectionView){
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bestCell", for: indexPath)
      let numLabel = cell.viewWithTag(1) as! UILabel
      let storeLabel = cell.viewWithTag(2) as! UILabel
      numLabel.text = "\(indexPath.row + 1)"
      if indexPath.row > 2 {
        numLabel.textColor = .black
      }else{
        numLabel.textColor = #colorLiteral(red: 0.5217606425, green: 0.8154509068, blue: 0.7899609804, alpha: 1)
      }
      storeLabel.text = bestList[indexPath.row].name
      return cell
    }else{
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      let textLabel = cell.viewWithTag(1) as! UILabel
      textLabel.text = searhStringList[indexPath.row]
      (cell.viewWithTag(2) as! UIButton).addTarget(self, action: #selector(deleteSearchButton(_:)), for: .touchUpInside)
      return cell
    }

  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView.isEqual(recommandCollectionView){
      searchTextField.text = recommandList[indexPath.row]
      getStoreList()
    }else if collectionView.isEqual(bestCollectionView){
      let vc = storyboard?.instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
      vc.storeId = bestList[indexPath.row].storeId
      navigationController?.pushViewController(vc, animated: true)
    }else{
      searchTextField.text = searhStringList[indexPath.row]
      getStoreList()
    }
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView.isEqual(recommandCollectionView){
      return CGSize(width: 0, height: 30)
    }else if collectionView.isEqual(bestCollectionView){
      return CGSize(width: collectionView.bounds.width , height: 18)
    }else{
      searchCollectionViewHeight.constant = CGFloat(30 * searhStringList.count)
      viewHeight.constant = 64 + searchCollectionViewHeight.constant
      return CGSize(width: collectionView.bounds.width, height: 18)
    }
  }
}
extension SearchStoreViewController: UITextFieldDelegate {
  // 클래스 내용
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // 엔터 버튼을 눌렀을 때 수행할 동작
    if self.searchTextField.text == ""{
      self.callOkCancelMSGDialog(message: "검색어를 입력해주세요.") {
      }
      
    }else{
      self.searhStringList = DataHelperTool.searchKeywordHistoryList ?? []
      self.searhStringList.append(self.searchTextField.text ?? "")
      DataHelper.set(self.searhStringList, forKey: .searchKeywordHistoryList)
      self.getStoreList()
    }
      textField.resignFirstResponder() // 키보드를 숨기기 위해 텍스트 필드로의 첫 응답자(responder) 상태를 해제합니다.
      return true
  }
}

