//
//  MagazineDetailViewController.swift
//  spa
//
//  Created by 이동석 on 2022/12/07.
//

import UIKit
import Kingfisher
import RxSwift

class MagazineDetailViewController: BaseViewController {
  @IBOutlet var tableView: UITableView!

  @IBOutlet var titleLabel: UILabel!
  
  var magazine: Journal!
  var imageList = [UIImage]()
  var allImageList = [String]()

  override func viewDidLoad() {
    super.viewDidLoad()
    titleLabel.text = magazine.title
    tableView.register(UINib(nibName: "JournalCell", bundle: nil), forCellReuseIdentifier: "cell")
    convertImagesToUIImages()
  }

  func getImages() {
      let observables = magazine.contents.compactMap { content -> Observable<UIImage>? in
          guard let imageURLString = content.image, !imageURLString.isEmpty,
                let imageURL = URL(string: imageURLString) else {
            imageList.append(UIImage())
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
              self.imageList.append(image)
              self.allImageList.append("yesImage")
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
  
  func convertImagesToUIImages(){
    for content in magazine.contents {
      if let imageString = content.image,
             let imageURL = URL(string: imageString),
             let imageData = try? Data(contentsOf: imageURL),
             let uiImage = UIImage(data: imageData) {
              let image = uiImage.resizeToWidth(newWidth: UIScreen.main.bounds.width)
              imageList.append(image)
              allImageList.append("yesImage")
          } else {
            imageList.append(UIImage())
            allImageList.append("noImage")
          }
      }
  }
}

extension MagazineDetailViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return magazine.contents.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! JournalCell
    if imageList[indexPath.row] == UIImage(){
      cell.contentImageView.isHidden = true
    }else{
      cell.contentImageView.isHidden = false
      cell.contentImageView.image = imageList[indexPath.row]
      cell.contentImageHeightConstraint.constant = imageList[indexPath.row].size.height
    }
    
    if magazine.contents[indexPath.row].title == nil{
      cell.titleLabel.isHidden = true
    }else{
      cell.titleLabel.isHidden = false
      cell.titleLabel.text = magazine.contents[indexPath.row].title
    }
    
    if magazine.contents[indexPath.row].subtitle == nil{
      cell.subtitleLabel.isHidden = true
    }else{
      cell.subtitleLabel.isHidden = false
      cell.subtitleLabel.text = magazine.contents[indexPath.row].subtitle
    }
    if magazine.contents[indexPath.row].description == nil{
      cell.descriptionLabel.isHidden = true
    }else{
      cell.descriptionLabel.isHidden = false
      cell.descriptionLabel.text = magazine.contents[indexPath.row].description
    }
    

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}
