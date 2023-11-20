import Foundation
import RxSwift
import RxCocoa
import Moya
import CoreData
import FirebaseAnalytics

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
  // MARK: - Filter Token Expired Error
  private func filter401StatusCode() -> Single<Response> {
    return flatMap {
      if $0.statusCode == 401 {
        throw MoyaError.statusCode($0)
      } else {
        return .just($0)
      }
    }
  }

  // MARK: - Renewal Token (StatusCode == 401 => Token Refresh & Retry)
//  func retryWithAuthIfNeeded() -> Single<Response> {
//    // Filter Not SignIn
////    guard DataHelperTool.accessToken != nil || DataHelperTool.refreshToken != nil else {
////      DataHelper<Any>.clearAll()
////      let vc = UIStoryboard(name: "Onboard", bundle: nil).instantiateInitialViewController()
////
////      (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc
////      return Single.error(NSError(domain: "noAccessOrRefreshToken", code: 401, userInfo: nil))
////    }
//
//    return filter401StatusCode().catch { tokenExpiredError in
//      APIService.shared.authAPI.rx.request(.refreshToken)
//        .filterSuccessfulStatusCodes()
//        .catch { refreshTokenError in
//          if (refreshTokenError as! MoyaError).response?.statusCode == 401 {
//            Analytics.setUserID(nil)
//            DataHelper<Any>.clearAll()
//            let vc = UIStoryboard(name: "Onboard", bundle: nil).instantiateInitialViewController()
//            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc
//          }
//          return Single.error(refreshTokenError)
//        }.flatMap { response -> Single<Response> in
//          if let token = try? response.map(RefreshTokenResponse.self) {
//            DataHelper<String>.set(token.accessToken, forKey: .accessToken)
//          }
//          return Single.error(tokenExpiredError)
//        }
//    }.retry(2)
//  }

  func catchErrorResponse(statusCode: Int, message: String? = nil, errorDescription: String) -> Single<Element> {
    return flatMap { response in
      let containStatusCode: Bool = {
        return response.statusCode == statusCode
      }()
      let containMessage: Bool? = {
        guard let message = message else { return nil }
        guard let json = try? response.mapJSON() as? [String: Any], let jsonMessage = json.first(where: { $0.key == "message" })?.value as? String, jsonMessage == message else { return false }
        return true
      }()

      if containStatusCode && (containMessage ?? true) {
        throw NSError(domain: response.request?.url?.absoluteString ?? "Unknown URL", code: response.statusCode, userInfo: ["errorDescription": errorDescription])
      } else {
        return .just(response)
      }
    }
  }
}

// MARK: - Handle Loading
extension Observable where Element: Any {
  func startLoading(loadingSubject: BehaviorSubject<Bool>) -> Observable<Element> {
    return self.do(onNext: { _ in loadingSubject.onNext(true) })
  }

  func stopLoading(loadingSubject: BehaviorSubject<Bool>) -> Observable<Element> {
    return self.do(onNext: { _ in loadingSubject.onNext(false) })
  }

  func startLoading(_ loadingSubject: BehaviorRelay<Bool>) -> Observable<Element> {
    return self.do(onNext: { _ in loadingSubject.accept(true) })
  }

  func stopLoading(_ loadingSubject: BehaviorRelay<Bool>) -> Observable<Element> {
    return self.do(onNext: { _ in loadingSubject.accept(false) })
  }
}
