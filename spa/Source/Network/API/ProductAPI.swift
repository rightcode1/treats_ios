import Foundation
import Moya

enum ProductAPI {
  case getProductList(param: GetProductListRequest?)
  case getProductDetail(id: Int)

  case getThemeList(page: Int, limit: Int)
}

extension ProductAPI: TargetType {
  public var baseURL: URL {
    return URL(string: Environment.baseUrl)!
  }

  var path: String {
    switch self {
    case .getProductList:
      return "/v1/board/list"
    case .getProductDetail:
      return "/v1/board/detail"
    case .getThemeList:
      return "/v1/theme/list"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getProductList,
        .getProductDetail,
        .getThemeList:
      return .get
    }
  }

  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }

  var task: Task {
    switch self {
    case .getProductList(let param):
      if let param = param {
        return .requestParameters(parameters: try! param.asDictionary(), encoding: URLEncoding.default)
      } else {
        return .requestPlain
      }
    case .getProductDetail(let id):
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.default)
    case .getThemeList(let page, let limit):
      return .requestParameters(parameters: ["page": page, "limit": limit], encoding: URLEncoding.default)
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

struct GetProductListRequest: Codable {
  var page: Int? = nil
  var limit: Int? = nil
  var brandId: Int? = nil
}

struct Product: Codable {
  var content: String
  var time: Int
  var id: Int
  var price: Int
  var order: Int
  var categoryId: Int
  var updatedAt: String
  var createdAt: String
  var name: String
}

struct GetProductListResponse: Codable {
  var list: [Product]
}

struct Theme: Codable {
  var createdAt: String
  var id: Int
  var title: String
  var boards: [Product]
  var sortCode: Int
}

struct GetThemeListResponse: Codable {
  var list: [Theme]
}
