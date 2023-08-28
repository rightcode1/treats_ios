//
//  StoreEditorReviewCell.swift
//  spa
//
//  Created by 이동석 on 2023/01/09.
//

import UIKit

protocol storeEditProtocol{
  func didSelectStoreEdit(url: URL)
}
class StoreEditorReviewCell: UITableViewCell {
  @IBOutlet var collectionView: UICollectionView!

  var editorReviewList = [EditorReview]()
  var delegate: storeEditProtocol?

  override func awakeFromNib() {
    super.awakeFromNib()

    collectionView.dataSource = self
    collectionView.delegate = self
  }
}

extension StoreEditorReviewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return editorReviewList.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    let editorReview = editorReviewList[indexPath.item]

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
      cell.viewWithTag(4)?.applyGradient(colors: [.clear, UIColor(hex: "#00090b")])
    }

    (cell.viewWithTag(1) as! UIImageView).kf.setImage(with: URL(string: editorReview.thumbnail)!)
    (cell.viewWithTag(2) as! UILabel).text = editorReview.title
    (cell.viewWithTag(3) as! UILabel).text = editorReview.author

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let url = URL(string: editorReviewList[indexPath.item].url) {
      delegate?.didSelectStoreEdit(url: url)
    }
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width - 40, height: 183)
  }
}
