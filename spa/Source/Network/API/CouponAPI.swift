import Foundation
import Moya

enum CouponAPI {
  case downloadCoupon(id: Int)
  case getCouponList(param: GetCouponListReq)
}

extension CouponAPI: TargetType {
  public var baseURL: URL {
    return URL(string: Environment.baseUrl)!
  }

  var path: String {
    switch self {
    case .downloadCoupon(let id):
      return "/coupons/\(id)"
    case .getCouponList:
      return "/coupons"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getCouponList:
      return .get
    case .downloadCoupon:
      return .post
    }
  }

  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }

  var task: Task {
    switch self {
    case .getCouponList(let param):
      return .requestParameters(parameters: try! param.asDictionary(), encoding: URLEncoding.default)
    case .downloadCoupon:
      return .requestPlain
    default:
      return .requestPlain
    }
  }

  var headers: [String : String]? {
    if let accessToken = DataHelperTool.accessToken {
      return ["Content-type": "application/json", "Authorization": "Bearer \(accessToken)"]
    } else {
      return ["Content-type": "application/json"]
    }
  }
}

struct GetCouponListReq: Codable {
  var status: Coupon.Status
  var start: Int
  var perPage: Int
}
