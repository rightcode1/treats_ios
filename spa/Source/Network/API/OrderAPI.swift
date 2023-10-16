//
//  OrderAPI.swift
//  spa
//
//  Created by 이동석 on 2022/11/28.
//

import Foundation
import Moya

enum OrderAPI {
  case getOrderList(param: GetOrderListReqeust)
  case getWaitList(param: GetOrderListReqeust)
  case getOrderDetail(id: Int)

  case createOrderSheet(param: CreateOrderSheetRequest)
  case getOrderSheet(id: String)
  case getCancel(id: Int)

  case postOrderWebview(param: PostOrderRequest)
  case postOrder(param: PostOrderRequest) // 0원일때

  case cancelOrder(id: Int)
}

extension OrderAPI: TargetType {
  public var baseURL: URL {
    return URL(string: Environment.baseUrl)!
  }

  var path: String {
    switch self {
    case .getOrderList:
      return "/orders"
    case .getWaitList:
      return "/waiting"
    case .getOrderDetail(let id):
      return "/orders/\(id)"
    case .getCancel(let id):
      return "/orders/check/\(id)"

    case .createOrderSheet:
      return "/orderSheets"
    case .getOrderSheet(let id):
      return "/orderSheets/\(id)"

    case .postOrderWebview:
      return "/orders/webview"
    case .postOrder:
      return "/orders"
    case .cancelOrder(let id):
      return "/orders/\(id)"
    }
  }

  var method: Moya.Method {
    switch self {
    case .createOrderSheet,
        .postOrderWebview,
        .postOrder:
      return .post
    case .getOrderList,
        .getWaitList,
        .getOrderDetail,
        .getCancel,
        .getOrderSheet:
      return .get
    case .cancelOrder:
      return .delete
    }
  }

  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }

  var task: Task {
    switch self {
    case .getOrderList(let param):
      return .requestParameters(parameters: try! param.asDictionary(), encoding: URLEncoding.default)
    case .getWaitList(let param):
      return .requestParameters(parameters: try! param.asDictionary(), encoding: URLEncoding.default)
    case .createOrderSheet(let param):
      return .requestParameters(parameters: try! param.asDictionary(), encoding: JSONEncoding.default)
    case .postOrderWebview(let param):
      return .requestJSONEncodable(param)
    case .postOrder(let param):
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

struct GetOrderListReqeust: Codable {
  var start: Int
  var perPage: Int
  var status: Order.Status?
}

struct CreateOrderSheetRequest: Codable {
  var date: String
  var time: String
  var bedCount: Int
  var productId: Int
  var options: [Option]
  var coupleRoom: Bool?

  struct Option: Codable {
    var id: Int
    var quantity: Int
  }
}

struct IamportResponse: Codable {
  var imp: IMP
  var impAccount: String

  struct IMP: Codable {
    var amount: Int
    var buyer_name: String
    var buyer_email: String
    var pg: String
    var pay_method: String
    var merchant_uid: String
    var m_redirect_url: String
    var name: String
    var buyer_tel: String
  }
}

struct PostOrderRequest: Codable {
  var sheetId: String
  var payMethod: PayMethod
  var buyerEmail: String
  var buyerName: String
  var buyerTel: String
  var redirectUrl: String? = nil
  var point: Int = 0

  enum PayMethod: String, Codable {
    case card
    case vBank
  }
}

struct OrderSheet: Codable {
  var store: Store
  var product: Store.Product
  var options: [Option]
  var point: Int
  var user: User
  var reservationDate: String
  var bedCount: Int

  struct Option: Codable {
    var quantity: Int
    var id: Int
    var price: Int
    var order: Int
    var storeId: Int
    var name: String
  }
}

struct OrderList: Codable {
  var id: Int
  var status: Order.Status
  var storeAddress: String
  var storeName: String
  var storeTitleImage: String
  var productName: String?
  var productTime: Int?
  var reservationDate: String?
  var amount: Int?
  var reviewed: Bool?
  var createdAt: String
  var date: String
  var time: String
  var count: Int
}


struct Order: Codable {
  var reservationDate: String
  var bedCount: Int

  var buyerEmail: String
  var store: Store
  var product: Store.Product
  var options: [OptionInventory]
  var id: Int
  var status: Status
  var amount: Int
  var productAmount: Int
  var optionAmount: Int
  var originalAmount: Int
  var point: Int
  var buyerName: String
  var buyerTel: String
  var reviewed: Bool
  var createdAt: String
  var orderSheetId: String
  var payment: Payment?
  var cancelledAt: String?
  var cancelledUserMemo: String?
  //  "vbankRefund": {
  //    "bank": "352203628507425663491392198464443158402412571532141126",
  //    "account": "28049063023312358283501331080558196434051200199913672111928",
  //    "holder": "string"
  //  },

  enum Status: String, Codable {
    case ready
    case noReady
    case used
    case cancelled
    case wait
    case send

    func getString() -> String {
      switch self {
      case .ready:
        return "사용전"
      case .noReady:
        return "예약대기"
      case .used:
        return "사용완료"
      case .cancelled:
        return "예약취소"
      case .wait:
        return "줄서기 예약"
      case .send:
        return "알림발송"
      }
    }

    func getTextColor() -> UIColor {
      switch self {
      case .ready:
        return UIColor(hex: "#345D9A")
      case .noReady:
        return UIColor(hex: "#1db0ab")
      case .used:
        return UIColor(hex: "#797979")
      case .cancelled:
        return UIColor(hex: "#e96c68")
      case .wait:
        return UIColor(hex: "#7BC4BC")
      case .send:
        return UIColor(hex: "#3D5C96")
      }
    }
  }

  struct OptionInventory: Codable {
    var optionId: Int
    var option: Option
    var quantity: Int

    struct Option: Codable {
      var name: String
      var id: Int
      var price: Int
    }
  }

  struct Payment: Codable {
    var method: Method
    var status: String
    var amount: Int
    var id: Int
    var paymentId: String
    var updatedAt: String
    var type: String
    var createdAt: String
    var cancelledAmount: Int

    enum Method: String, Codable {
      case card
      case trans
      case vbank
      case phone
      case samsung
      case kpay
      case kakaopay
      case payco
      case lpay
      case ssgpay
      case tosspay
      case cultureland
      case smartculture
      case happymoney
      case booknlife
      case point
      case wechat
      case alipay
      case unionpay
      case tenpay

      func getString() -> String {
        switch self {
        case .card:
          return "신용카드"
        case .trans:
          return "실시간계좌이체"
        case .vbank:
          return "가상계좌"
        case .phone:
          return "휴대폰소액결제"
        case .samsung:
          return "삼성페이 / 이니시스, KCP 전용"
        case .kpay:
          return "KPay앱 직접호출 / 이니시스 전용"
        case .kakaopay:
          return "카카오페이 직접호출 / 이니시스, KCP, 나이스페이먼츠 전용"
        case .payco:
          return "페이코 직접호출 / 이니시스, KCP 전용"
        case .lpay:
          return "LPAY 직접호출 / 이니시스 전용"
        case .ssgpay:
          return "SSG페이 직접호출 / 이니시스 전용"
        case .tosspay:
          return "토스간편결제 직접호출 / 이니시스 전용"
        case .cultureland:
          return "문화상품권 / 이니시스, 토스페이먼츠(구 LG U+), KCP 전용"
        case .smartculture:
          return "스마트문상 / 이니시스, 토스페이먼츠(구 LG U+), KCP 전용"
        case .happymoney:
          return "해피머니 / 이니시스, KCP 전용"
        case .booknlife:
          return "도서문화상품권 / 토스페이먼츠(구 LG U+), KCP 전용"
        case .point:
          return "베네피아 포인트 등 포인트 결제 / KCP 전용"
        case .wechat:
          return "위쳇페이 / 엑심베이 전용"
        case .alipay:
          return "알리페이 / 엑심베이 전용"
        case .unionpay:
          return "유니온페이 / 엑심베이 전용"
        case .tenpay:
          return "텐페이 / 엑심베이 전용"
        }
      }
    }
  }
}
