//
//  AuthResponse.swift
//  ginger9
//
//  Created by jason on 2021/04/20.
//

import Foundation

struct ConnectInfo: Codable {
  var id: Int?
  var name: String?
  var connectedAt: String?
}

struct LoginResponse: Codable {
//  var user: User
  var token: String
}

struct RegisterResponse: Codable {
//  var user: User
  var accessToken: String
  var refreshToken: String
}

struct RefreshTokenResponse: Codable {
  var accessToken: String
}

struct SendAuthCodeResponse: Decodable {
  var codeToken: String
  var code: String?
}

struct ConfirmAuthCodeResponse: Decodable {
  var phoneToken: String
}

struct CheckAppVersionResponse: Codable {
  var ios: Int
  var android: Int
  var isHidden : Bool
}

struct FindEmailResponse: Decodable {
  var email: String
}

struct CheckEmailResponse: Decodable {
  var message: String
}


struct AgreementsResponse: Decodable {
  var title: String
  var contents: String
}
