//
//  HomeViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/01.
//

import UIKit
import CoreLocation
import FSPagerView
import RxSwift

class HomeViewController: BaseViewController {
  @IBOutlet var bannerPagerView: FSPagerView!

  @IBOutlet weak var bannerPageLabel: UILabel!
  @IBOutlet weak var editorPickCollectionView: UICollectionView!
  @IBOutlet weak var editorPickerPageControl: FSPageControl!
  @IBOutlet weak var reservationableStoreCollectionView: UICollectionView!
  @IBOutlet var reservationableStoreButton: UIButton!

  @IBOutlet weak var benefitCollectionView: UICollectionView!
  @IBOutlet var benefitStoreButton: UIButton!
  
  @IBOutlet var allAroundStoreButton: UIButton!
  @IBOutlet weak var aroundMenuCollectionView: UICollectionView!
  @IBOutlet weak var aroundStoreTableView: UITableView!
  @IBOutlet weak var spotCollectionView: UICollectionView!

  @IBOutlet var allPlaceButton: UIButton!
  @IBOutlet var categoryViewList: [UIView]!
  @IBOutlet var searchViewButton: UIView!
  @IBOutlet var privacyButton: UILabel!
  @IBOutlet var useButton: UILabel!
  
  var bannerList = [Advertisement]()
  var magazineList = [Journal]()
  var categoryList = [Category]()
  var reservationableStoreList = [Store]()
  var benefitList = [Advertisement]()
  var aroundStoreList = [Store]()
  var placeList = [Place]()

  var aroundMenuList = ["바디스파", "페이셜스파", "호텔스파", "커플스파"]
  var selectedAroundMenuIndex = 0

  var shouldGoOrderHistory = false
  var shouldGoWaitOrderHistory = false
  var selectedDate = Date()
  var selectedBedCount = 1

  let reservationable = BehaviorSubject<Bool>(value: false)

//  var spotImageList = ["imgTempSpot1"]

  override func viewDidLoad() {
    super.viewDidLoad()

    aroundStoreTableView.register(UINib(nibName: "HomeStoreCell", bundle: nil), forCellReuseIdentifier: "homeStoreCell")
    aroundStoreTableView.register(UINib(nibName: "StoreCell", bundle: nil), forCellReuseIdentifier: "cell")

    editorPickerPageControl.setFillColor(.black, for: .selected)
    editorPickerPageControl.setFillColor(.white, for: .normal)
    editorPickerPageControl.setStrokeColor(.black, for: .selected)
    editorPickerPageControl.setStrokeColor(.black, for: .normal)

    bannerPagerView.register(UINib(nibName: "HomeBannerCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    bannerPagerView.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 480)
    bannerPagerView.interitemSpacing = 0
    bannerPagerView.backgroundView?.backgroundColor = .clear
    bannerPagerView.inputView?.clipsToBounds = false
    bannerPagerView.automaticSlidingInterval = 3
    bannerPagerView.isInfinite = true

    editorPickerPageControl.numberOfPages = 4

    bindInput()
    getHomeInfo()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let storeId = DataHelperTool.pushStoreId {
      DataHelper<Any>.remove(forKey: .pushStoreId)
      let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
      vc.storeId = storeId
      navigationController?.pushViewController(vc, animated: true)
    } else {
      if shouldGoOrderHistory {
        self.shouldGoOrderHistory = false
        let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(withIdentifier: "orderHistory") as! OrderHistoryViewController
        navigationController?.pushViewController(vc, animated: false)
      }
      if shouldGoWaitOrderHistory {
        self.shouldGoWaitOrderHistory = false
        let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(withIdentifier: "orderHistory") as! OrderHistoryViewController
        vc.selectedOrderStatus.onNext(.wait)
        navigationController?.pushViewController(vc, animated: false)
      }
    }
  }
  func bindInput() {
    searchViewButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "search") as! SearchStoreViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    reservationableStoreButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if let nav = self.tabBarController?.viewControllers?[1] as? UINavigationController {
          if let vc = nav.viewControllers.first as? StoreViewController {
            vc.reservationable = "true"
            self.tabBarController?.selectedIndex = 1
          }
        }
      })
      .disposed(by: disposeBag)
    
    benefitStoreButton.rx.tap
    .bind(onNext: { [weak self] in
      guard let self = self else { return }
      let vc = self.storyboard?.instantiateViewController(withIdentifier: "benefitList") as! BenefitListViewController
      self.navigationController?.pushViewController(vc, animated: true)
    })
    .disposed(by: disposeBag)

    allAroundStoreButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if let nav = self.tabBarController?.viewControllers?[1] as? UINavigationController {
          if let vc = nav.viewControllers.first as? StoreViewController {
            vc.reservationable = "false"
            self.tabBarController?.selectedIndex = 1
          }
        }
      })
      .disposed(by: disposeBag)

    allPlaceButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.tabBarController?.selectedIndex = 1
      })
      .disposed(by: disposeBag)
    
    privacyButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
          let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(withIdentifier: "urlCommon") as! UrlCommonViewController
          vc.url = URL(string:"https://treatapp.notion.site/0238ed9d1b7a450a91ad21682f4e6e7b?pvs=4")
          vc.titleName = "개인정보 처리방침"
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    
    useButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(withIdentifier: "urlCommon") as! UrlCommonViewController
        vc.url = URL(string: "https://treatapp.notion.site/13d057cc5c3142d88256eb0f1df4c68a?pvs=4")
        vc.titleName = "이용약관"
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
  }

  func getHomeInfo() {
    APIService.shared.homeAPI.rx.request(.getHomeInfo)
      .map(HomeInfo.self)
      .subscribe(onSuccess: { response in
        if let popup = response.popupAdvertisement {
          if !DataHelperTool.neverShowPopup {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "popupAD") as! PopupADViewController
            vc.delegate = self
            vc.advertisement = popup
            self.present(vc, animated: false)
          }
        }

        self.bannerList = response.advertisementBanners
        self.bannerPageLabel.text = "1/\(response.advertisementBanners.count)"
        if self.bannerList.count < 2{
          self.bannerPagerView.isInfinite = false
        }
        self.bannerPagerView.reloadData()

        self.magazineList = response.editorPicks
        self.editorPickerPageControl.numberOfPages = response.editorPicks.count
        self.editorPickCollectionView.reloadData()

        self.categoryList = response.categories
        self.setCategoryViewList()

        self.reservationableStoreList = response.reservationableStores
        self.reservationableStoreCollectionView.reloadData()

        self.benefitList = response.advertisementBenefit
        self.benefitCollectionView.reloadData()

        self.placeList = response.places
        self.spotCollectionView.reloadData()

//        self.aroundStoreList = response.aroundStores
//        self.aroundStoreTableView.reloadData()
        self.getAroundStoreList()
      }, onFailure: { error in
        log.error(error)
      })
      .disposed(by: disposeBag)
  }

  func setCategoryViewList() {
    categoryList.enumerated().forEach { (index, category) in
      if categoryViewList.indices.contains(index) {
        let view = categoryViewList[index]
        (view.viewWithTag(1) as! UIImageView).kf.setImage(with: URL(string: category.image!))
        (view.viewWithTag(2) as! UIButton).addTarget(self, action: #selector(didCategoryButtonTapped(_:)), for: .touchUpInside)
      }
    }
  }

  @objc
  func didCategoryButtonTapped(_ sender: UIButton) {
    if let index = categoryViewList.firstIndex(where: { $0 == sender.superview }) {
      if let vc = (self.tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers.first as? StoreViewController {
        vc.selectedHomeParentCategory = categoryList[index]
        self.tabBarController?.selectedIndex = 1
      }
    }
  }
  
  @objc
  func benefitAllButtonTapped(_ sender: UIButton) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "benefitList") as! BenefitListViewController
    navigationController?.pushViewController(vc, animated: true)
  }

  func getAroundStoreList() {
    let param = GetAroundStoreListRequest(
      latitude: LocationManager.shared.currentLocation?.latitude,
      longitude: LocationManager.shared.currentLocation?.longitude,
      aroundCategoryId: selectedAroundMenuIndex+1
    )
    APIService.shared.homeAPI.rx.request(.getAroundStoreList(param: param))
      .map([Store].self)
      .subscribe(onSuccess: { response in
        self.aroundStoreList = response
        self.aroundStoreTableView.reloadData()
      })
      .disposed(by: disposeBag)
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let xPoint = scrollView.contentOffset.x + scrollView.frame.width / 2
    let yPoint = scrollView.frame.height / 2
    let center = CGPoint(x: xPoint, y: yPoint)

//    if scrollView == bannerCollectionView {
//      if let indexPath = bannerCollectionView.indexPathForItem(at: center) {
//        bannerPageLabel.text = "\(indexPath.item+1)/\(bannerList.count)"
//      }
//    }

    if scrollView == editorPickCollectionView {
      if let indexPath = editorPickCollectionView.indexPathForItem(at: center) {
        self.editorPickerPageControl.currentPage = indexPath.row
      }
    }
  }

  deinit {
    categoryViewList = nil;
  }
}

extension HomeViewController: FSPagerViewDataSource, FSPagerViewDelegate {
  func numberOfItems(in pagerView: FSPagerView) -> Int {
    return bannerList.count
  }

  func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
    let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index) as! HomeBannerCell

    let banner = bannerList[index]
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
      cell.gradientView.applyGradient(colors: [.clear, UIColor(hex: "#150b00")])
    }

    if let url = URL(string: banner.thumbnail) {
      cell.bannerImageView.kf.setImage(with: url)
    } else {
      cell.bannerImageView.image = nil
    }

    cell.titleLabel.text = banner.name
    cell.subTitleLabel.text = banner.description
    cell.categoryLabel.text = banner.category
    return cell
  }

  func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
    let banner = bannerList[index]
    APIService.shared.homeAPI.rx.request(.getAdvertisement(id: banner.id))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { _ in
        switch banner.division {
        case .url:
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "urlAD") as! UrlADViewController
          vc.advertisement = banner
          self.navigationController?.pushViewController(vc, animated: true)
        case .image:
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "imageAD") as! ImageADViewController
          vc.advertisement = banner
          self.navigationController?.pushViewController(vc, animated: true)
        case .store:
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "storeAD") as! StoreADViewController
          vc.advertisement = banner
          self.navigationController?.pushViewController(vc, animated: true)
        }
      }, onFailure: { error in
        log.error(error)
      })
      .disposed(by: disposeBag)
  }

  func pagerViewDidScroll(_ pagerView: FSPagerView) {
    bannerPageLabel.text = "\(pagerView.currentIndex+1)/\(bannerList.count)"
  }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//    if collectionView == bannerCollectionView {
//      return bannerList.count
    if collectionView == editorPickCollectionView {
      return magazineList.count
    } else if collectionView == reservationableStoreCollectionView {
      return reservationableStoreList.count > 4 ? 4 : reservationableStoreList.count
    } else if collectionView == benefitCollectionView {
      return benefitList.count > 4 ? 4 : benefitList.count
    } else if collectionView == aroundMenuCollectionView {
      return 4
    } else if collectionView == spotCollectionView {
      return placeList.count
    } else {
      fatalError()
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    if collectionView == bannerCollectionView {
//      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//      let banner = bannerList[indexPath.item]
//      DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//        cell.viewWithTag(2)?.applyGradient(colors: [.clear, UIColor(hex: "#150b00")])
//      }
//
//      if let url = URL(string: banner.thumbnail) {
//        (cell.viewWithTag(1) as! UIImageView).kf.setImage(with: url)
//      } else {
//        (cell.viewWithTag(1) as! UIImageView).image = nil
//      }
//
//      (cell.viewWithTag(3) as! UILabel).text = banner.name
//      (cell.viewWithTag(4) as! UILabel).text = banner.description
//
//      return cell
    if collectionView == editorPickCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      let magazine = magazineList[indexPath.item]

      if let url = URL(string: magazine.thumbnail) {
        (cell.viewWithTag(1) as! UIImageView).kf.setImage(with: url)
      } else {
        (cell.viewWithTag(1) as! UIImageView).image = nil
      }

      (cell.viewWithTag(2) as! UILabel).text = magazine.title
      (cell.viewWithTag(3) as! UILabel).text = magazine.subtitle

      return cell
    } else if collectionView == reservationableStoreCollectionView {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ReservationableStoreCell
        let store = reservationableStoreList[indexPath.row]
        var timeList = store.schedules?.filter({ $0.bedCount >= selectedBedCount }).map({ Date.dateFromString("\(selectedDate.yyyyMMdd) \($0.time):00", dateFormat: .yyyyMMddHHmmss, timeZone: TimeZone(identifier: "GMT")) }).sorted(by: { $0 < $1 }) ?? []
        timeList = timeList.filter({$0 >= Date()})
        cell.collectionView.isHidden = timeList.isEmpty
        cell.timeList = timeList
        cell.collectionView.reloadData()
        cell.id = store.id
        cell.Home = self
        cell.initWithStoreList(store)
      if indexPath.row + 1 == 4 {
        cell.moreButton.isHidden = false
      }else{
        cell.moreButton.isHidden = true
      }
      return cell
    } else if collectionView == benefitCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      let benefit = benefitList[indexPath.item]

      if let url = URL(string: benefit.thumbnail) {
        (cell.viewWithTag(1) as! UIImageView).kf.setImage(with: url)
      } else {
        (cell.viewWithTag(1) as! UIImageView).image = nil
      }

      (cell.viewWithTag(2) as! UILabel).text = benefit.name
      (cell.viewWithTag(3) as! UILabel).text = benefit.price
      (cell.viewWithTag(4) as! UILabel).text = benefit.percent
      (cell.viewWithTag(5) as! UILabel).text = benefit.description

      if indexPath.row + 1 == 4 {
        cell.viewWithTag(6)?.isHidden = false
        (cell.viewWithTag(7) as! UIButton).addTarget(self, action: #selector(benefitAllButtonTapped(_:)), for: .touchUpInside)
      }else{
        cell.viewWithTag(6)?.isHidden = true
      }
      return cell
    } else if collectionView == aroundMenuCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      (cell.viewWithTag(1) as! UILabel).text = aroundMenuList[indexPath.item]
      cell.viewWithTag(3)?.isHidden = selectedAroundMenuIndex != indexPath.item
      return cell
    } else if collectionView == spotCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      let place = placeList[indexPath.item]
      if let url = URL(string: place.image ?? "") {
        (cell.viewWithTag(1) as! UIImageView).kf.setImage(with: url)
      } else {
        (cell.viewWithTag(1) as! UIImageView).image = nil
      }

      return cell
    } else {
      fatalError()
    }
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//    if collectionView == bannerCollectionView {
//      return CGSize(width: UIScreen.main.bounds.width, height: 480)
    if collectionView == editorPickCollectionView {
      return CGSize(width: UIScreen.main.bounds.width, height: 260)
    } else if collectionView == reservationableStoreCollectionView {
      if indexPath.row + 1 == 4 {
        return CGSize(width: UIScreen.main.bounds.width - 90, height: 240)
      }else{
        return CGSize(width: UIScreen.main.bounds.width - 150, height: 240)
      }
    } else if collectionView == benefitCollectionView {
      if indexPath.row + 1 == 4 {
        return CGSize(width: 260, height: 314)
      }else{
        return CGSize(width: 200, height: 314)
      }
    } else if collectionView == aroundMenuCollectionView {
      return CGSize(width: UIScreen.main.bounds.width/4, height: 35)
    } else if collectionView == spotCollectionView {
      return CGSize(width: 64, height: 64)
    } else {
      fatalError()
    }
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    if collectionView == bannerCollectionView {
//      let banner = bannerList[indexPath.item]
//
//      switch banner.division {
//      case .url:
//        if let url = URL(string: banner.url ?? "") {
//          UIApplication.shared.open(url)
//        }
//      case .image:
//        let vc = storyboard?.instantiateViewController(withIdentifier: "imageAD") as! ImageADViewController
//        vc.advertisement = banner
//        navigationController?.pushViewController(vc, animated: true)
//      case .store:
//        let vc = storyboard?.instantiateViewController(withIdentifier: "storeAD") as! StoreADViewController
//        vc.advertisement = banner
//        navigationController?.pushViewController(vc, animated: true)
//      }
    if collectionView == editorPickCollectionView {
      let vc = UIStoryboard(name: "Magazine", bundle: nil).instantiateViewController(withIdentifier: "magazineDetail") as! MagazineDetailViewController
      vc.magazine = magazineList[indexPath.row]
      navigationController?.pushViewController(vc, animated: true)
    } else if collectionView == reservationableStoreCollectionView {
//        let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
//        vc.storeId = reservationableStoreList[indexPath.item].id
//    //    vc.selectedDate = selectedDate
//    //    vc.selectedTime = selectedTime
//    //    vc.selectedBedCount = selectedBedCount
//        navigationController?.pushViewController(vc, animated: true)
    } else if collectionView == benefitCollectionView {
      let banner = benefitList[indexPath.row]
      APIService.shared.homeAPI.rx.request(.getAdvertisement(id: banner.id))
        .filterSuccessfulStatusCodes()
        .subscribe(onSuccess: { _ in
          switch banner.division {
          case .url:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "urlAD") as! UrlADViewController
            vc.advertisement = banner
            self.navigationController?.pushViewController(vc, animated: true)
          case .image:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "imageAD") as! ImageADViewController
            vc.advertisement = banner
            self.navigationController?.pushViewController(vc, animated: true)
          case .store:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "storeAD") as! StoreADViewController
            vc.advertisement = banner
            self.navigationController?.pushViewController(vc, animated: true)
          }
        }, onFailure: { error in
          log.error(error)
        })
        .disposed(by: disposeBag)
      
    } else if collectionView == aroundMenuCollectionView {
      selectedAroundMenuIndex = indexPath.item
      collectionView.reloadData()
      getAroundStoreList()
    } else if collectionView == spotCollectionView {
      let place = placeList[indexPath.item]
      LocationManager.shared.currentLocation = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
      LocationManager.shared.currentAddress = place.address
      tabBarController?.selectedIndex = 1
    }
  }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return aroundStoreList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "homeStoreCell", for: indexPath) as! HomeStoreCell
//
//    let store = aroundStoreList[indexPath.row]
//
//    cell.initWithStore(store)
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StoreCell

    let store = aroundStoreList[indexPath.row]
    cell.collectionView.isHidden = true
    cell.likeButton.isHidden = true
    cell.initWithStore(store)

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
    vc.storeId = aroundStoreList[indexPath.row].id
    //    vc.selectedDate = selectedDate
    //    vc.selectedTime = selectedTime
    //    vc.selectedBedCount = selectedBedCount
    navigationController?.pushViewController(vc, animated: true)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 140
  }
}


extension HomeViewController: PopupADDelegate {
  func didSelectAdvertisement(_ advertisement: Advertisement) {
    APIService.shared.homeAPI.rx.request(.getAdvertisement(id: advertisement.id))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { _ in
        switch advertisement.division {
        case .url:
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "urlAD") as! UrlADViewController
          vc.advertisement = advertisement
          self.navigationController?.pushViewController(vc, animated: true)
        case .image:
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "imageAD") as! ImageADViewController
          vc.advertisement = advertisement
          self.navigationController?.pushViewController(vc, animated: true)
        case .store:
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "storeAD") as! StoreADViewController
          vc.advertisement = advertisement
          self.navigationController?.pushViewController(vc, animated: true)
        }
      }, onFailure: { error in
        log.error(error)
      })
      .disposed(by: disposeBag)
  }
}

class CustomPageControl: UIPageControl {

  var borderCircleColor: UIColor = .clear

  override var currentPage: Int {
    didSet {
      updateBorderColor()
    }
  }

  func updateBorderColor() {
    subviews.enumerated().forEach { index, subview in
      if index != currentPage {
        subview.layer.borderColor = borderCircleColor.cgColor
        subview.layer.borderWidth = 1
      } else {
        subview.layer.borderWidth = 0
      }
    }
  }
}
