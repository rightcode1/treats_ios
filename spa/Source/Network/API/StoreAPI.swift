//
//  StoreAPI.swift
//  spa
//
//  Created by 이동석 on 2022/11/04.
//

import Foundation
import Moya

enum StoreAPI {
  case getStoreList(param: GetStoreListRequest)
  case getStoreDetail(id: Int)
  case likeStore(id: Int)
  case unlikeStore(id: Int)

  case getStoreSchedule(storeId: Int, date: String)
  
  case chatRoom(param: RegisterChatRoom)

  case getCategoryList

  case getPaymentHTML

  case postWating(param: PostWatingRequest)
}

extension StoreAPI: TargetType {
  public var baseURL: URL {
    return URL(string: Environment.baseUrl)!
  }

  var path: String {
    switch self {
    case .getStoreList:
      return "/stores"
    case .getStoreDetail(let id):
      return "/stores/\(id)"
    case .likeStore(let id):
      return "/stores/\(id)/liked"
    case .unlikeStore(let id):
      return "/stores/\(id)/liked"

    case .getStoreSchedule:
      return "/schedules"
    case .getCategoryList:
      return "/categories"

    case .chatRoom:
      return "/chatRooms"
    case .getPaymentHTML:
      return "/orders/webView"

    case .postWating:
      return "/waiting"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getStoreList,
        .getStoreDetail,
        .getStoreSchedule,
        .getCategoryList,
        .getPaymentHTML:
      return .get
    case .likeStore,
        .chatRoom,
        .postWating:
      return .post
    case .unlikeStore:
      return .delete
    }
  }

  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }

  var task: Task {
    switch self {
    case .chatRoom(let param):
      return .requestJSONEncodable(param)
    case .getStoreList(let param):
      return .requestParameters(parameters: try! param.asDictionary(), encoding: URLEncoding(boolEncoding: .literal))
    case .getStoreDetail:
      return .requestPlain
    case .getStoreSchedule(let storeId, let date):
      return .requestParameters(parameters: ["storeId": storeId, "date": date], encoding: URLEncoding.default)
    case .getCategoryList:
      return .requestPlain
    case .postWating(let param):
      return .requestJSONEncodable(param)
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

struct Coupon: Codable {
  var quantity: Int
  var endDate: String
  var id: Int
  var contents: String
  var startDate: String
  var enabled: Bool
  var storeId: Int
  var createdAt: String
  var updatedAt: String
  var name: String
  var originalQuantity: Int

  enum Status: String, Codable {
    case ready
    case used
    case expired

    func getString() -> String {
      switch self {
      case .ready:
        return "사용전"
      case .used:
        return "사용후"
      case .expired:
        return "기간만료"
      }
    }
  }
}

struct Store: Codable {
  var id: Int
  var name: String
  var likedCount: Int
  var titleImage: String
  var addressDetail: String
  var address: String
  var summary: String
  var etc: String?
  var holiday: String
  var time: String
  var subway: String
  var parking: String
  var launch: String
  
  var chatRoomId: Int?
  var isRoom: Bool?
  var enabled: Bool
  var images: [String]
  var tel: String
  var liked: Bool?
  var createdAt: String
  var productCategories: [ProductCategory]?
  var options: [Option]?
  var infos: [Info]
  var editorReviews: [EditorReview]?
  var latitude: Double
  var longitude: Double
  var rating: Double
  var reviewCount: Int?
  var distance: Double?
  var categories: [Category]?
  var beds: [Bed]?
  var coupons: [Coupon]?
  var downloadCouponIdList: [Int]?
  var schedules: [Schedule]?
  var isCoupleRoom: Bool
  var notice: [StoreNotice]?
  
  struct Info: Codable {
    var image: String?
    var title: String
    var description: String
  }

  struct ProductCategory: Codable {
    var name: String
    var products: [Product]
  }

  struct Product: Codable {
    var id: Int
    var name: String
    var price: Int
    var time: Int
    var content: String
    var createdAt: String
    var updatedAt: String
    var surgeryTime: Int?

    var category: Category?

    struct Category: Codable {
      var id: Int
      var name: String
    }
  }

  struct Option: Codable {
    var id: Int
    var price: Int
    var order: Int
    var storeId: Int
    var createdAt: String
    var updatedAt: String
    var name: String
  }

  struct Schedule: Codable {
    var time: String
    var bedCount: Int
  }

  func getTimeList(bedCount: Int) -> [String] {
    var timeList = [String]()
    var timeAndCountList = [(Date, Int)]()
    if let beds = beds {
      beds.forEach { bed in
        (bed.schedules ?? []).forEach { schedule in
          let scheduleDate = Date.dateFromISO8601String(schedule.date)!
          if let index = timeAndCountList.firstIndex(where: { $0.0.isSameTime(scheduleDate)}) {
            timeAndCountList[index].1 = timeAndCountList[index].1 + 1
          } else {
            timeAndCountList.append((scheduleDate, 1))
          }
        }
      }

      timeList = timeAndCountList.filter({ $0.1 >= bedCount }).filter({ $0.0 > Date() }).sorted(by: {$0.0 < $1.0}).map({ $0.0.ahhmm })
    }

    return timeList
  }
}

struct GetStoreListResponse: Codable {
  var total: Int
  var data: [Store]
}

struct GetStoreListRequest: Codable {
  var date: String?
  var latitude: Double?
  var longitude: Double?
  var liked: Bool?
  var categoryId: Int?
  var start: Int = 0
  var perPage: Int = 30
  var reservationable: String?
  var search: String?
}

struct Category: Codable {
  var id: Int
  var name: String
  var image: String?
  var parentId: Int?
  var children: [Category]?
  var isParent: Bool?
}

struct GetCategoryListResponse: Codable {
  var data: [Category]
}

struct GetScheduleResponse: Codable {
  var data: [Bed]
}
struct RegisterRoomResponse: Codable {
  var id: Int
}

struct Bed: Codable {
  var id: Int
  var schedules: [Schedule]?

  struct Schedule: Codable {
    var id: Int
    var reservated: Bool
    var date: String
  }
}

struct EditorReview: Codable {
  var author: String
  var thumbnail: String
  var id: Int
  var title: String
  var updatedAt: String
  var createdAt: String
  var url: String
}
struct RegisterChatRoom: Codable {
  var storeId: Int
}

struct StoreNotice: Codable {
  var id: Int
  var images: [String]?
  var title: String
  var content: String
  var storeId: Int
  var createdAt: String
  var updatedAt: String
}

struct PostWatingRequest: Codable {
  var date: String
  var time: String
  var count: Int
  var storeId: Int
}

