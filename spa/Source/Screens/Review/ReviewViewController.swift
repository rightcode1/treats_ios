//
//  ReviewViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/01.
//

import UIKit
import RxSwift

enum ReviewOrder: String, Codable {
  case recent
  case highstRated
  case lowestRated
}

class ReviewViewController: BaseViewController {
  @IBOutlet weak var tableView: UITableView!

  @IBOutlet var searchTextField: UITextField!

  @IBOutlet weak var parentCategoryView: UIView!
  @IBOutlet weak var parentCategoryLabel: UILabel!

  @IBOutlet weak var childCategoryView: UIView!
  @IBOutlet weak var childCategoryLabel: UILabel!

  @IBOutlet var orderLabel: UILabel!
  @IBOutlet var orderButton: UIButton!

  @IBOutlet weak var totalLabel: UILabel!
  @IBOutlet var photoButton: UIButton!
  
  var categoryList = [Category]()
  var selectedParentCategory: Category?
  var selectedChildCategory: Category?

  var reviewList = [Review]()

  let photo = BehaviorSubject<Bool>(value: false)
  let order = BehaviorSubject<ReviewOrder>(value: .recent)

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "cell")

    childCategoryView.isHidden = true
    
    
    getCategoryList()
    bindInput()
    bindOutput()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    getReviewList()
  }

  func bindInput() {
    parentCategoryView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "selectCategory") as! SelectCategoryViewController
        vc.delegate = self
        vc.categoryList = self.categoryList
        vc.selectedParentCategory = self.selectedParentCategory
        vc.isParent = true
        self.present(vc, animated: false)
      })
      .disposed(by: disposeBag)

    childCategoryView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "selectCategory") as! SelectCategoryViewController
        vc.delegate = self
        vc.categoryList = self.categoryList
        vc.selectedParentCategory = self.selectedParentCategory
        vc.selectedChildCategory = self.selectedChildCategory
        vc.isParent = false
        self.present(vc, animated: false)
      })
      .disposed(by: disposeBag)

    orderButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let recent = UIAlertAction(title: "최신순", style: .default) { action in
          self.order.onNext(.recent)
        }
        alert.addAction(recent)

        let highstRated = UIAlertAction(title: "높은 평점순", style: .default) { action in
          self.order.onNext(.highstRated)
        }
        alert.addAction(highstRated)

        let lowestRated = UIAlertAction(title: "낮은 평점순", style: .default) { action in
          self.order.onNext(.lowestRated)
        }
        alert.addAction(lowestRated)

        let cancel = UIAlertAction(title: "취소", style: .cancel) { action in
          self.order.onNext(.lowestRated)
        }
        alert.addAction(cancel)

        self.present(alert, animated: true)
      })
      .disposed(by: disposeBag)

    photoButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.photo.onNext(!(try! self.photo.value()))
        self.getReviewList()
      })
      .disposed(by: disposeBag)
  }

  func bindOutput() {
    photo.bind(onNext: { [weak self] b in
      guard let self = self else { return }
      let image = b ? UIImage(named: "iconCheckOn") : UIImage(named: "iconCheckOff")
      self.photoButton.setImage(image, for: .normal)
    })
    .disposed(by: disposeBag)

    order
      .distinctUntilChanged().bind(onNext: { [weak self] order in
        guard let self = self else { return }
        switch order {
        case .recent:
          self.orderLabel.text = "최신순"
        case .highstRated:
          self.orderLabel.text = "높은 평점순"
        case .lowestRated:
          self.orderLabel.text = "낮은 평점순"
        }

        self.getReviewList()
      })
      .disposed(by: disposeBag)

    searchTextField.rx.controlEvent(.editingDidEnd)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.getReviewList()
      })
      .disposed(by: disposeBag)
  }

  func getCategoryList() {
    APIService.shared.storeAPI.rx.request(.getCategoryList)
      .map(GetCategoryListResponse.self)
      .subscribe(onSuccess: { response in
        self.categoryList = response.data
      }, onFailure: { error in
        log.error(error)
      })
      .disposed(by: disposeBag)
  }

  func getReviewList() {
    let param = GetReviewListRequest(
      start: 0,
      perPage: 20,
      categoryId: selectedChildCategory?.id ?? selectedParentCategory?.id,
      order: try! order.value(),
      photo: try! photo.value(),
      search: searchTextField.text!.isEmpty ? nil : searchTextField.text!
    )
    APIService.shared.reviewAPI.rx.request(.getReviewList(query: param))
      .map(ListResponse<Review>.self)
      .subscribe(onSuccess: { response in
          self.reviewList = response.data
        self.tableView.reloadData()

        self.totalLabel.text = "총 \(response.total.formattedDecimalString())개의 리뷰"
      }, onFailure: { error in
        log.error(error)
      })
      .disposed(by: disposeBag)
  }
}

extension ReviewViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reviewList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReviewCell
    let review = reviewList[indexPath.row]
    cell.initWithReview(review)
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

extension ReviewViewController: SelectCategoryDelegate {
  func didSelectCategory(parentCategory: Category?, childCategory: Category?, isParent: Bool) {
    selectedParentCategory = parentCategory
    selectedChildCategory = childCategory
    if isParent {
      selectedChildCategory = nil
      parentCategoryLabel.text = parentCategory?.name ?? "전체"
      childCategoryView.isHidden = (parentCategory?.children ?? []).isEmpty
      childCategoryLabel.text = "전체"
    } else {
      childCategoryLabel.text = childCategory?.name ?? "전체"
    }
    getReviewList()
  }
}
