import Foundation
import Moya

enum BrandAPI {
  case getBrandlist(param: GetBrandListRequest)
  case getBrandDetail(id: Int)
}

extension BrandAPI: TargetType {
  public var baseURL: URL {
    return URL(string: Environment.baseUrl)!
  }

  var path: String {
    switch self {
    case .getBrandlist:
      return "/v1/brand/list"
    case .getBrandDetail:
      return "/v1/brand/detail"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getBrandlist,
        .getBrandDetail:
      return .get
    }
  }

  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }

  var task: Task {
    switch self {
    case .getBrandlist(let param):
      return .requestParameters(parameters: try! param.asDictionary(), encoding: URLEncoding.default)
    case .getBrandDetail(let id):
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.default)
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

struct GetBrandListRequest: Codable {
  var page: Int
  var limit: Int
  var search: String? = nil
  var sort: Sort? = nil

  enum Sort: String, Codable {
    case 가나다순
    case 관심도순
  }
}

struct GetBrandListResponse: Codable {
  var list: [Brand]
}

struct Brand: Codable {
  var id: Int
  var name: String
  var thumbnail: String
  var createdAt: String
}
