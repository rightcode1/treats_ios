//
//  MypageViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/01.
//

import UIKit
import FirebaseMessaging

class MypageViewController: BaseViewController {
  @IBOutlet weak var loginView: UIView!
  @IBOutlet weak var loginButton: UIButton!

  @IBOutlet weak var userInfoView: UIView!

  @IBOutlet weak var profileImageView: UIImageView!

  @IBOutlet weak var nicknameLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!

  @IBOutlet var pointButton: UIButton!
  @IBOutlet var pointLabel: UILabel!

  @IBOutlet weak var editProfileButton: UIView!
  @IBOutlet weak var reservationButton: UIButton!

  @IBOutlet var couponButton: UIButton!
  @IBOutlet var couponCountLabel: UILabel!

  @IBOutlet weak var recentViewedStoreButton: UIView!
  @IBOutlet weak var chatButton: UIView!
  @IBOutlet weak var myReviewButton: UIView!
  @IBOutlet weak var likeStoreButton: UIView!
  @IBOutlet var userSupportButton: UIView!
  @IBOutlet var noticeButton: UIView!

  @IBOutlet var pushTitleView: UIView!
  @IBOutlet var marketingPushView: UIView!
  @IBOutlet var chatPushView: UIView!

  @IBOutlet var marketingPushSwitch: UISwitch!
  @IBOutlet var chatPushSwitch: UISwitch!
  
  @IBOutlet var homButton: UIButton!
  
  @IBOutlet var privacyButton: UILabel!
  @IBOutlet var useButton: UILabel!
  
  let socketManager = SocketIOManager.sharedInstance
  override func viewDidLoad() {
    super.viewDidLoad()
    marketingPushSwitch.isOn = DataHelperTool.agreeMarketingPush
    chatPushSwitch.isOn = DataHelperTool.agreeChatPush

    bindInput()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
    print("!!!!\(DataHelperTool.accessToken)")
    if DataHelperTool.accessToken == nil {
      recentViewedStoreButton.isHidden = true
      myReviewButton.isHidden = true
      likeStoreButton.isHidden = true
      loginView.isHidden = false
      userInfoView.isHidden = true
      userSupportButton.isHidden = true
      pushTitleView.isHidden = true
      marketingPushView.isHidden = true
      chatPushView.isHidden = true
      chatButton.isHidden = true
    } else {
      recentViewedStoreButton.isHidden = false
      myReviewButton.isHidden = false
      likeStoreButton.isHidden = false
      loginView.isHidden = true
      userInfoView.isHidden = false
      userSupportButton.isHidden = false
      pushTitleView.isHidden = false
      marketingPushView.isHidden = false
      chatPushView.isHidden = false
      chatButton.isHidden = false
      getUserInfo()
    }
    
  }

  func bindInput() {
    loginButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.showLoginViewController()
      })
      .disposed(by: disposeBag)
    
    editProfileButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "editProfile") as! EditProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    homButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.tabBarController?.selectedIndex = 0
      })
      .disposed(by: disposeBag)

    pointButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "point") as! PointViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    reservationButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "orderHistory") as! OrderHistoryViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    couponButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "coupon") as! CouponViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    recentViewedStoreButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = self?.storyboard?.instantiateViewController(withIdentifier: "recentStore") as! RecentStoreViewController
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    chatButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    myReviewButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = self?.storyboard?.instantiateViewController(withIdentifier: "myReview") as! MyReviewViewController
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    likeStoreButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = self?.storyboard?.instantiateViewController(withIdentifier: "like") as! LikeViewController
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    userSupportButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = self?.storyboard?.instantiateViewController(withIdentifier: "userSupport") as! UserSupportViewController
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    noticeButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = self?.storyboard?.instantiateViewController(withIdentifier: "notice") as! NoticeViewController
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    marketingPushSwitch.rx.isOn
      .distinctUntilChanged()
      .bind(onNext: { [weak self] b in
        guard let self = self else { return }
        self.switchMarketingPush(isOn: b)
      })
      .disposed(by: disposeBag)

    chatPushSwitch.rx.isOn
      .distinctUntilChanged()
      .bind(onNext: { [weak self] b in
        guard let self = self else { return }
        self.switchChatPush(isOn: b)
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

  func getUserInfo() {
    APIService.shared.userAPI.rx.request(.getUserInfo)
      .filterSuccessfulStatusCodes()
      .map(User.self)
      .subscribe(onSuccess: { response in
        if let url = URL(string: response.profileImage ?? "") {
          self.profileImageView.kf.setImage(with: url)
        } else {
          self.profileImageView.image = UIImage(named: "profileDefault")
        }
        self.pointLabel.text = (response.point ?? 0).formattedDecimalString()
        self.couponCountLabel.text = (response.couponCount ?? 0).formattedDecimalString()
        self.nicknameLabel.text = response.nickname
        self.emailLabel.text = response.email
        if let setting = response.setting {
          self.marketingPushSwitch.isOn = setting.agreeMarketingPush
          self.chatPushSwitch.isOn = setting.agreeChatPush
        }
      }, onFailure: { error in

      })
      .disposed(by: disposeBag)
  }

  func switchMarketingPush(isOn: Bool) {
    let param = PatchUserInfoRequest(agreeMarketingPush: isOn)
    APIService.shared.userAPI.rx.request(.patchUserInfo(param: param))
      .subscribe()
      .disposed(by: disposeBag)
    if isOn {
      Messaging.messaging().subscribe(toTopic: "marketing") { error in
        log.error(error)
      }
    } else {
      Messaging.messaging().unsubscribe(fromTopic: "marketing") { error in
        log.error(error)
      }
    }
  }

  func switchChatPush(isOn: Bool) {
    let param = PatchUserInfoRequest(agreeChatPush: isOn)
    APIService.shared.userAPI.rx.request(.patchUserInfo(param: param))
      .subscribe()
      .disposed(by: disposeBag)
  }
}
