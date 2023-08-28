//
//  SelectStoreInfoViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/15.
//

import UIKit
import JTAppleCalendar

protocol SelectStoreInfoDelegate: AnyObject {
  func didApplyFilter(date: Date, bedCount: Int, time: Date, isCouple: Bool?)
}

class SelectStoreInfoViewController: BaseViewController {
  @IBOutlet weak var calendarView: JTACMonthView!
  @IBOutlet weak var currentMonthLabel: UILabel!
  @IBOutlet weak var bedCountCollectionView: UICollectionView!
  @IBOutlet weak var applyButton: UIButton!
  
  @IBOutlet var coupleView: UIView!
  @IBOutlet var coupleUseCheckButton: UIImageView!
  @IBOutlet var coupleUnUseCheckButton: UIImageView!
  weak var delegate: SelectStoreInfoDelegate?
  
  var selectedDate = Date()
  var selectedBedCount = 2
  var selectedTime = Date()
  
  var timeList = [Date]()
  var isCouple : Bool = false{
    didSet{
      if isCouple == true{
        coupleUseCheckButton.image = UIImage(named: "iconCheckOn")
        coupleUnUseCheckButton.image = UIImage(named: "iconCheckOff")
      }else{
        coupleUseCheckButton.image = UIImage(named: "iconCheckOff")
        coupleUnUseCheckButton.image = UIImage(named: "iconCheckOn")
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    calendarView.ibCalendarDelegate = self
    calendarView.ibCalendarDataSource = self

    calendarView.visibleDates { [weak self] visibleDates in
      guard let self = self, let startDate = visibleDates.monthDates.first?.date else { return }
      self.currentMonthLabel.text = "\(startDate.year). \(startDate.month)"
    }
    applyButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.delegate?.didApplyFilter(date: self.selectedDate, bedCount: self.selectedBedCount, time: self.selectedTime, isCouple: self.isCouple)
        self.dismiss(animated: true) {}
      })
      .disposed(by: disposeBag)
    coupleUseCheckButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { _ in
        self.isCouple = true
      })
      .disposed(by: disposeBag)
    coupleUnUseCheckButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { _ in
        self.isCouple = false
      })
      .disposed(by: disposeBag)
  }
//
//  func generateTimeList() {
//    timeList = []
//    var startDate = DateComponents(
//      calendar: Calendar.current,
//      year: selectedDate.year,
//      month: selectedDate.month,
//      day: selectedDate.day,
//      hour: 0,
//      minute: 0,
//      second: 0
//    ).date!// ?? Date()
//
//    while startDate.day == selectedDate.day {
//      timeList.append(startDate)
//      startDate.addTimeInterval(60*30)
//    }
//    timeList = timeList.filter({ $0 > Date() })
//    timeList.sort(by: { $0 < $1 })
//    timeCollectionView.reloadData()
//  }
}

extension SelectStoreInfoViewController: JTACMonthViewDataSource, JTACMonthViewDelegate {
  func configureCalendar(_ calendar: JTAppleCalendar.JTACMonthView) -> JTAppleCalendar.ConfigurationParameters {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy MM dd"
    let startDate = formatter.date(from: "2024 01 01")!
    return ConfigurationParameters(startDate: Date(), endDate: startDate)
  }

  func calendar(_ calendar: JTAppleCalendar.JTACMonthView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTACDayCell {
    let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath)
    
    (cell.viewWithTag(1) as! UILabel).text = cellState.text
    if date < Date().addingTimeInterval(-60*60*24) {
      (cell.viewWithTag(1) as! UILabel).textColor = .lightGray
      cell.viewWithTag(2)?.isHidden = true
    } else {
      if selectedDate.year == date.year && selectedDate.month == date.month && selectedDate.day == date.day {
        (cell.viewWithTag(1) as! UILabel).textColor = .white
        cell.viewWithTag(2)?.isHidden = false
      } else {
        (cell.viewWithTag(1) as! UILabel).textColor = .black
        cell.viewWithTag(2)?.isHidden = true
      }
    }

    return cell
  }

  func calendar(_ calendar: JTAppleCalendar.JTACMonthView, willDisplay cell: JTAppleCalendar.JTACDayCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
    (cell.viewWithTag(1) as! UILabel).text = cellState.text
  }

  func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
    selectedDate = date
    calendarView.reloadData()
//    generateTimeList()
  }

  func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
    if let date = visibleDates.monthDates.first?.date {
      currentMonthLabel.text = "\(date.year). \(date.month)"
    }
  }
}

extension SelectStoreInfoViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == bedCountCollectionView {
      return 4
    } else {
      return timeList.count
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == bedCountCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      (cell.viewWithTag(1) as! UILabel).text = "\(indexPath.item+1)명"
      if selectedBedCount == indexPath.item+1 {
        cell.borderColor = .black
      } else {
        cell.borderColor = UIColor(hex: "#c6c6c8")
      }
//      if selectedBedCount == 1{
//        coupleView.isHidden = true
//      }else{
//        coupleView.isHidden = false
//      }
      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      let time = timeList[indexPath.item]
      (cell.viewWithTag(1) as! UILabel).text = time.ahmm
      if time.hour == selectedTime.hour && time.minute == selectedTime.minute {
        cell.borderColor = .black
      } else {
        cell.borderColor = UIColor(hex: "#c6c6c8")
      }

      return cell
    }
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == bedCountCollectionView {
      selectedBedCount = indexPath.item+1
    } else {
      selectedTime = timeList[indexPath.item]
    }

    collectionView.reloadData()
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 100, height: 40)
  }
}
