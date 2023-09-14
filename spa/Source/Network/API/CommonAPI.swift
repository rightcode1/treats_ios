import Foundation
import Moya

enum CommonAPI {
  case getPresignedURL(param: GetPresignedURLRequest)
  case postFile(param: PostFileRequest)
  case uploadFile(URL, Data)
  case downloadImage(path: String)
  case getMagazineList
  case getAgreements
  case getJournalList(param: ListRequest)
  case getJournalDetail(id: Int)
  case getNoticeList(param: ListRequest)
  case getNotice(id: Int)
}

extension CommonAPI: TargetType {
  public var baseURL: URL {
    switch self {
    case let .uploadFile(url, _):
      return url
    default:
      return URL(string: Environment.baseUrl)!
    }
  }

  var path: String {
    switch self {
    case .getAgreements:
      return "/agreements"
    case .getPresignedURL:
      return "/files/upload"
    case .postFile:
      return "/files/upload"
    case .uploadFile:
      return ""
    case .downloadImage:
      return "/images"
    case .getMagazineList:
      return "/magazines"
    case .getJournalList:
      return "/journals"
    case .getJournalDetail(let id):
      return "/journals/\(id)"
    case .getNoticeList:
      return "/notices"
    case .getNotice(let id):
      return "/notices/\(id)"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getPresignedURL,
        .downloadImage,
        .getAgreements,
        .getMagazineList,
        .getJournalList,
        .getJournalDetail,
        .getNoticeList,
        .getNotice:
      return .get
    case .postFile:
      return .post
    case .uploadFile:
      return .put
    }
  }

  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }

  var task: Task {
    switch self {
    case .getPresignedURL(let param):
      return .requestParameters(parameters: try! param.asDictionary(), encoding: URLEncoding.default)
    case .postFile(let param):
      return .requestJSONEncodable(param)
    case let .uploadFile(_, data):
      //      let imageData = MultipartFormData(provider: .data(data), name: "image")
      let imageData = MultipartFormData(provider: .data(data), name: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
      return .uploadMultipart([imageData])
    case .downloadImage(let path):
      return .requestParameters(parameters: ["imagePath": path], encoding: URLEncoding.default)
    case .getMagazineList:
      return .requestPlain
    case .getJournalList(let param):
      return .requestParameters(parameters: try! param.asDictionary(), encoding: URLEncoding.default)
    case .getNoticeList(let param):
      return .requestParameters(parameters: try! param.asDictionary(), encoding: URLEncoding.default)
    case .getNotice:
      return .requestPlain
    default:
      return .requestPlain
    }
  }

  var headers: [String : String]? {
    switch self {
    case .uploadFile:
      return ["Content-Type": "image/jpeg"]
    default:
      if let accessToken = DataHelperTool.accessToken {
        return ["Authorization": "Bearer \(accessToken)", "Content-type": "application/json"]
      }else {
        return ["Content-type": "application/json"]
      }
    }
  }
}

struct GetPresignedURLRequest: Codable {
  var type: Type
  var name: String
  var mimeType: String

  enum `Type`: String, Codable {
    case image
    case file
  }
}

struct PresignedURL: Codable {
  var path: String
  var url: String
}

struct PostFileRequest: Codable {
  var type: Type
  var kind: Kind
  var path: String

  enum `Type`: String, Codable {
    case image
    case file
  }

  enum Kind: String, Codable {
    case users
    case reviews
  }
}

struct PostFileResponse: Codable {
  var url: String
}

struct Notice: Codable {
  var id: Int
  var title: String
  var content: String
  var createdAt: String
  var updatedAt: String
}
