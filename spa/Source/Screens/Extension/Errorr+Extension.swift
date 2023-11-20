import Foundation
import Moya

extension Error {
  var moyaError: MoyaError? {
    get {
      return self as? MoyaError
    }
  }

  var serverMessage: String? {
    get {
      return ((try? moyaError?.response?.mapJSON()) as? [String: Any])?["message"] as? String
    }
  }
}
