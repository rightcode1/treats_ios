//
//  StoreDetailViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/04.
//

import UIKit
import RxSwift
import Kingfisher
import FSPagerView
import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate
import SafariServices

enum StoreDetailMenu {
  case product
  case info
  case review
}

struct ReservationTime {
  var date: Date
  var bedCount: Int
}

class StoreDetailViewController: BaseViewController{
  
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet var storeNameLabel: UILabel!
  @IBOutlet var imagePagerView: FSPagerView!
  //  @IBOutlet weak var imageCollectionView: UICollectionView!
  @IBOutlet var imagePageLabel: UILabel!
  @IBOutlet var imagePageControl: FSPageControl!
  
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var summaryLabel: UILabel!
  @IBOutlet var ratingLabel: UILabel!
  @IBOutlet var reviewCountLabel: UILabel!
  @IBOutlet var shareButton: UIButton!
  
  @IBOutlet weak var couponView: UIView!
  @IBOutlet var couponButton: UIView!
  @IBOutlet var couponButtonLabel: UILabel!
  @IBOutlet var couponButtonIcon: UIImageView!
  
  @IBOutlet weak var likeButton: UIButton!
  
  @IBOutlet weak var storeInfoView: UIView!
  @IBOutlet weak var selectedDateLabel: UILabel!
  @IBOutlet weak var selectedBedCountLabel: UILabel!
  @IBOutlet weak var selectedTimeLabel: UILabel!
  
  @IBOutlet weak var roomRegister: UIImageView!
  @IBOutlet weak var scheduleCollectionView: UICollectionView!
  @IBOutlet weak var menuCollectionView: UICollectionView!
  
  @IBOutlet var noScheduleLabel: UILabel!
  @IBOutlet weak var telButton: UIButton!
  @IBOutlet weak var reservationButton: UIButton!
  
  @IBOutlet var emptyImageView: UIImageView!
  
  @IBOutlet var infoFooterView: UIView!
  @IBOutlet var footerLabel: UILabel!

  var storeId: Int!
  var store: Store?
  
  var liked = false
  
  var bedList = [Bed]()
  
  var timeList = [ReservationTime](){
    didSet{
      if timeList.isEmpty{
        noScheduleLabel.isHidden = false
      }else{
        noScheduleLabel.isHidden = true
      }
    }
  }
  var startTime = Date()
  var endTime = Date()
  
  let menuList = ["상품", "정보", "리뷰", "공지"]
  
  var imageList = [String]()
  var productCategoryList = [Store.ProductCategory]()
  var productList = [(String, Store.Product)]()
  var selectedProduct: Store.Product?
  
  var infoImageList = [UIImage]()
  
  var selectedResevationTimeIndex: Int?{
    didSet{
      if selectedResevationTimeIndex != nil{
        selectedTimeLabel.text = self.timeList[self.selectedResevationTimeIndex!].date.ahhmm
      }
    }
  }
  var selectedMenuIndex = 0
  
  var selectedBedCount = 1
  var selectedCoupleRoom :Bool?
  var selectedDate = Date()
  var selectedTime = Date()
  
  var reviewList = [Review]()
  var editorReviewList = [EditorReview]()
  var totalReviewCount = 0
  var chatRoomId: Int = 0
  
  var allImageList = [String]()
  var downloadCouponIdList = [Int]()
  var isRoom = false
  var agreemenst: String = ""
  var safariViewController : SFSafariViewController? // to keep instance
  var noticeList = [StoreNotice]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imagePageControl.setFillColor(.black, for: .selected)
    imagePageControl.setFillColor(.clear, for: .normal)
    imagePageControl.setStrokeColor(.black, for: .selected)
    imagePageControl.setStrokeColor(.black, for: .normal)
    view.bringSubviewToFront(imagePageControl)
    
    imagePagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
    imagePagerView.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    imagePagerView.interitemSpacing = 0
    imagePagerView.backgroundView?.backgroundColor = .clear
    imagePagerView.inputView?.clipsToBounds = false
    //    imagePagerView.automaticSlidingInterval = 3
    imagePagerView.isInfinite = true
    
    
    couponView.isHidden = true
    tableView.tableFooterView?.frame.size.height = 0
    tableView.tableHeaderView?.frame.size.height = UIScreen.main.bounds.width + 383 - 110
    couponButtonIcon.isHidden = true
    
    tableView.register(UINib(nibName: "ProductCategoryCell", bundle: nil), forCellReuseIdentifier: "productCategoryCell")
    tableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "productCell")
    tableView.register(UINib(nibName: "StoreNoticeCell", bundle: nil), forCellReuseIdentifier: "noticeCell")
    
    reservationButton.backgroundColor = .black
    reservationButton.setTitleColor(.white, for: .normal)
    
    selectedDateLabel.text = selectedDate.MMddEKR
    selectedBedCountLabel.text = "\(selectedBedCount)명"
    selectedTimeLabel.text = selectedTime.ahmm
    
    bindInput()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
    getStoreDetail()
    getAgreements()
  }
  
  func bindInput() {
    likeButton.rx.tap
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if DataHelperTool.accessToken == nil {
          self.showLoginViewController()
        } else {
          self.liked = !self.liked
          if self.liked {
            APIService.shared.storeAPI.rx.request(.likeStore(id: self.storeId))
              .subscribe()
              .disposed(by: self.disposeBag)
          } else {
            APIService.shared.storeAPI.rx.request(.unlikeStore(id: self.storeId))
              .subscribe()
              .disposed(by: self.disposeBag)
          }
          
          self.likeButton.setImage(self.liked ? UIImage(named: "iconBookmarkOn") : UIImage(named: "iconBookmarkOff"), for: .normal)
        }
      })
      .disposed(by: disposeBag)
    
    shareButton.rx.tap
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "KakaoPopup") as! KakaoSharePopupViewController
        vc.delegate = self
        self.present(vc, animated: false)
      })
      .disposed(by: disposeBag)
    
    storeInfoView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "selectStoreInfo") as! SelectStoreInfoViewController
        vc.delegate = self
        vc.selectedDate = self.selectedDate
        vc.selectedBedCount = self.selectedBedCount
        vc.storeId = self.storeId
        vc.selectedTime = self.selectedTime
        vc.startTime  = self.startTime
        vc.endTime = self.endTime
        self.present(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    couponButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "storeCoupon") as! StoreCouponViewController
        vc.couponList = self.store?.coupons ?? []
        vc.parentVC = self
        self.present(vc, animated: false)
      })
      .disposed(by: disposeBag)
    
    roomRegister.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if DataHelperTool.accessToken == nil {
          self.showLoginViewController()
          return
        }
        if self.isRoom{
          let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatRoomVC") as! ChatRoomVC
          vc.RoomName = self.store?.name ?? ""
          vc.chatRoomId = self.chatRoomId
          self.navigationController?.pushViewController(vc, animated: true)
        }else{
          self.roomAdd()
        }
      })
      .disposed(by: disposeBag)
    
    telButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CallPopup") as! CallPhonePopupViewController
        vc.delegate = self
        vc.phoneNum = self.store?.tel ?? "010-0000-0000"
        self.present(vc, animated: false)
      })
      .disposed(by: disposeBag)
    
    reservationButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        guard let store = self.store else { return }
        
        if self.selectedResevationTimeIndex == nil {
          self.callOkCancelMSGDialog(message: "예약시간을 선택해주세요.", okAction: {
          })
          return
        }
        if self.selectedProduct == nil {
          self.callOkCancelMSGDialog(message: "관리상품을 선택해주세요.", okAction:{
          })
          return
        }
        guard let product = self.selectedProduct else { return }
        
        if DataHelperTool.accessToken == nil {
          self.showLoginViewController()
          return
        }
        

        
        if (store.options ?? []).isEmpty {
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "confirmReservation") as! ConfirmReservationViewController
          vc.store = store
          let productCategory = store.productCategories?.first(where: { $0.products.contains(where: { $0.id == product.id }) })
          vc.productCategory = productCategory
          vc.product = product
          vc.date = self.selectedDate
          vc.time = self.selectedTime
          vc.selectedBedCount = self.selectedBedCount
          vc.selectedCoupleRoom = self.selectedCoupleRoom
          vc.selectedReservationTime = self.timeList[self.selectedResevationTimeIndex!].date
          vc.selectedBedCount = self.selectedBedCount
          self.navigationController?.pushViewController(vc, animated: true)
        } else {
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "selectOption") as! SelectOptionViewController
          vc.delegate = self
          vc.optionList = (store.options ?? []).map({ option in
            return (option, 0)
          })
          self.present(vc, animated: false)
        }
      })
      .disposed(by: disposeBag)
  }
  func roomAdd() {
    let param = RegisterChatRoom(storeId: storeId!)
    APIService.shared.storeAPI.rx.request(.chatRoom(param: param))
      .filterSuccessfulStatusCodes()
      .map(RegisterRoomResponse.self)
      .subscribe(onSuccess: { response in
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatRoomVC") as! ChatRoomVC
        vc.RoomName = self.store?.name ?? ""
        vc.chatRoomId = response.id
        self.navigationController?.pushViewController(vc, animated: true)
      }, onFailure: { error in
      })
      .disposed(by: disposeBag)
  }
  func getStoreDetail() {
    showHUD()
    APIService.shared.storeAPI.rx.request(.getStoreDetail(id: storeId))
      .filterSuccessfulStatusCodes()
      .map(Store.self)
      .subscribe(onSuccess: { response in
        self.isRoom = response.isRoom ?? false
        self.chatRoomId = response.chatRoomId ?? 0
        DataHelper<Any>.pushRecentStores(response)
        self.couponButtonLabel.text = "\(response.name) 쿠폰 다운받기"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        self.startTime = dateFormatter.date(from: response.serviceStart) ?? Date()
        self.endTime = dateFormatter.date(from: response.serviceEnd) ?? Date()
        if (response.coupons ?? []).isEmpty {
          self.couponView.isHidden = true
          self.tableView.tableHeaderView?.frame.size.height = UIScreen.main.bounds.width + 385 - 110
        } else {
          self.couponView.isHidden = false
          self.couponButtonIcon.isHidden = false
          self.tableView.tableHeaderView?.frame.size.height = UIScreen.main.bounds.width + 385
        }
        self.downloadCouponIdList = response.downloadCouponIdList ?? []
        self.dismissHUD()
        self.store = response
        self.liked = response.liked ?? false
        self.likeButton.setImage(self.liked ? UIImage(named: "iconBookmarkOn") : UIImage(named: "iconBookmarkOff"), for: .normal)
        
        self.likeButton.setImage(response.liked ?? false ? UIImage(named: "iconBookmarkOn") : UIImage(named: "iconBookmarkOff"), for: .normal)
        
        self.imageList = response.images
        self.imagePageLabel.text = "1/\(response.images.count)"
        self.imagePageControl.numberOfPages = response.images.count
        //        self.imageCollectionView.reloadData()
        self.imagePagerView.reloadData()
        
        var addressList = response.address.split(separator: " ")
        var address = ""
        if addressList.indices.contains(0) {
          address.append(addressList[0] + " ")
        }
        
        if addressList.indices.contains(1) {
          address.append(addressList[1] + "")
        }
        
        addressList.removeFirst()
        addressList.removeFirst()
        
        self.addressLabel.text = address
        self.summaryLabel.text = "\(addressList.joined(separator: " ")) \(response.addressDetail)"
        
        self.storeNameLabel.text = response.name
        self.nameLabel.text = response.name
        self.ratingLabel.text = String(format: "%.1f", response.rating)
        self.reviewCountLabel.text = "리뷰 \((response.reviewCount ?? 0).formattedDecimalString()) 개"
        
        self.productCategoryList = response.productCategories ?? []
        self.productList = []
        response.productCategories?.forEach({ pc in
          pc.products.forEach { p in
            self.productList.append((pc.name, p))
          }
        })
        self.setFooterHeight()
        self.editorReviewList = response.editorReviews ?? []
        self.tableView.reloadData()
        self.getInfoImages()
        self.getSchedule()

        self.noticeList = response.notice ?? []
      }, onFailure: { error in
        self.dismissHUD()
        self.callOkActionMSGDialog(message: "오류가 발생하였습니다") {
          self.backPress()
        }
        log.error(error)
      })
      .disposed(by: disposeBag)
  }
  
  func getSchedule() {
    APIService.shared.storeAPI.rx.request(.getStoreSchedule(storeId: storeId, date: selectedDate.yyyyMMdd))
      .filterSuccessfulStatusCodes()
      .map(GetScheduleResponse.self)
      .subscribe(onSuccess: { response in
        self.bedList = response.data
        self.timeList = []
        
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date() // 현재 로컬 시간을 가져옵니다.

        var date = calendar.date(from: DateComponents(year: self.selectedDate.year, month: self.selectedDate.month, day: self.selectedDate.day, hour: 0, minute: 0))!
        let endDate = calendar.date(byAdding: .day, value: 1, to: date)!

        var dateList = [Date]()
        while (date < endDate) {
            date.addTimeInterval(60 * 30)
            
            // 시작 날짜가 현재 로컬 시간 이후인 경우에만 추가
            if date >= currentDate {
                dateList.append(date)
            }
        }
        print(self.selectedTime)
        self.timeList = dateList.map({ ReservationTime(date: $0, bedCount: 0) })
        self.timeList = self.timeList.filter({$0.date >= self.selectedTime})
        
        let hourCalendar = Calendar.current
        let startHourMinute = calendar.dateComponents([.hour, .minute], from: self.startTime)
        let endHourMinute = calendar.dateComponents([.hour, .minute], from: self.endTime)

        self.timeList = self.timeList.filter { reservationTime in
          let reservationHourMinute = calendar.dateComponents([.hour, .minute], from: reservationTime.date)
          return self.compareDateComponents(lhs: reservationHourMinute, rhs: startHourMinute) && self.compareDateComponents(lhs: endHourMinute, rhs: reservationHourMinute)
        }
        response.data.forEach { bed in
          (bed.schedules ?? []).forEach { schedule in
            let date = Date.dateFromISO8601String(schedule.date)!
            if let index = self.timeList.firstIndex(where: { $0.date.isSameTime(date) }) {
              self.timeList[index].bedCount += 1
            }
          }
        }
        
        //        self.timeList = self.timeList.filter({ $0.date > Date() })
        self.timeList.enumerated().forEach({ (index, item) in
          if item.date < Date() {
            self.timeList[index].bedCount = 0
          }
        })
        self.timeList.sort(by: { $0.date < $1.date})
        
        if let index = self.timeList.firstIndex(where: { $0.date == self.selectedTime }) {
          self.selectedResevationTimeIndex = index
        }
        self.scheduleCollectionView.reloadData()
        self.tableView.reloadData()
        
        if let time = self.timeList.filter({ $0.date > Date() }).first {
          if let index = self.timeList.firstIndex(where: { $0.date == time.date }) {
            self.scheduleCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .left, animated: false)
          }
        }
      }, onFailure: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func getInfoImages() {
    guard let store = store else { return }
    
    let observables = store.infos.compactMap { content -> Observable<UIImage>? in
      guard let imageURLString = content.image, !imageURLString.isEmpty,
            let imageURL = URL(string: imageURLString) else {
        infoImageList.append(UIImage())
        allImageList.append("noImage")
        // content.image가 빈 값인 경우에 대한 처리 로직
        return nil
      }

      return Observable<UIImage>.create { observer in
        KingfisherManager.shared.retrieveImage(with: imageURL) { result in
          switch result {
          case .success(let image):
            observer.onNext(image.image)
            observer.onCompleted()
          case .failure(let error):
            observer.onError(error)
          }
        }
        return Disposables.create()
      }
    }
    
    Observable.concat(observables)
      .subscribe(onNext: { image in
        self.infoImageList.append(image)
        self.allImageList.append("yesImage")
        log.info(image.size)
      }, onError: { error in
        log.error(error)
      }, onCompleted: {
        log.info("onCompleted")
        self.tableView.reloadData()
      }, onDisposed: {
        log.info("onDisposed")
      })
      .disposed(by: disposeBag)
  }
  
  
  
  
  func getReviewList(_ refresh: Bool = true) {
    if refresh {
      reviewList = []
    }
    
    let param = GetReviewListRequest(start: 0, perPage: 20, storeId: storeId, order: nil)
    APIService.shared.reviewAPI.rx.request(.getReviewList(query: param))
      .map(ListResponse<Review>.self)
      .subscribe(onSuccess: { response in
        self.reviewList = response.data
        self.totalReviewCount = response.total
        self.tableView.reloadData()
        self.setFooterHeight()
      }, onFailure: { error in
        log.error(error)
      })
      .disposed(by: disposeBag)
  }
  func getAgreements() {
    APIService.shared.commonAPI.rx.request(.getAgreements)
      .map(AgreementsResponse.self)
      .subscribe(onSuccess: { response in
        self.agreemenst = response.contents
      }, onFailure: { error in
        log.error(error)
      })
      .disposed(by: disposeBag)
  }

  func getNoticeList(_ refresh: Bool = true) {
    

  }
  
  func setFooterHeight() {
    if self.selectedMenuIndex == 0 {
      self.infoFooterView.isHidden = true
      self.emptyImageView.isHidden = false
      self.emptyImageView.image = UIImage(named: "imgNoProduct")
      self.tableView.tableFooterView?.frame.size.height = self.productCategoryList.isEmpty ? 250 : 10
    } else if self.selectedMenuIndex == 1 {
      self.infoFooterView.isHidden = false
      self.emptyImageView.isHidden = true
      self.footerLabel.text = agreemenst
      self.tableView.tableFooterView?.frame.size.height = 250
    } else if self.selectedMenuIndex == 2 {
      self.infoFooterView.isHidden = true
      self.emptyImageView.isHidden = false
      self.emptyImageView.image = UIImage(named: "imgNoReview")
      self.tableView.tableFooterView?.frame.size.height = self.reviewList.isEmpty ? 250 : 10
    } else {
      self.infoFooterView.isHidden = true
      self.emptyImageView.isHidden = false
      self.emptyImageView.image = UIImage(named: "imgNoNotice")
      self.tableView.tableFooterView?.frame.size.height = self.noticeList.isEmpty ? 250 : 10
    }
    self.tableView.reloadData()
  }
}

extension StoreDetailViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if selectedMenuIndex == 0 {
      return 1 + productList.count
    } else if selectedMenuIndex == 1 {
      if store!.infos.isEmpty {
        return 3
      } else {
        return (store?.infos.count ?? 0) + 2
      }
    } else if selectedMenuIndex == 2 {
      return (editorReviewList.isEmpty ? 0 : 1) + 1 + reviewList.count
    } else {
      return noticeList.count
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if selectedMenuIndex == 0 {
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath)
        return cell
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductCell
        let categoryNameAndProduct = productList[indexPath.row - 1]
        let product = categoryNameAndProduct.1

        cell.headerLabel.text = categoryNameAndProduct.0
        if productList.indices.contains(indexPath.row - 2) {
          if categoryNameAndProduct.0 == productList[indexPath.row - 2].0 {
            cell.headerView.isHidden = true
          } else {
            cell.headerView.isHidden = false
          }
        } else {
          cell.headerView.isHidden = false
        }


        cell.nameLabel.text = product.name
        cell.timeLabel.text = "\(product.surgeryTime ?? 0) 분"
        cell.priceLabel.text = "\(product.price.formattedDecimalString())원"
        cell.contentLabel.text = product.content

        if checkAvailableProduct(product) {
          cell.unavailableBadge.isHidden = true
          cell.cardView.backgroundColor = .white
          cell.nameLabel.textColor = .black
          cell.timeLabel.textColor = .black
          cell.priceLabel.textColor = .black
          cell.contentLabel.textColor = .black
        } else {
          cell.unavailableBadge.isHidden = false
          cell.cardView.backgroundColor = UIColor(hex: "#f6f6f6")
          cell.nameLabel.textColor = UIColor(hex: "#c6c6c6")
          cell.timeLabel.textColor = UIColor(hex: "#c6c6c6")
          cell.priceLabel.textColor = UIColor(hex: "#c6c6c6")
          cell.contentLabel.textColor = UIColor(hex: "#c6c6c6")
        }

        cell.cardView.borderColor = selectedProduct?.id == product.id ? .black : UIColor(hex: "f6f6f6")

//        let productCategory = productCategoryList[indexPath.row - 1]
//        cell.delegate = self
//        cell.bedList = bedList
//        if let index = selectedResevationTimeIndex {
//          cell.selectedTime = timeList[index].date
//        }
//        cell.selectedBedCount = selectedBedCount
//        cell.categoryNameLabel.text = productCategory.name
//        cell.productList = productCategory.products
//        cell.selectedProduct = selectedProduct
//        cell.tableView.reloadData()
        return cell
      }
    } else if selectedMenuIndex == 1 {
      if store!.infos.isEmpty {
        if indexPath.row == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "noInfoCell", for: indexPath)

          return cell
        }else if indexPath.row == 1 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "infoMapCell", for: indexPath)

          if let store = store {
            let mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(
              latitude: store.latitude,
              longitude: store.longitude)
            )
            let mapView = cell.viewWithTag(1) as! MTMapView
            mapView.isUserInteractionEnabled = false
            mapView.setMapCenter(mapPoint, zoomLevel: 0, animated: false)

            let poiItem = MTMapPOIItem()
            poiItem.mapPoint = mapPoint
            poiItem.markerType = .customImage
            poiItem.customImage = UIImage(named: "marker")
            mapView.add(poiItem)

            (cell.viewWithTag(2) as! UILabel).text = "\(store.address) \(store.addressDetail)"
          }
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "storeInfoCell", for: indexPath) as! StoreInfoCell
          if store?.holiday == ""{
            cell.restDayView.isHidden = true
          }
          if store?.time == ""{
            cell.doDayView.isHidden = true
          }
          if store?.subway == ""{
            cell.surveyView.isHidden = true
          }
          if store?.parking == ""{
            cell.parkView.isHidden = true
          }
          
          cell.restDayLabel.text = store?.holiday
          cell.doDayLabel.text = store?.time
          cell.surveyLabel.text = store?.subway
          cell.parkLabel.text = store?.parking
          cell.coupleRoomLabel.text = store!.isCoupleRoom ? "보유" :  "미보유"
          
          return cell
        }
      } else {
        if indexPath.row < store?.infos.count ?? 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "infoImageCell", for: indexPath) as! ImageInfoCell
          
          if allImageList[indexPath.row] == "yesImage"{
            cell.infoImageView.image = infoImageList[indexPath.row]
            cell.infoImageViewHeightConstraint.constant = infoImageList[indexPath.row].resizeToWidth(newWidth: UIScreen.main.bounds.width - 40).size.height
          }else{
            cell.infoImageView.isHidden = true
          }
          cell.titleLabel.text = store?.infos[indexPath.row].title
          cell.descriptionLabel.text = store?.infos[indexPath.row].description

//          (cell.viewWithTag(1) as! UIImageView).image = infoImageList[indexPath.row]

          return cell
        }else if indexPath.row == store?.infos.count ?? 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "infoMapCell", for: indexPath)

          if let store = store {
            if let mapView = cell.viewWithTag(1) as? MTMapView {
              mapView.isUserInteractionEnabled = false
              mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(
                latitude: store.latitude,
                longitude: store.longitude)
              ), zoomLevel: 0, animated: false)
            }

            (cell.viewWithTag(2) as! UILabel).text = "\(store.address) \(store.addressDetail)"
          }

          return cell
        }else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "storeInfoCell", for: indexPath) as! StoreInfoCell
          if store?.holiday == ""{
            cell.restDayView.isHidden = true
          }
          if store?.time == ""{
            cell.doDayView.isHidden = true
          }
          if store?.subway == ""{
            cell.surveyView.isHidden = true
          }
          if store?.parking == ""{
            cell.parkView.isHidden = true
          }
          if store?.launch == ""{
            cell.launchView.isHidden = true
          }
          cell.restDayLabel.text = store?.holiday
          cell.doDayLabel.text = store?.time
          cell.surveyLabel.text = store?.subway
          cell.launchLabel.text = store?.launch
          cell.parkLabel.text = store?.parking
          cell.coupleRoomLabel.text = store!.isCoupleRoom ? "보유" : "미보유"
          return cell
        }
      }
    } else if selectedMenuIndex == 2 {
      if editorReviewList.isEmpty {
        if indexPath.row == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "reviewTitle", for: indexPath)
          (cell.viewWithTag(1) as! UILabel).text = "리뷰 (\(totalReviewCount.formattedDecimalString())개)"
          if !reviewList.isEmpty{
            (cell.viewWithTag(2) as! UILabel).text = String(format: "%.1f", reviewList.reduce(0.0) { $0 + $1.rating } / Double(reviewList.count))
          }
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! StoreReviewCell
          let review = reviewList[indexPath.row - 1]
          cell.initWithReview(review)
          return cell
        }
      } else {
        if indexPath.row == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "editorReviewCell", for: indexPath) as! StoreEditorReviewCell
          cell.editorReviewList = self.editorReviewList
          cell.collectionView.reloadData()
          cell.delegate = self
          //          (cell.viewWithTag(1) as! UILabel).text = totalReviewCount.formattedDecimalString()
          return cell
        } else if indexPath.row == 1 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "reviewTitle", for: indexPath)
          (cell.viewWithTag(1) as! UILabel).text = "리뷰 (\(totalReviewCount.formattedDecimalString()))"
          (cell.viewWithTag(2) as! UILabel).text = String(format: "%.1f", store?.rating ?? 0.0)
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! StoreReviewCell
          let review = reviewList[indexPath.row - 2]
          cell.initWithReview(review)
          return cell
        }
      }
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell") as! StoreNoticeCell
      cell.initWithNotice(noticeList[indexPath.row])
      return cell
    }
  }

  func checkAvailableProduct(_ product: Store.Product) -> Bool {
    

    if let index = selectedResevationTimeIndex {
      let selectedTime = timeList[index].date
      var timeList = [Date]()
      for i in 1...product.time / 30 {
        timeList.append(selectedTime.addingTimeInterval(TimeInterval(60*30*(i-1))))
      }

      var availableBedCount = 0
      bedList.forEach { bed in
        var isAvailable = true

        timeList.forEach { date in
          if !(bed.schedules ?? []).contains(where: { Date.dateFromISO8601String($0.date)!.isSameTime(date) }) {
            isAvailable = false
          }
        }

        if isAvailable {
          availableBedCount += 1
        }
      }
      return availableBedCount >= selectedBedCount
    } else {
      return true
    }

  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if selectedMenuIndex == 0 {
      if indexPath.row == 0 {
        return 42
      } else {
//        let productCategory = productCategoryList[indexPath.row - 1]
//        return 68 + (CGFloat(productCategory.products.count) * 115)
        return UITableView.automaticDimension
      }
    } else if selectedMenuIndex == 1 {
      if store!.infos.isEmpty {
        if indexPath.row == 0 {
          return 370
        }else if indexPath.row == 1{
          return 290 // map
        } else {
          if store?.holiday == "" && store?.time == "" && store?.subway == "" && store?.parking == "" && store?.launch == ""{
            return 0
          }else{
            return 370
          }
        }
      } else {
        if indexPath.row < store?.infos.count ?? 0 {
          return UITableView.automaticDimension
        } else if indexPath.row == store?.infos.count ?? 0{
          return 290 // map
        } else {
          if store?.holiday == "" && store?.time == "" && store?.subway == "" && store?.parking == "" && store?.launch == ""{
            return 0
          }else{
            return 370
          }
        }
      }
    } else if selectedMenuIndex == 2 {
      if editorReviewList.isEmpty {
        if indexPath.row == 0 {
          return 42
        } else {
          return UITableView.automaticDimension
        }
      } else {
        if indexPath.row == 0 {
          return 268
        } else if indexPath.row == 1 {
          return 42
        } else {
          return UITableView.automaticDimension
        }
      }
    } else {
      return 80
    }
  }

  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if selectedMenuIndex == 0 {
      print(indexPath.row)
      if indexPath.row > 0 {
        if selectedResevationTimeIndex == nil {
          callMSGDialog(message: "시간을 먼저 선택해주세요")
          return
        }

        let product = productList[indexPath.row - 1].1

        if checkAvailableProduct(product) {
          if selectedProduct?.id == product.id {
            selectedProduct = nil
          } else {
            selectedProduct = product
          }
          tableView.reloadData()

        }
      }
    } else if selectedMenuIndex == 3 {
      let notice = noticeList[indexPath.row]

      let vc = self.storyboard?.instantiateViewController(withIdentifier: "storeNoticeDetail") as! StoreNoticeDetailViewController
      vc.noticeDetail = notice
      navigationController?.pushViewController(vc, animated: true)
    }
  }
}

extension StoreDetailViewController: FSPagerViewDataSource, FSPagerViewDelegate {
  func numberOfItems(in pagerView: FSPagerView) -> Int {
    return imageList.count
  }

  func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
    let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
    
    cell.imageView?.contentMode = .scaleAspectFill
    cell.imageView?.kf.setImage(with: URL(string: imageList[index])!)

    return cell
  }

  func pagerViewDidScroll(_ pagerView: FSPagerView) {
    imagePageLabel.text = "\(pagerView.currentIndex+1)/\(imageList.count)"
    imagePageControl.currentPage = pagerView.currentIndex
  }

}

extension StoreDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //    if collectionView == imageCollectionView {
    //      return imageList.count
    if collectionView == scheduleCollectionView {
      return timeList.count
    } else if collectionView == menuCollectionView {
      return menuList.count
    } else {
      fatalError()
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if collectionView == scheduleCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      let time = timeList[indexPath.item]
      
      let disableColor = UIColor(hex: "#cbcbcb")
      let disableBolderColor = UIColor(hex: "#cbcbcb")
      
      (cell.viewWithTag(1) as! UILabel).text = timeList[indexPath.item].date.ahhmm
      
      if time.bedCount < selectedBedCount {
        cell.borderColor = disableColor
        (cell.viewWithTag(1) as! UILabel).textColor = .white
        cell.backgroundColor = disableColor
      } else {
        cell.borderColor = indexPath.item == selectedResevationTimeIndex ? UIColor(hex: "#85d0c9") : UIColor(hex: "#cbcbcb")
        (cell.viewWithTag(1) as! UILabel).textColor = indexPath.item == selectedResevationTimeIndex ? .white : .black
        cell.backgroundColor = indexPath.item == selectedResevationTimeIndex ? UIColor(hex: "#85d0c9") : .white
      }
      return cell
    } else if collectionView == menuCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      (cell.viewWithTag(1) as! UILabel).text = menuList[indexPath.item]
      cell.viewWithTag(2)?.isHidden = indexPath.item != selectedMenuIndex
      return cell
    } else {
      fatalError()
    }
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == scheduleCollectionView {
      if timeList[indexPath.item].bedCount < selectedBedCount {
        print(timeList[indexPath.row])
        selectedTime = timeList[indexPath.row].date
        self.selectedDate = timeList[indexPath.row].date
        let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(withIdentifier: "CommonPopup") as! CommonDialog
        vc.titleString = "해당 시간은 예약이 불가능합니다.\n예약 취소시 대기 알림을 받으시겠습니까?"
        vc.yesTitle = "줄서기 예약"
          vc.delegate = self
          self.present(vc, animated: false)
      }
      if selectedResevationTimeIndex != indexPath.item {
        selectedResevationTimeIndex = indexPath.item
        
        selectedProduct = nil
          let currentTime = Date() // 현재 시간
          let oneHourLater = currentTime.addingTimeInterval(3600) // 현재 시간으로부터 1시간 뒤의 시간
          let oneHourTenLater = currentTime.addingTimeInterval(4200) // 현재 시간으로부터 1시간 10분 뒤의 시간
          if self.timeList[selectedResevationTimeIndex!].date >= oneHourLater && self.timeList[selectedResevationTimeIndex!].date <= oneHourTenLater{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "hurryUpPopup") as! OrderOneHourCautionView
            self.present(vc, animated: true)
          } else  if self.timeList[selectedResevationTimeIndex!].date < oneHourLater {
            selectedResevationTimeIndex = nil
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "noResevationPopup") as! NoOrderOneHourView
            self.present(vc, animated: true)
            return
          }
      }

      tableView.reloadData()
    } else if collectionView == menuCollectionView {
      selectedMenuIndex = indexPath.item
      if selectedMenuIndex == 2 {
        getReviewList(true)
      } else {
        setFooterHeight()
      }

      tableView.reloadData()
    }
    collectionView.reloadData()
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == scheduleCollectionView {
      return CGSize(width: 70, height: 30)
    } else if collectionView == menuCollectionView {
      return CGSize(width: UIScreen.main.bounds.width / 4, height: 42)
    } else {
      fatalError()
    }
  }
}

extension StoreDetailViewController: SelectStoreInfoDelegate {
  func didApplyFilter(date: Date, bedCount: Int, time: Date, isCouple: Bool?) {
    selectedDate = date
    selectedBedCount = bedCount
    selectedTime = time
    selectedCoupleRoom = isCouple
    selectedDateLabel.text = selectedDate.MMddEKR
    selectedBedCountLabel.text = "\(selectedBedCount)명"
    selectedTimeLabel.text = selectedTime.ahmm
    getSchedule()
  }
}
extension StoreDetailViewController: storeEditProtocol {
  func didSelectStoreEdit(url: URL) {
    let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "urlAD") as! UrlADViewController
    vc.detailUrl = url
    vc.detailStoreName = store?.name
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension StoreDetailViewController: SelectOptionDelegate {
  func didSelectOptions(_ selectedOptionList: [(Store.Option, Int)]) {
    guard let product = selectedProduct else { return }
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "confirmReservation") as! ConfirmReservationViewController
    vc.store = store
    let productCategory = self.store?.productCategories?.first(where: { $0.products.contains(where: { $0.id == product.id }) })
    vc.productCategory = productCategory
    vc.product = product
    vc.date = self.selectedDate
    vc.time = self.selectedTime
    vc.selectedCoupleRoom = self.selectedCoupleRoom
    vc.selectedReservationTime = timeList[selectedResevationTimeIndex!].date
    vc.selectedBedCount = self.selectedBedCount
    vc.optionList = selectedOptionList.filter({ $0.1 > 0 })
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension StoreDetailViewController: ProductCategoryCellDelegate {
  func didSelectProduct(_ product: Store.Product, cell: ProductCategoryCell) {
    if selectedResevationTimeIndex == nil {
      callMSGDialog(message: "시간을 먼저 선택해주세요")
      return
    }

    if cell.checkAvailableProduct(product) {
      if selectedProduct?.id == product.id {
        selectedProduct = nil
      } else {
        selectedProduct = product
      }
      tableView.reloadData()
    }
  }
}

extension StoreDetailViewController : KakaoSharePopupDelegate{
  func didTapShare() {
    guard let store = self.store else { return }
    
    
    let feedTemplateJsonStringData =
"""
{
    "object_type": "feed",
    "content": {
        "title": "\(store.name)",
        "description": "\(store.categories?.map({ "#\($0.name)" }).joined(separator: " ") ?? "")",
        "image_url": "\(store.titleImage)",
        "link": {
            "mobile_web_url": "https://developers.kakao.com",
            "web_url": "https://developers.kakao.com"
        }
    },
    "social": {
        "like_count": \(store.likedCount)
    },
    "buttons": [
        {
            "title": "앱으로 보기",
            "link": {
                "android_execution_params": "storeId=\(store.id)",
                "ios_execution_params": "storeId=\(store.id)"
            }
        }
    ]
}
""".data(using: .utf8)!
    do {
      let templatable = try SdkJSONDecoder.custom.decode(FeedTemplate.self, from: feedTemplateJsonStringData)
      
      if ShareApi.isKakaoTalkSharingAvailable() {
        ShareApi.shared.shareDefault(templatable: templatable) {(sharingResult, error) in
          if let error = error {
            print(error)
          }
          else {
            print("shareDefault() success.")
            
            if let sharingResult = sharingResult {
              UIApplication.shared.open(sharingResult.url,
                                        options: [:], completionHandler: nil)
            }
          }
        }
        
      } else {
        if let url = ShareApi.shared.makeDefaultUrl(templatable: templatable) {
          self.safariViewController = SFSafariViewController(url: url)
          self.safariViewController?.modalTransitionStyle = .crossDissolve
          self.safariViewController?.modalPresentationStyle = .overCurrentContext
          self.present(self.safariViewController!, animated: true) {
            print("웹 present success")
          }
        }
      }
    } catch let error {
      log.error(error)
    }
  }
  
  
}
extension StoreDetailViewController : selectWaitProtocol{
  func selectWait() {
  }
}
extension StoreDetailViewController : CallPhoneDelgate{
  func TapCall() {
  if let url = URL(string: "tel:\(self.store?.tel ?? "")") {
    UIApplication.shared.open(url)
  } else {
    
  }
  }
  
  
}
extension StoreDetailViewController: CommonDialogDelegate{
  func didUnlikeButtonTapped(diff: String) {
    let param = PostWatingRequest(
      date: self.selectedDate.yyyyMMdd,
      time: self.selectedTime.HHmm,
      count: self.selectedBedCount,
      storeId: self.storeId
    )
    self.showHUD()
    APIService.shared.storeAPI.rx.request(.postWating(param: param))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "waitComplete") as! WatiCompleteViewController
        self.navigationController?.pushViewController(vc, animated: true)
      }, onFailure: { error in
        self.dismissHUD()
      }, onDisposed: {
      })
      .disposed(by: self.disposeBag)
  }
}
  
