//
//  StoreNoticeDetailViewController.swift
//  spa
//
//  Created by 이동석 on 2023/07/23.
//

import UIKit
import RxSwift
import Kingfisher

class StoreNoticeDetailViewController: BaseViewController {
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var createdAtLabel: UILabel!
  @IBOutlet var contentLabel: UILabel!
  @IBOutlet var stackView: UIStackView!

  var noticeDetail: StoreNotice!

  var imageList = [UIImage]()

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = noticeDetail.title
    createdAtLabel.text = Date.dateFromISO8601String(noticeDetail.createdAt)?.yyyyMMddDot
    contentLabel.text = noticeDetail.content

//    noticeDetail.images = [
//      "https://d3veojcrwtmea8.cloudfront.net/images/stores/d9b2c56f-3a1e-489e-bf18-66225e2ec6e7.jpeg",
//      "https://d3veojcrwtmea8.cloudfront.net/images/stores/41973f9a-8e56-45c0-90a9-20a0bd84d60b.jpeg",
//      "https://d3veojcrwtmea8.cloudfront.net/images/stores/3cd82b65-e093-40bf-b18d-cd19cec4b72f.jpeg",
//      "https://d3veojcrwtmea8.cloudfront.net/images/stores/91ec3754-9b77-4356-860a-1d25fe8657fd.jpeg",
//      "https://d3veojcrwtmea8.cloudfront.net/images/stores/c372bdb0-3a8c-4a9b-9e29-362133001565.jpeg",
//      "https://d3veojcrwtmea8.cloudfront.net/images/stores/7bdc7898-e5f1-4bd2-af00-b170040aa526.jpeg"
//    ]

    getImages()
  }

  func getImages() {
    let observables = (noticeDetail.images ?? []).map { image -> Observable<UIImage> in
      return Observable<UIImage>.create { observer in
        KingfisherManager.shared.retrieveImage(with: URL(string: image)!) { result in
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
        self.imageList.append(image.resizeToWidth(newWidth: UIScreen.main.bounds.width - 40))
      }, onError: { error in
        log.error(error)
      }, onCompleted: {
        log.info("onCompleted")
//        self.tableView.reloadData()
        self.stackView.removeArrangedSubview(self.stackView.arrangedSubviews.first!)
        self.imageList.forEach { image in
          let imageView = UIImageView(image: image)
          imageView.layer.cornerRadius = 10
          self.stackView.addArrangedSubview(imageView)
        }
      }, onDisposed: {
        log.info("onDisposed")
      })
      .disposed(by: disposeBag)
  }
}
