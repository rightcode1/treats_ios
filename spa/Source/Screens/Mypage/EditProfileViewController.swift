//
//  EditProfileViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/01.
//

import UIKit
import CropViewController
import RxAlamofire
import GoogleSignIn
import KakaoSDKUser
import NaverThirdPartyLogin
import AuthenticationServices


class EditProfileViewController: BaseViewController, CommonDialogDelegate {
  func didUnlikeButtonTapped(diff: String) {
    if diff == "회원탈퇴"{
      APIService.shared.userAPI.rx.request(.withdrawal)
        .filterSuccessfulStatusCodes()
        .subscribe(onSuccess: { response in
          self.dismissHUD()
          self.callOkActionMSGDialog(message: "회원탈퇴가 완료되었습니다") {
            if self.diff == "kakao"{
              self.signOutKakao()
            }else if self.diff == "naver"{
              self.signOutNaver()
            }else if self.diff == "google"{
              self.signOutGoogle()
            }else if self.diff == "apple"{
              self.signOutApple()
            }
            DataHelper<Any>.clearAll()
            self.backPress()
          }
        }, onFailure: { error in
          self.dismissHUD()
          self.callMSGDialog(message: "오류가 발생하였습니다")
        })
        .disposed(by: self.disposeBag)
    }else if diff == "로그아웃"{
      if self.diff == "kakao"{
        signOutKakao()
      }else if self.diff == "naver"{
        signOutNaver()
      }else if self.diff == "google"{
        signOutGoogle()
      }else if self.diff == "apple"{
        signOutApple()
      }
      DataHelper<Any>.clearAll()
      self.backPress()
    }
  }
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var editProfileImageButton: UIButton!

  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var nameTextField: UITextField!

  @IBOutlet var editNicknameButton: UIButton!
  @IBOutlet var editPhoneButton: UIButton!
  @IBOutlet var editPasswordButton: UIButton!

  @IBOutlet weak var logoutButton: UIButton!
  @IBOutlet var withdrawalButton: UIButton!

  @IBOutlet weak var confirmButton: UIButton!

  var selectedImage: UIImage?
  var diff: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    bindInput()
    getUserInfo()
  }
  
  func signOutApple() {
  }
  func signOutGoogle() {
      GIDSignIn.sharedInstance()?.signOut()
  }
  func signOutKakao() {
      // 로그아웃 요청
    KakaoSDKUser.UserApi.shared.logout { error in
      if let error = error {
          print("카카오 로그아웃 실패: \(error.localizedDescription)")
      } else {
          print("카카오 로그아웃 성공")
      }
    }
  }
  func signOutNaver() {
      let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
      naverLoginInstance?.resetToken()
  }

  func bindInput() {
    editProfileImageButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        UIImagePickerController.show(self)
      })
      .disposed(by: disposeBag)

    editNicknameButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "editNickname") as! EditNicknameViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    editPhoneButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "editPhone") as! EditPhoneViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    editPasswordButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if self.diff != "email" {
          let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(withIdentifier: "CommonPopup") as! CommonDialog
          vc.titleString = "해당 채널에서 변경 가능합니다."
          vc.yesHidden = true
          vc.yesTitle = "확인"
            vc.delegate = self
            self.present(vc, animated: false)
        }else{
          let vc = UIStoryboard(name: "Onboard", bundle: nil).instantiateViewController(withIdentifier: "findPassword") as! FindPasswordViewController
          vc.isFromEditProfile = true
          self.navigationController?.pushViewController(vc, animated: true)
        }
      })
      .disposed(by: disposeBag)

    logoutButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(withIdentifier: "CommonPopup") as! CommonDialog
        vc.titleString = "로그아웃 하시겠습니까?"
        vc.yesTitle = "로그아웃"
          vc.delegate = self
          self.present(vc, animated: false)
      })
      .disposed(by: disposeBag)

    withdrawalButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(withIdentifier: "userOut") as! userByeViewController
          vc.yesTitle = "회원탈퇴"
          vc.delegate = self
          self.present(vc, animated: false)
      })
      .disposed(by: disposeBag)

    confirmButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if let image = self.selectedImage {
          self.uploadImage(image) { profileUrl in
            self.patchUserInfo(profileUrl: profileUrl)
          }
        } else {
          self.patchUserInfo(profileUrl: nil)
        }
      })
      .disposed(by: disposeBag)
  }

  func getUserInfo() {
    showHUD()
    APIService.shared.userAPI.rx.request(.getUserInfo)
      .filterSuccessfulStatusCodes()
      .map(User.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        if let url = URL(string: response.profileImage ?? "") {
          self.profileImageView.kf.setImage(with: url)
        } else {
          self.profileImageView.image = UIImage(named: "profileDefault")
        }
        self.diff = response.accounts?.first
        self.emailLabel.text = response.email
        self.nameTextField.text = response.name
      }, onFailure: { error in
        self.dismissHUD()
        self.callOkActionMSGDialog(message: "오류가 발생하였습니다") {
          self.backPress()
        }
      })
      .disposed(by: disposeBag)
  }

  func uploadImage(_ image: UIImage, success: @escaping (String) -> Void) {
    showHUD()
    let param = GetPresignedURLRequest(type: .image, name: "image.jpeg", mimeType: "image/jpeg")
    APIService.shared.commonAPI.rx.request(.getPresignedURL(param: param))
      .map(PresignedURL.self)
      .subscribe(onSuccess: { presignedURL in
        RxAlamofire.upload(image.resizeToWidth(newWidth: 200).jpegData(compressionQuality: 1)!, urlRequest: try! URLRequest(url: presignedURL.url, method: .put))
          .subscribe(onNext: { uploadRequest in
            log.info(uploadRequest)
          }, onCompleted: {
            let param = PostFileRequest(type: .image, kind: .users, path: presignedURL.path)
            APIService.shared.commonAPI.rx.request(.postFile(param: param))
              .map(PostFileResponse.self)
              .subscribe(onSuccess: { response in
                self.dismissHUD()
                success(response.url)
              }, onFailure: { error in
                self.dismissHUD()
              })
              .disposed(by: self.disposeBag)
          })
          .disposed(by: self.disposeBag)
      }, onFailure: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }

  func patchUserInfo(profileUrl: String?) {
    let param = PatchUserInfoRequest(
      profileImage: profileUrl
    )
    showHUD()
    APIService.shared.userAPI.rx.request(.patchUserInfo(param: param))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.callOkActionMSGDialog(message: "변경되었습니다") {
          self.backPress()
        }
      }, onFailure: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
}

extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)

    let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
    self.profileImageView.image = image
    self.selectedImage = image

  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}
