//
//  APIService.swift
//  ginger9
//
//  Created by jason on 2021/04/20.
//

import Foundation
import Moya

final class APIService {

  static let shared = APIService()

  var authAPI = MoyaProvider<AuthAPI>()
  var userAPI = MoyaProvider<UserAPI>()
  var homeAPI = MoyaProvider<HomeAPI>()
  var storeAPI = MoyaProvider<StoreAPI>()
  var productAPI = MoyaProvider<ProductAPI>()
  var orderAPI = MoyaProvider<OrderAPI>()
  var reviewAPI = MoyaProvider<ReviewAPI>()
  var couponAPI = MoyaProvider<CouponAPI>()
  var brandAPI = MoyaProvider<BrandAPI>()
  var commonAPI = MoyaProvider<CommonAPI>()
  var kakaoAPI = MoyaProvider<KakaoAPI>()

  private init() {
    let networkLoggerPlugin = NetworkLoggerPlugin(configuration: .init(formatter: .init(entry: { (string1, string2, targetType) -> String in
      if string1 != "Response" {
        return "[\(string1)] \(string2)"
      }
      return "Response"
    }, requestData: { data -> (String) in
      return (data.prettyPrintedJSONString as String?) ?? ""
    }, responseData: { data -> (String) in
      return (data.prettyPrintedJSONString as String?) ?? ""
    }), output: { (targetType, stringList) in
      print("------------------------------------------------------------")
      stringList.forEach { if $0 != "Response" { print($0) } }
      print("------------------------------------------------------------")
    }, logOptions: [.verbose]))

    let networkActivityPlugin = NetworkActivityPlugin { (networkActivityChangeType, targetType) in
      switch networkActivityChangeType {
      case .began: break
      case .ended: break
      }
    }

    authAPI = MoyaProvider<AuthAPI>(plugins: [networkLoggerPlugin, networkActivityPlugin])
    userAPI = MoyaProvider<UserAPI>(plugins: [networkLoggerPlugin, networkActivityPlugin])
    homeAPI = MoyaProvider<HomeAPI>(plugins: [networkLoggerPlugin, networkActivityPlugin])
    storeAPI = MoyaProvider<StoreAPI>(plugins: [networkLoggerPlugin, networkActivityPlugin])
    productAPI = MoyaProvider<ProductAPI>(plugins: [networkLoggerPlugin, networkActivityPlugin])
    orderAPI = MoyaProvider<OrderAPI>(plugins: [networkLoggerPlugin, networkActivityPlugin])
    reviewAPI = MoyaProvider<ReviewAPI>(plugins: [networkLoggerPlugin, networkActivityPlugin])
    couponAPI = MoyaProvider<CouponAPI>(plugins: [networkLoggerPlugin, networkActivityPlugin])
    brandAPI = MoyaProvider<BrandAPI>(plugins: [networkLoggerPlugin, networkActivityPlugin])
    commonAPI = MoyaProvider<CommonAPI>(plugins: [networkLoggerPlugin, networkActivityPlugin])
    kakaoAPI = MoyaProvider<KakaoAPI>(plugins: [networkLoggerPlugin, networkActivityPlugin])
  }
}
