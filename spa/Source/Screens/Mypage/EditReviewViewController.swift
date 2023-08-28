//
//  EditReviewViewController.swift
//  spa
//
//  Created by 이동석 on 2022/12/06.
//

import UIKit
import RxAlamofire

class EditReviewViewController: BaseViewController {
  @IBOutlet weak var storeImageView: UIImageView!
  @IBOutlet weak var storeAddressLabel: UILabel!
  @IBOutlet weak var storeNameLabel: UILabel!
  @IBOutlet weak var productNameLabel: UILabel!

  @IBOutlet var starButtonList: [UIButton]!

  @IBOutlet weak var descriptionPlaceholder: UILabel!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var collectionView: UICollectionView!

  @IBOutlet weak var confirmButton: UIButton!

  var order: OrderList!

  var rating = 0
  var imageUrlList = [String]()

  override func viewDidLoad() {
    super.viewDidLoad()

    storeImageView.kf.setImage(with: URL(string: order.storeTitleImage)!)
    storeAddressLabel.text = order.storeAddress
    storeNameLabel.text = order.storeName
    productNameLabel.text = order.productName

    bindInput()
  }

  func bindInput() {
    starButtonList.forEach { button in
      button.rx.tap
        .bind(onNext: { [weak self] in
          guard let self = self else { return }
          self.rating = button.tag
          self.setStarButtons()
        })
        .disposed(by: disposeBag)
    }

    descriptionTextView.rx.text.orEmpty
      .bind(onNext: { [weak self] text in
        self?.descriptionPlaceholder.isHidden = !text.isEmpty
      })
      .disposed(by: disposeBag)

    confirmButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let param = PostReviewRequest(
          orderId: self.order.id,
          description: self.descriptionTextView.text!,
          rating: self.rating,
          images: self.imageUrlList
        )
        self.showHUD()
        APIService.shared.reviewAPI.rx.request(.postReview(param: param))
          .subscribe(onSuccess: { response in
            self.dismissHUD()
            self.callOkActionMSGDialog(message: "등록되었습니다") {
              self.backPress()
            }
          }, onFailure: { error in
            self.dismissHUD()
            self.callMSGDialog(message: "오류가 발생하였습니다")
          })
          .disposed(by: self.disposeBag)
      })
      .disposed(by: disposeBag)
  }

  func setStarButtons() {
    starButtonList.forEach { button in
      if button.tag <= rating {
        button.setImage(UIImage(named: "icStarFill"), for: .normal)
      } else {
        button.setImage(UIImage(named: "icStar"), for: .normal)
      }
    }
  }
}

extension EditReviewViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imageUrlList.count + 1
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.item == 0 {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "add", for: indexPath)

      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

      (cell.viewWithTag(1) as! UIImageView).kf.setImage(with: URL(string: imageUrlList[indexPath.item - 1])!)

      return cell
    }
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.item == 0 {
      UIImagePickerController.show(self)
    } else {
      imageUrlList.remove(at: indexPath.item - 1)
      collectionView.reloadData()
    }
  }
}

extension EditReviewViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)

    let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
    APIService.shared.commonAPI.rx.request(.getPresignedURL(param: GetPresignedURLRequest(type: .image, name: "image.jpeg", mimeType: "image/jpeg")))
      .map(PresignedURL.self)
      .subscribe(onSuccess: { presignedURL in
        RxAlamofire.upload(image.resizeToWidth(newWidth: 200).jpegData(compressionQuality: 1)!, urlRequest: try! URLRequest(url: presignedURL.url, method: .put))
          .subscribe(onNext: { uploadRequest in
            log.info(uploadRequest)
          }, onCompleted: {
            let param = PostFileRequest(type: .image, kind: .reviews, path: presignedURL.path)
            APIService.shared.commonAPI.rx.request(.postFile(param: param))
              .map(PostFileResponse.self)
              .subscribe(onSuccess: { response in
                self.dismissHUD()
                self.imageUrlList.append(response.url)
                self.collectionView.reloadData()
              }, onFailure: { error in
                self.dismissHUD()
              })
              .disposed(by: self.disposeBag)
          })
          .disposed(by: self.disposeBag)
      }, onFailure: { error in

      })
      .disposed(by: disposeBag)
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}
