//
//  HomeAroundStoreCell.swift
//  spa
//
//  Created by 이동석 on 2023/01/15.
//

import UIKit

class HomeAroundStoreCell: UITableViewCell {
  @IBOutlet var collectionView: UICollectionView!

  var categoryList = [String]()

  override func awakeFromNib() {
    super.awakeFromNib()

    collectionView.dataSource = self
    collectionView.delegate = self
  }
}

extension HomeAroundStoreCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return categoryList.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

    (cell.viewWithTag(1) as! UILabel).text = categoryList[indexPath.item]

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let font = UIFont.systemFont(ofSize: 12)
    let fontAttributes = [NSAttributedString.Key.font: font]
    let text = categoryList[indexPath.item] as NSString
    return CGSize(width: text.size(withAttributes: fontAttributes).width + 16, height: 21)
  }
}
