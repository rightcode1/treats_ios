//
//  SelectCategoryViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/04.
//

import UIKit

protocol SelectCategoryDelegate: AnyObject {
  func didSelectCategory(parentCategory: Category?, childCategory: Category?, isParent: Bool)
}

class SelectCategoryViewController: BaseViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

  @IBOutlet weak var sheetView: UIView!
  @IBOutlet weak var applyButton: UIButton!

  weak var delegate: SelectCategoryDelegate?

  var isParent = true
  var categoryList = [Category?]()

  var selectedParentCategory: Category?
  var selectedChildCategory: Category?

  override func viewDidLoad() {
    super.viewDidLoad()

    if !isParent {
      categoryList = selectedParentCategory?.children ?? []
    }

    categoryList.insert(nil, at: 0)

    sheetView.layer.cornerRadius = 10
    sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

    bindInput()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    collectionViewHeightConstraint.constant = collectionView.contentSize.height
  }

  func bindInput() {
    applyButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.dismiss(animated: false) {
          self.delegate?.didSelectCategory(
            parentCategory: self.selectedParentCategory,
            childCategory: self.selectedChildCategory,
            isParent: self.isParent
          )
        }
      })
      .disposed(by: disposeBag)
  }
}

extension SelectCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return categoryList.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    let textLabel = cell.viewWithTag(1) as! UILabel

    let category = categoryList[indexPath.item]
    let selectedCategory = isParent ? selectedParentCategory : selectedChildCategory

    let isSelected = category?.id == selectedCategory?.id

    textLabel.text = category?.name ?? "전체"

    cell.borderColor = isSelected ? .black : UIColor(hex: "#c6c6c8")
    textLabel.textColor = isSelected ? .black : UIColor(hex: "#2d2d2d")

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if isParent {
      selectedParentCategory = categoryList[indexPath.item]
    } else {
      selectedChildCategory = categoryList[indexPath.item]
    }

    collectionView.reloadData()
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (UIScreen.main.bounds.width - 50) / 2
    return CGSize(width: width, height: 40)
  }
}
