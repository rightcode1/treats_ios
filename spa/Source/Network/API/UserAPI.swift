import Foundation
import Moya

enum UserAPI {
  case getUserInfo
  case checkUser(id: String,pwd: String)
  case patchUserInfo(param: PatchUserInfoRequest)

  case postUserSupport(data: PostUserSupportRequest)
  case getUserSupportList(param: ListRequest)
  case getUserSupport(id: Int)

  case getPointList(param: ListRequest)

  case withdrawal
}

extension UserAPI: TargetType {
  public var baseURL: URL {
    return URL(string: Environment.baseUrl)!
  }

  var path: String {
    switch self {
    case .getUserInfo:
      return "/users"
    case .checkUser:
      return "/users/check"
    case .patchUserInfo:
      return "/users"
    case .postUserSupport:
      return "/userSupports"
    case .getUserSupportList:
      return "/userSupports"
    case .getUserSupport(let id):
      return "/userSupports/\(id)"
    case .getPointList:
      return "/points"
    case .withdrawal:
      return "/users"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getUserInfo,
        .getUserSupportList,
        .getUserSupport,
        .checkUser,
        .getPointList:
      return .get
    case .postUserSupport:
      return .post
    case .patchUserInfo:
      return .patch
    case .withdrawal:
      return .delete
    }
  }

  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }

  var task: Task {
    switch self {
    case .checkUser(let id ,let pwd):
      return .requestParameters(parameters: ["email": id,"phone": pwd], encoding: URLEncoding.default)
//    case .getUserList:
//      return .requestParameters(parameters: ["isRecommend": true], encoding: URLEncoding(destination: .queryString, arrayEncoding: .brackets, boolEncoding: .literal))
    case .patchUserInfo(let param):
      return .requestJSONEncodable(param)
    case .postUserSupport(let data):
      return .requestJSONEncodable(data)
    case .getUserSupportList(let param):
      return .requestParameters(parameters: try! param.asDictionary(), encoding: URLEncoding.default)
    case .getPointList(let param):
      return .requestParameters(parameters: try! param.asDictionary(), encoding: URLEncoding.default)
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

struct User: Codable {
  var id: Int
  var email: String?
  var profileImage: String?
  var name: String?
  var nickname: String?
  var phone: String?
  var gender: String?
  var couponCount: Int?
  var point: Int?
  var setting: Setting?
  var accounts: [String]?

  struct Setting: Codable {
    var agreeMarketing: Bool
    var agreeMarketingPush: Bool
    var agreeChatPush: Bool
    var agreeReceiveText: Bool
    var agreeReceiveEmail: Bool
  }
}

struct GetUserInfoResponse: Codable {
  var data: User
}

struct PatchUserInfoRequest: Codable {
  var name: String?
  var nickname: String?
  var gender: String?
  var profileImage: String?
  var phoneToken: String?
  var agreeMarketingPush: Bool?
  var agreeChatPush: Bool?
}

struct GetUserListResponse: Codable {
  var list: [User]
}

struct PostUserSupportRequest: Codable {
  var title: String
  var content: String
}

struct UserSupport: Codable {
  var id: Int
  var title: String
  var content: String
  var answered: Bool
  var answerTitle: String?
  var answerContent: String?
  var createdAt: String
  var updatedAt: String
}

struct Point: Codable {
  var id: Int
  var title: String
  var point: Int
  var createdAt: String
}

struct GetPointListResponse: Codable {
  var point: Int
  var data: [Point]
  var total: Int
}
