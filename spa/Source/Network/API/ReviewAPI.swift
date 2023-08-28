//
//  ReviewAPI.swift
//  spa
//
//  Created by 이동석 on 2022/12/05.
//

import Foundation
import Moya

enum ReviewAPI {
  case postReview(param: PostReviewRequest)
  case getReviewList(query: GetReviewListRequest)
  case getReviewDetail(id: Int)
}

extension ReviewAPI: TargetType {
  public var baseURL: URL {
    return URL(string: Environment.baseUrl)!
  }

  var path: String {
    switch self {
    case .postReview:
      return "/reviews"
    case .getReviewList:
      return "/reviews"
    case .getReviewDetail(let id):
      return "/reviews/\(id)"
    }
  }

  var method: Moya.Method {
    switch self {
    case .getReviewList,
        .getReviewDetail:
      return .get
    case .postReview:
      return .post
    }
  }

  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }

  var task: Task {
    switch self {
    case .postReview(let param):
      return .requestJSONEncodable(param)
    case .getReviewList(let query):
      return .requestParameters(parameters: try! query.asDictionary(), encoding: URLEncoding(boolEncoding: .literal))
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

struct PostReviewRequest: Codable {
  var orderId: Int
  var description: String
  var rating: Int
  var images: [String]
}

struct GetReviewListRequest: Codable {
  var start: Int
  var perPage: Int
  var categoryId: Int?
  var storeId: Int?
  var userId: Int?
  var order: ReviewOrder?
  var photo: Bool?
  var search: String?
}

struct GetReviewListResponse: Codable {
  var data: [Review]
  var total: Int
}

struct Review: Codable {
  var id: Int
  var storeId: Int
  var storeName: String
  var storeTitleImage: String
  var storeAddress: String
  var productId: Int
  var productName: String
  var userId: Int
  var userName: String
  var userProfileImage: String?
  var rating: Double
  var description: String
  var images: [String]
  var createdAt: String
  var comment: String?
}
