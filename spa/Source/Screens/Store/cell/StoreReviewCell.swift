//
//  StoreReviewCell.swift
//  spa
//
//  Created by 이동석 on 2022/12/07.
//

import UIKit
import FSPagerView

class StoreReviewCell: UITableViewCell {

//  @IBOutlet weak var storeImageView: UIImageView!
//  @IBOutlet weak var storeAddressLabel: UILabel!
//  @IBOutlet weak var storeNameLabel: UILabel!
//  @IBOutlet weak var productNameLabel: UILabel!

  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var noImageView: UIView!
  @IBOutlet weak var bannerPagerView: FSPagerView!
  @IBOutlet weak var pageLabel: UILabel!
  @IBOutlet weak var createdAtLabel: UILabel!
  @IBOutlet var productNameLabel: UILabel!

  @IBOutlet var commenctUser: UILabel!
  @IBOutlet var commentLabel: UIView!
  @IBOutlet var commecntContent: UILabel!
  
  var imageList: [String] = []
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  func initWithReview(_ review: Review) {
    imageList = review.images
    self.pageLabel.text = "1/\(review.images.count)"
    
    if !imageList.isEmpty{
      bannerPagerView.delegate = self
      bannerPagerView.dataSource = self
      bannerPagerView.register(UINib(nibName: "ReviewPagerCell", bundle: nil), forCellWithReuseIdentifier: "cell2")
      bannerPagerView.itemSize = FSPagerView.automaticSize
      bannerPagerView.interitemSpacing = 0
      bannerPagerView.backgroundView?.backgroundColor = .clear
      bannerPagerView.inputView?.clipsToBounds = false
    }else{
      noImageView.isHidden = true
    }
    
//    storeImageView.kf.setImage(with: URL(string: review.storeTitleImage)!)
//    storeAddressLabel.text = review.storeAddress
//    storeNameLabel.text = review.storeName
    productNameLabel.text = review.productName
    if let url = URL(string: review.userProfileImage ?? "") {
      userImageView.kf.setImage(with: url, placeholder: UIImage(named: "profileDefault"))
    } else {
      userImageView.image = UIImage(named: "profileDefault")
    }
    userNameLabel.text = review.userName
    ratingLabel.text = String(review.rating)
    descriptionLabel.text = review.description
    
    if review.comment != nil{
      commentLabel.isHidden = false
      commenctUser.text = review.storeName
      commecntContent.text = review.comment
    }else{
      commentLabel.isHidden = true
    }
    
    createdAtLabel.text = Date.dateFromISO8601String(review.createdAt)?.yyyyMMddDot
  }

}

extension StoreReviewCell: FSPagerViewDataSource, FSPagerViewDelegate {
  func numberOfItems(in pagerView: FSPagerView) -> Int {
    return imageList.count
  }

  func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
    let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell2", at: index) as! ReviewPagerCell

    let banner = imageList[index]

    if let url = URL(string: banner) {
      cell.bannerImageView.kf.setImage(with: url)
    } else {
      cell.bannerImageView.image = nil
    }
    return cell
  }
  func pagerViewDidScroll(_ pagerView: FSPagerView) {
    pageLabel.text = "\(pagerView.currentIndex+1)/\(imageList.count)"
  }
}
