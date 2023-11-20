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
  @IBOutlet weak var timeCollectionView: UICollectionView!
  
  @IBOutlet weak var previousMothButton: UIImageView!
  @IBOutlet weak var nextMonthButton: UIImageView!
  
  @IBOutlet weak var applyButton: UIButton!
  
  @IBOutlet var coupleView: UIView!
  @IBOutlet var coupleUseCheckButton: UIImageView!
  @IBOutlet var coupleUnUseCheckButton: UIImageView!
  weak var delegate: SelectStoreInfoDelegate?
  
  var selectedDate = Date()
  var selectedBedCount = 2
  var selectedTime = Date()
  var storeId: Int?
  var bedList = [Bed]()
  
  var startTime = Date()
  var endTime = Date()
  
  var timeList = [Date]()
  var timeList2 = [ReservationTime]()
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
    if storeId != nil{
      getSchedule()
    }else{
      generateTimeList()
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
    
    previousMothButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { _ in
        self.calendarView.scrollToSegment(.previous)
      })
      .disposed(by: disposeBag)
    
    nextMonthButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { _ in
        self.calendarView.scrollToSegment(.next)
      })
      .disposed(by: disposeBag)
  }
  func getSchedule() {
    APIService.shared.storeAPI.rx.request(.getStoreSchedule(storeId: storeId!, date: selectedDate.yyyyMMdd))
      .filterSuccessfulStatusCodes()
      .map(GetScheduleResponse.self)
      .subscribe(onSuccess: { response in
        self.bedList = response.data
        self.timeList2 = []
        
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date() // 현재 로컬 시간을 가져옵니다.

        var date = calendar.date(from: DateComponents(year: self.selectedDate.year, month: self.selectedDate.month, day: self.selectedDate.day, hour: 0, minute: 0))!
        let endDate = calendar.date(byAdding: .day, value: 1, to: date)!

        var dateList = [Date]()
        while (date < endDate) {
            date.addTimeInterval(60 * 30)
            
            // 시작 날짜가 현재 로컬 시간 이후인 경우에만 추가
            if date >= currentDate {
                dateList.append(date)
            }
        }
        print(self.selectedTime)
        self.timeList2 = dateList.map({ ReservationTime(date: $0, bedCount: 0) })
        self.timeList2 = self.timeList2.filter({$0.date >= self.selectedTime})
        
        let hourCalendar = Calendar.current
        let startHourMinute = calendar.dateComponents([.hour, .minute], from: self.startTime)
        let endHourMinute = calendar.dateComponents([.hour, .minute], from: self.endTime)

        self.timeList2 = self.timeList2.filter { reservationTime in
          let reservationHourMinute = calendar.dateComponents([.hour, .minute], from: reservationTime.date)
          return self.compareDateComponents(lhs: reservationHourMinute, rhs: startHourMinute) && self.compareDateComponents(lhs: endHourMinute, rhs: reservationHourMinute)
        }
        
        response.data.forEach { bed in
          (bed.schedules ?? []).forEach { schedule in
            let date = Date.dateFromISO8601String(schedule.date)!
            if let index = self.timeList2.firstIndex(where: { $0.date.isSameTime(date) }) {
              self.timeList2[index].bedCount += 1
            }
          }
        }
        
        //        self.timeList = self.timeList.filter({ $0.date > Date() })
        self.timeList2.enumerated().forEach({ (index, item) in
          if item.date < Date() {
            self.timeList2[index].bedCount = 0
          }
        })
        self.timeList2 = self.timeList2.filter{$0.bedCount >= self.selectedBedCount}
        self.timeList2.sort(by: { $0.date < $1.date})
        self.timeCollectionView.reloadData()
        
        if let time = self.timeList2.filter({ $0.date > Date() }).first {
          if let index = self.timeList2.firstIndex(where: { $0.date == time.date }) {
            self.timeCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
          }
        }
      }, onFailure: { error in
      })
      .disposed(by: disposeBag)
  }

  func generateTimeList() {
    timeList = []
    var startDate = DateComponents(
      calendar: Calendar.current,
      year: selectedDate.year,
      month: selectedDate.month,
      day: selectedDate.day,
      hour: 0,
      minute: 0,
      second: 0
    ).date!// ?? Date()

    while startDate.day == selectedDate.day {
      timeList.append(startDate)
      startDate.addTimeInterval(60*30)
    }
    timeList = timeList.filter({ $0 > Date() })
    timeList.sort(by: { $0 < $1 })
    timeCollectionView.reloadData()
  }
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
    if storeId != nil{
      getSchedule()
    }else{
      generateTimeList()
    }
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
      if storeId != nil{
        return timeList2.count
      }else{
        return timeList.count
      }
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
      var time: Date?
      if storeId != nil{
        time = timeList2[indexPath.item].date
        }else{
        time = timeList[indexPath.item]
      }
      (cell.viewWithTag(1) as! UILabel).text = time?.ahmm
      if time?.hour == selectedTime.hour && time?.minute == selectedTime.minute {
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
      if storeId != nil{
        getSchedule()
      }
    } else {
    if storeId != nil{
          let currentTime = Date() // 현재 시간
          let oneHourLater = currentTime.addingTimeInterval(3600) // 현재 시간으로부터 1시간 뒤의 시간
          let oneHourTenLater = currentTime.addingTimeInterval(4200) // 현재 시간으로부터 1시간 10분 뒤의 시간
          if self.timeList2[indexPath.item].date >= oneHourLater && self.timeList2[indexPath.item].date <= oneHourTenLater{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "hurryUpPopup") as! OrderOneHourCautionView
            self.present(vc, animated: true)
          } else  if self.timeList2[indexPath.item].date < oneHourLater {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "noResevationPopup") as! NoOrderOneHourView
            self.present(vc, animated: true)
            return
          }
      selectedTime = timeList2[indexPath.item].date
    }else{
      let currentTime = Date() // 현재 시간
      let oneHourLater = currentTime.addingTimeInterval(3600) // 현재 시간으로부터 1시간 뒤의 시간
      let oneHourTenLater = currentTime.addingTimeInterval(4200) // 현재 시간으로부터 1시간 10분 뒤의 시간
      if self.timeList[indexPath.item] >= oneHourLater && self.timeList[indexPath.item] <= oneHourTenLater{
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "hurryUpPopup") as! OrderOneHourCautionView
        self.present(vc, animated: true)
      } else  if self.timeList[indexPath.item] < oneHourLater {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "noResevationPopup") as! NoOrderOneHourView
        self.present(vc, animated: true)
        return
      }
      selectedTime = timeList[indexPath.item]
    }
    }
    collectionView.reloadData()
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 100, height: 40)
  }
}
