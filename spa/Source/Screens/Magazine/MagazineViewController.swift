//
//  MagazineViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/01.
//

import UIKit

class MagazineViewController: BaseViewController {
  @IBOutlet weak var tableView: UITableView!

  var magazineList = [Journal]()

  override func viewDidLoad() {
    super.viewDidLoad()

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    getMagazineList()
  }

  func getMagazineList() {
    let param = ListRequest(start: 0, perPage: 50)
    APIService.shared.commonAPI.rx.request(.getJournalList(param: param))
      .map(ListResponse<Journal>.self)
      .subscribe(onSuccess: { response in
        self.magazineList = response.data
        self.tableView.reloadData()
      }, onFailure: { error in
        log.error(error)
      })
      .disposed(by: disposeBag)
  }
}

extension MagazineViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return magazineList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let magazine = magazineList[indexPath.row]

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
      cell.viewWithTag(2)?.applyGradient(colors: [.clear, UIColor(hex: "#00090b")])
    }

    (cell.viewWithTag(1) as! UIImageView).kf.setImage(with: URL(string: magazine.thumbnail)!)
    (cell.viewWithTag(3) as! UILabel).text = magazine.subtitle
    (cell.viewWithTag(4) as! UILabel).text = magazine.title

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = UIStoryboard(name: "Magazine", bundle: nil).instantiateViewController(withIdentifier: "magazineDetail") as! MagazineDetailViewController
    vc.magazine = magazineList[indexPath.row]
    navigationController?.pushViewController(vc, animated: true)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 250
  }
}
