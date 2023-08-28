import Foundation
import Moya

enum AuthAPI {
  case login(email: String, password: String)
  case socialLogin(param: SocialLoginRequest)
  case register(param: RegisterRequest)
  case socialRegister(param: SocialRegisterRequest)
  case checkEmail(email: String)
  case checkNickname(nickname: String)
  case findEmail(param: FindEmailRequest)
  case changePassword(param: ChangePasswordRequest)
  case resetPassword(param: ResetPasswordRequest)
  case refreshToken
  case sendAuthCode(param: SendAuthCodeRequest)
  case confirmAuthCode(param: ConfirmAuthCodeRequest)
  case checkAppVersion
  case sendNotificationToken(param: NotificationRequest)
}

extension AuthAPI: TargetType {
  public var baseURL: URL {
    return URL(string: Environment.baseUrl)!
  }

  var path: String {
    switch self {
    case .login:
      return "/auth"
    case .socialLogin:
      return "/auth/social"
    case .register:
      return "/auth/register"
    case .socialRegister:
      return "/auth/social/register"
    case .checkEmail:
      return "/auth/email"
    case .checkNickname:
      return "/auth/nickname"
    case .findEmail:
      return "/auth/findEmail"
    case .changePassword:
      return "/users/password"
    case .resetPassword:
      return "/auth/resetPassword"
    case .refreshToken:
      return "/auth/refresh"
    case .sendAuthCode:
      return "/verifications"
    case .confirmAuthCode:
      return "/verifications/confirm"
    case .checkAppVersion:
      return "/versions"
    case .sendNotificationToken : return "/userToken"
    }
  }

  var method: Moya.Method {
    switch self {
    case .login,
        .socialLogin,
        .register,
        .socialRegister,
        .findEmail,
        .resetPassword,
        .sendAuthCode,
        .refreshToken,
        .sendNotificationToken,
        .confirmAuthCode:
      return .post
    case .checkEmail,
        .checkNickname,
        .checkAppVersion:
      return .get
    case .changePassword:
      return .put
    }
  }

  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }

  var task: Task {
    switch self {
    case .login(let email, let password):
      return .requestParameters(parameters: ["email": email, "password": password], encoding: JSONEncoding.default)
    case .socialLogin(let param):
      return .requestJSONEncodable(param)
    case .register(let param):
      return .requestJSONEncodable(param)
    case .socialRegister(let param):
      return .requestJSONEncodable(param)
    case .checkEmail(let email):
      return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)
    case .checkNickname(let nickname):
      return .requestParameters(parameters: ["nickname": nickname], encoding: URLEncoding.queryString)
    case .findEmail(let param):
      return .requestJSONEncodable(param)
    case .resetPassword(let param):
      return .requestJSONEncodable(param)
    case .refreshToken:
      guard let refreshToken = DataHelperTool.refreshToken, let accessToken = DataHelperTool.accessToken else {
        return .requestPlain
      }
      return .requestParameters(parameters: ["refreshToken": refreshToken, "accessToken": accessToken], encoding: JSONEncoding.default)
    case .sendAuthCode(let param):
      return .requestJSONEncodable(param)
    case .confirmAuthCode(let param):
      return .requestJSONEncodable(param)
    case .changePassword(let param):
      return .requestJSONEncodable(param)
    case .sendNotificationToken(let param):
      return .requestJSONEncodable(param)
    default:
      return .requestPlain
    }
  }

  var headers: [String : String]? {
    switch self {
    case .changePassword:
      if let accessToken = DataHelperTool.accessToken {
        return ["Content-type": "application/json", "Authorization": "Bearer \(accessToken)"]
      } else {
        return ["Content-type": "application/json"]
      }
    default:
      return ["Content-type": "application/json"]
    }
  }
}

struct AuthResponse: Codable {
  var user: User
  var statusCode: Int
  var token: String
}

struct Notification: Codable {
  let code: Int
  let result: Bool
  let resultMsg: String
}
