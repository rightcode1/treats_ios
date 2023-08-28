import Foundation

struct Environment {
  static let baseUrl = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as! String
  static let displayName = Bundle.main.object(forInfoDictionaryKey: "DISPLAY_NAME") as! String
  static let bundleIdentifier = Bundle.main.object(forInfoDictionaryKey: "BUNDLE_IDENTIFIER") as! String
  static let urlScheme = Bundle.main.object(forInfoDictionaryKey: "URL_SCHEME") as! String
  static let firebaseResource = Bundle.main.object(forInfoDictionaryKey: "FIREBASE_RESOURCE") as! String
  static let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as! String
  static let kakaoRestApiKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_REST_API_KEY") as! String
  static let naverConsumerKey = Bundle.main.object(forInfoDictionaryKey: "NAVER_CONSUMER_KEY") as! String
  static let naverConsumerSecret = Bundle.main.object(forInfoDictionaryKey: "NAVER_CONSUMER_SECRET") as! String
  static let googleClientId = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as! String
}
