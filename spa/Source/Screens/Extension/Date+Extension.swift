import Foundation
import UIKit

enum DateFormat: String {
  case meetup = "M'월 'd'일 'a"
  case meetupList = "M월 d일 (E) a h:mm"
  case meetupCreate = "yyyy.MM.dd aa hh:mm"
  case HHmm = "HH:mm"
  case HHmmss = "HH:mm:ss"
  case Mde = "M/d(E)"
  case yyMMdd = "yy:MM:dd"
  case yyMMddDot = "yy. MM. dd"
  case EEEEMMMMddyyyy = "EEEE MMMM dd,yyyy"
  case yyyyMMdd = "yyyy-MM-dd"
  case yyyyMMddDot = "yyyy. MM. dd"
  case yyyyMMddeDot = "yyyy.MM.dd(E)"
  case MMdd = "MM/dd"
  case iso8601 = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
  case iso86012 = "yyyy-MM-dd'T'HH:mm:ss.SS'Z'"
  case yyyyMMddHHmmss = "yyyy-MM-dd' 'HH:mm:ss"
  case yyyyMMddHHmm = "yyyy.MM.dd' 'HH:mm"
  case yyyyMMddKR = "yyyy'년 'M'월 'd'일"
  case MMddE = "MM/dd'('E')'"
  case MMddEKR = "MM월dd일'('E')'"
  case yyyyMMddForWeather = "yyyyMMdd"
  case HHmmForWeather = "HHmm"
  case yearWeek = "yyyyw"
  case ahmm = "a' 'h':'mm"
  case ahhmm = "a' 'hh':'mm"
}

enum TimeZoneFormat: String {
  case Locale
  case UTC = "UTC"
  case KST = "Asia/Seoul"

  func getTimeZone() -> TimeZone {
    return (self == .Locale) ? .autoupdatingCurrent : TimeZone(identifier: self.rawValue)!
  }
}

extension Date{
  var meetup: String {
    return asString(format: .meetup)
  }
  var meetupList: String {
    return asString(format: .meetupList)
  }
  var meetupCreate: String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    dateFormatter.dateFormat = DateFormat.meetupCreate.rawValue
    dateFormatter.locale = Locale(identifier: "en_US")
    return dateFormatter.string(from: self)
  }
  var HHmm: String{
    return asString(format: .HHmm)
  }
  var HHmmss: String{
    return asString(format: .HHmmss)
  }
  var Mde: String {
    return asString(format: .Mde)
  }
  var yyMMdd: String{
    return asString(format: .yyMMdd)
  }
  var yyMMddDot: String {
    return asString(format: .yyMMddDot)
  }
  var EEEEMMMMddyyyy: String{
    return asString(format: .EEEEMMMMddyyyy)
  }
  var yyyyMMdd: String{
    return asString(format: .yyyyMMdd)
  }

  var yyyyMMddDot: String {
    return asString(format: .yyyyMMddDot)
  }

  var yyyyMMddeDot: String {
    return asString(format: .yyyyMMddeDot)
  }
  
  var MMddHHmm: String{
    return asString(format: .MMdd)
  }
  
  var yyyyMMddHHmmss: String {
    return asString(format: .yyyyMMddHHmmss)
  }
  
  var yyyyMMddHHmm: String {
    return asString(format: .yyyyMMddHHmm)
  }

  var yyyyMMddKR: String {
    return asString(format: .yyyyMMddKR)
  }

  var MMddE: String {
    return asString(format: .MMddE)
  }

  var MMddEKR: String {
    return asString(format: .MMddEKR)
  }

  var yyyyMMddForWeather: String {
    return asString(format: .yyyyMMddForWeather)
  }

  var HHmmForWeather: String {
    return asString(format: .HHmmForWeather)
  }

  var yearWeek: String {
    return asString(format: .yearWeek)
  }

  var ahmm: String {
    return asString(format: .ahmm)
  }

  var ahhmm: String {
    return asString(format: .ahhmm)
  }

  var calendar: Calendar{
    return Calendar(identifier: .gregorian)
  }

  var year: Int{
    return calendar.component(.year, from: self)
  }

  var month: Int{
    return calendar.component(.month, from: self)
  }

  var day: Int{
    return calendar.component(.day, from: self)
  }

  var hour: Int {
    return calendar.component(.hour, from: self)
  }

  var minute: Int {
    return calendar.component(.minute, from: self)
  }

  func asString(format: DateFormat, timeZone: TimeZone? = TimeZone.autoupdatingCurrent) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = timeZone
    dateFormatter.dateFormat = format.rawValue
    dateFormatter.locale = Locale(identifier: "ko_KR")
    return dateFormatter.string(from: self)
  }
  
  var asISO8601String: String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    dateFormatter.dateFormat = DateFormat.iso8601.rawValue
    return dateFormatter.string(from: self)
  }
  
  static func dateFromISO8601String(_ string: String?) -> Date?{
    guard let string = string else{ return nil }
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    dateFormatter.dateFormat = DateFormat.iso8601.rawValue
    return dateFormatter.date(from: string)
  }

  static func dateFromISO8601String2(_ string: String?) -> Date?{
    guard let string = string else{ return nil }
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    dateFormatter.dateFormat = DateFormat.iso86012.rawValue
    return dateFormatter.date(from: string)
  }

  static func dateFromString(_ string: String, dateFormat: DateFormat, timeZone: TimeZone? = TimeZone(identifier: "UTC")) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = timeZone
    dateFormatter.dateFormat = dateFormat.rawValue
    return dateFormatter.date(from: string)!
  }
  
  func detailTime() -> String {
    let calendar = Calendar(identifier: .gregorian)
    
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())
    if components.year == 0 {
      if components.day == 0 {
        return "\(components.hour?.formattedDecimalString() ?? "")시간"
      } else {
        return "\(components.day?.formattedDecimalString() ?? "")일 전"
      }
    } else {
      return self.yyyyMMdd
    }
  }

  func getBirthString() -> String {
    let date1 = DateComponents(calendar: .current, year: self.year, month: self.month, day: self.day).date!
    let date2 = DateComponents(calendar: .current, year: Date().year, month: Date().month, day: Date().day).date!

    let years = date2.years(from: date1)
    let months = date2.months(from: date1) % 12
    let days = date2.days(from: date1)

    if years == 0 && months == 0 {
      return "\(days)일"
    } else {
      if years == 0 {
        return "\(months)개월"
      } else {
        if months == 0 {
          return"\(years)년"
        } else {
          return "\(years)년 \(months)개월"
        }
      }
    }
  }

  static func generateDateRange(_ calendar: Calendar = Calendar.current, from startDate: Date, to endDate: Date) -> [Date] {
    if startDate > endDate { return [] }
    var returnDates: [Date] = []
    var currentDate = startDate
    repeat {
      returnDates.append(currentDate)
      currentDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
    } while currentDate <= endDate
    return returnDates
  }

  func getYearWeek() -> String {
    let calendar = Calendar(identifier: .iso8601)
    let year = calendar.component(.year, from: self)
    let weekOfYear = calendar.component(.weekOfYear, from: self)
    return "\(year)\(weekOfYear < 10 ? "0\(weekOfYear)" : "\(weekOfYear)")"
  }

  func isSameDay(_ date: Date) -> Bool {
    let date1Components = calendar.dateComponents([.year, .month, .day], from: self)
    let date2Components = calendar.dateComponents([.year, .month, .day], from: date)

    let isSameYear = date1Components.year == date2Components.year
    let isSameMonth = date1Components.month == date2Components.month
    let isSameDay = date1Components.day == date2Components.day

    return isSameYear && isSameMonth && isSameDay
  }

  func isSameTime(_ date: Date) -> Bool {
    let date1Components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
    let date2Components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

    let isSameYear = date1Components.year == date2Components.year
    let isSameMonth = date1Components.month == date2Components.month
    let isSameDay = date1Components.day == date2Components.day
    let isSameHour = date1Components.hour == date2Components.hour
    let isSameMinute = date1Components.minute == date2Components.minute
    

    return isSameYear && isSameMonth && isSameDay && isSameHour && isSameMinute
  }

  /// Returns the amount of years from another date
  func years(from date: Date) -> Int {
    return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
  }
  /// Returns the amount of months from another date
  func months(from date: Date) -> Int {
    return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
  }
  /// Returns the amount of weeks from another date
  func weeks(from date: Date) -> Int {
    return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
  }
  /// Returns the amount of days from another date
  func days(from date: Date) -> Int {
    return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
  }
  /// Returns the amount of hours from another date
  func hours(from date: Date) -> Int {
    return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
  }
  /// Returns the amount of minutes from another date
  func minutes(from date: Date) -> Int {
    return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
  }
  /// Returns the amount of seconds from another date
  func seconds(from date: Date) -> Int {
    return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
  }
  /// Returns the a custom time interval description from another date
  func offset(from date: Date) -> String {
    if years(from: date)   > 0 { return "\(years(from: date))y"   }
    if months(from: date)  > 0 { return "\(months(from: date))M"  }
    if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
    if days(from: date)    > 0 { return "\(days(from: date))d"    }
    if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
    if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
    if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
    return ""
  }

  func getWeekends() -> (Date, Date) {
    let calendar = Calendar.current

    let todayWeekday = calendar.component(.weekday, from: self)

    let addWeekdays = 7 - todayWeekday
    var components = DateComponents()
    components.weekday = addWeekdays

    let nextSaturday = calendar.date(byAdding: components, to: self)
    components.weekday = addWeekdays + 1
    let nextSunday = calendar.date(byAdding: components, to: self)

    return (nextSaturday ?? self, nextSunday ?? self)
  }
}
