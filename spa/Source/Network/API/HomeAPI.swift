import Foundation
import Moya

enum HomeAPI {
  case getHomeInfo
  case getSearchInfo
  case getAroundStoreList(param: GetAroundStoreListRequest)
  case getAdvertisement(id: Int)
  case getAdvertisements
  case visitCount
}

extension HomeAPI: TargetType {
  public var baseURL: URL {
    return URL(string: Environment.baseUrl)!
  }

  var path: String {
    switch self {
    case .getHomeInfo:
      return "/home"
    case .getSearchInfo:
      return "/home/search"
    case .getAroundStoreList:
      return "/home/aroundStores"
    case .getAdvertisement(let id):
      return "/advertisements/\(id)"
    case .getAdvertisements:
      return "/advertisements"
    case .visitCount:
      return "/visit-count"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getHomeInfo,
        .getSearchInfo,
        .getAdvertisement,
        .getAroundStoreList,
        .getAdvertisements:
      return .get
    case .visitCount:
      return .post
    }
  }

  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }

  var task: Task {
    switch self {
    case .getHomeInfo:
      return .requestPlain
    case .getSearchInfo:
      return .requestPlain
    case .getAdvertisements:
      return .requestParameters(parameters: ["type": "benefits","start": 0,"perPage": 1000], encoding: URLEncoding.default)
    case .getAroundStoreList(let param):
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

struct GetAroundStoreListRequest: Codable {
  var latitude: Double?
  var longitude: Double?
  var aroundCategoryId: Int?
}

struct HomeInfo: Codable {
  var popupAdvertisement: Advertisement?
  var advertisementBanners: [Advertisement]
  var categories: [Category]
  var editorPicks: [Journal]
  var reservationableStores: [Store]
  var benefits: [Benefit]
  var advertisementBenefit: [Advertisement]
  var places: [Place]
}
struct AdvertisementResponse: Codable {
  var data: [Advertisement]
}
struct searchInfo: Codable {
  var searchList: [String]
  var storeList: [storList]
}
struct storList: Codable{
  var storeId: Int?
  var name: String?
  var count: Int?
}

struct Advertisement: Codable {
  var id: Int
  var name: String
  var description: String
  var category: String
  var order: Int
  var type: String
  var division: Division
  var thumbnail: String
  var enabled: Bool
  var url: String?
  var enableComment: Bool?
  var detailImage: String?
  var storeTitle: String?
  var stores: [Store]?
  var price: String?
  var percent: String?

  enum Division: String, Codable {
    case url
    case image
    case store
  }
}

struct Journal: Codable {
  var thumbnail: String
  var subtitle: String
  var id: Int
  var order: Int
  var title: String
  var updatedAt: String
  var createdAt: String
  var contents: [Content]

  struct Content: Codable {
    var title: String?
    var image: String?
    var subtitle: String?
    var description: String?
    
  }

}

struct Magazine: Codable {
  var id: Int
  var productName: String
  var storeName: String
  var author: String
  var title: String
  var intro: String
  var content: String
  var thumbnail: String
  var images: [String]
}

struct Benefit: Codable {
  var storeId: Int
  var storeName: String
  var storeThumbnail: String
  var thumbnail: String
  var id: Int
  var order: Int
  var content: String
}

struct Place: Codable {
  var longitude: Double
  var latitude: Double
  var name: String
  var image: String?
  var address: String
}
