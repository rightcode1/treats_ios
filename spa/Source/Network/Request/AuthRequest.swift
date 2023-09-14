//
//  AuthRequest.swift
//  ginger9
//
//  Created by jason on 2021/04/20.
//

import Foundation

enum SocialType: String, Codable {
  case kakao
  case naver
  case google
  case apple
}

struct SocialLoginRequest: Encodable {
  var type: SocialType
  let password: String = "rightcode1234"
  var phone: String? = nil
  var loginId: String? = nil
  var name: String? = nil
  var gender: String? = nil
  var agreeMarketing: Bool  = false
  var recommender: String? = nil
  var email: String? = nil
}

struct LoginRequest: Codable {
  var loginId: String
  var password: String
}

struct RegisterRequest: Encodable {
  var email: String?
  var name: String?
  var nickname: String?
  var phone: String?
  var gender: Gender?
  var type: LoginType
  var password: String?
  var socialToken: String? = nil
  var phoneToken: String? = nil
  var recommender: String? = nil

  enum Gender: String, Codable {
    case male
    case female
  }
}

enum LoginType: String, Codable {
  case email
  case facebook
  case naver
  case kakao
  case apple
  case google
}

struct SocialRegisterRequest: Codable {
  var platform: String = "ios"
  var type: SocialType
  var token: String //": "string",
  var name: String //": "string",
  var profileImage: String? //": "string"
}

struct ChangePasswordRequest: Encodable {
  var currentPassword: String
  var password: String
}

struct SendAuthCodeRequest: Encodable {
  var phone: String
  var type: Type // register, findId, resetPassword

  enum `Type`: String, Codable {
    case register
    case resetPassword
    case changePhone
    case findEmail
  }
}

struct ConfirmAuthCodeRequest: Encodable {
  var codeToken: String
  var code: String
}

struct FindEmailRequest: Codable {
  var phone: String
  var phoneToken: String
}

struct ResetPasswordRequest: Encodable {
  var password: String
  var email: String
  var phone: String
  var phoneToken: String
}

struct NotificationRequest: Codable {
    var notificationToken: String
}
