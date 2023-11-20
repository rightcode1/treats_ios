import UIKit

extension String {
  func asDate(format: DateFormat, timeZone: TimeZone? = TimeZone.autoupdatingCurrent) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = timeZone
    dateFormatter.dateFormat = format.rawValue
    return dateFormatter.date(from: self)!
  }
}

extension String {
  func validatePhone() -> Bool {
    let regex = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
  }

  func validatePassword() -> Bool {
//    let regex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$"
//    let regex = #"^[0-9a-zA-Z!@#$%^&*()?+-_~=/]{8,40}$"#
    let regex = "^(?=.*[a-zA-Z])(?=.*[0-9])[a-zA-Z0-9!@#$%^&*]{6,40}$"
//    let regex = "^(?=.*[a-z])(?=.*[0-9])[a-z0-9!@#$%^&*]{6,40}$"
    return  NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
  }

  func validateGingerPassword() -> Bool {
    if self.count < 8 || self.count > 20 {
      return false
    } else {
      return true
    }
  }

  func validatePasswordNumber() -> Bool {
    let regex = ".*[0-9]+.*"
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
  }

  func validatePasswordSpeicalCharacter() -> Bool {
    let regex = ".*[^A-Za-z0-9].*"
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
  }

  func validateEmail() -> Bool {
    let emailRegEx = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"#
    return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: self)
  }

  func validateName() -> Bool {
    let nameRegEx = #"^[a-zA-Z가-힣](?!.*?\s{2})[a-zA-Z가-힣]{0,28}[a-zA-Z가-힣]"#
    return NSPredicate(format: "SELF MATCHES %@", nameRegEx).evaluate(with: self)
  }

  func validateBreedName() -> Bool {
    let nameRegEx = #"^[a-zA-Z가-힣](?!.*?\s{2})[a-zA-Z가-힣]{0,28}[a-zA-Z가-힣]"#
    return NSPredicate(format: "SELF MATCHES %@", nameRegEx).evaluate(with: self)
  }

  var splitWithConsonant: String {
    let consonants = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
    return self.reduce(""){ (results, character) in
      let code = Int(String(character).unicodeScalars.reduce(0){ $0 + $1.value }) - 44032
      if code > -1 && code < 11172{
        let consonant = code / 21 / 28
        return results + consonants[consonant]
      }else{
        return results + String(character)
      }
    }
  }

  var insertPhoneHyphen: String {
    if self.count == 11 {
      let i = self.index(self.startIndex, offsetBy: 3)
      let j = self.index(self.startIndex, offsetBy: 8)
      var str = self
      str.insert("-", at: i)
      str.insert("-", at: j)
      return str
    }
    else if self.count == 10 {
      let i = self.index(self.startIndex, offsetBy: 3)
      let j = self.index(self.startIndex, offsetBy: 7)
      var str = self
      str.insert("-", at: i)
      str.insert("-", at: j)
      return str
    }else if self.count == 9 {
      let i = self.index(self.startIndex, offsetBy: 2)
      let j = self.index(self.startIndex, offsetBy: 6)
      var str = self
      str.insert("-", at: i)
      str.insert("-", at: j)
      return str
    }
    return self
  }

  var localized: String{
    return getLocalizedString(for: self)
  }

  var firstUppercased: String{
    guard let first = first else{ return "" }
    return String(first).uppercased() + dropFirst()
  }

  func getLocalizedString(for key: String, with comment: String = "") -> String{
    return NSLocalizedString(key, comment: comment)
  }

  func asUIImage() -> UIImage?{
    let data = Data(base64Encoded: self)
    return UIImage(data: data!)
  }

  func validate(with regex: String) -> Bool{
    return NSPredicate(format: "SELF MATCHES %@" , regex).evaluate(with: self)
  }

  func count(word: String) -> Int{
    return split(separator: " ").reduce(0) { (result, text) in
      guard text == word else{ return result }
      return result + 1
    }
  }

  func replaceToQuery() -> String? {
    return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed.subtracting(CharacterSet(charactersIn: "+")))
  }
}

extension Int {
  func formattedDecimalString() -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    guard let formattedCount = formatter.string(from: self as NSNumber) else {
      return ""
    }
    return formattedCount
  }

  func secondToShowable() -> String {
    let minute = self / 60
    let second = self % 60

    let minuteString: String
    if minute < 10 {
      minuteString = "0\(minute)"
    }else {
      minuteString = "\(minute)"
    }

    let secondsString: String
    if second < 10 {
      secondsString = "0\(second)"
    }else {
      secondsString = "\(second)"
    }
    return "\(minuteString):\(secondsString)"
  }
}
