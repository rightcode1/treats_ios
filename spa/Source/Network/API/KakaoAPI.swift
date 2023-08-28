import Foundation
import Moya

enum KakaoAPI {
  case coordToAddress(param: GetCoordToAddressRequest)

}

extension KakaoAPI: TargetType {
  public var baseURL: URL {
    return URL(string: "https://dapi.kakao.com")!
  }

  var path: String {
    switch self {
    case .coordToAddress:
      return "/v2/local/geo/coord2address"
    }
  }

  var method: Moya.Method {
    switch self {
    case .coordToAddress:
      return .get
    }
  }

  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }

  var task: Task {
    switch self {
    case .coordToAddress(let param):
      return .requestParameters(parameters: try! param.asDictionary(), encoding: URLEncoding.default)
    }
  }

  var headers: [String : String]? {
    return ["Content-type": "application/json", "Authorization": "KakaoAK \(Environment.kakaoRestApiKey)"]
  }
}

struct GetCoordToAddressRequest: Codable {
  var x: Double // longitude
  var y: Double // latitude
}

struct GetCoordToAddressResponse: Codable {
  var documents: [Document]

  struct Document: Codable {
    var road_address: RoadAddress?
    var address: Address?

    struct RoadAddress: Codable {
      var address_name: String
    }

    struct Address: Codable {
      var address_name: String
    }
  }
}
