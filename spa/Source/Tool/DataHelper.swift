import Foundation
import FirebaseMessaging

class DataHelper<T> {
  enum DataKeys: String {
    case neverShowPopup = "neverShowPopup"

    case userId = "userId"
    case profileImage = "profileImage"
    case email = "email"
    case nickname = "nickname"

    case accessToken = "accessToken"
    case pushToken = "pushToken"
    case refreshToken = "refreshToken"

    case isSpotifyConnected = "isSpotifyConnected"
    case spotifyAccessToken = "spotifyAccessToken"
    case spotifyRefreshToken = "spotifyRefreshToken"

    case recentStores = "recentStores"

    case agreeMarketingPush = "agreeMarketingPush"
    case agreeChatPush = "agreeChatPush"

    case pushAdvertisementId = "pushAdvertisementId"
    case pushStoreId = "pushStoreId"
    
    
    case searchKeywordHistoryList = "searchKeywordHistoryList"
  }

  class func value(forKey key: DataKeys) -> T? {
    if let data = UserDefaults.standard.value(forKey: key.rawValue) as? T {
      return data
    }else {
      return nil
    }
  }

  class func set(_ value:T, forKey key:DataKeys) {
    UserDefaults.standard.set(value, forKey : key.rawValue)
    UserDefaults.standard.synchronize()
  }

  class func remove(forKey key: DataKeys) {
    UserDefaults.standard.removeObject(forKey: key.rawValue)
    UserDefaults.standard.synchronize()
  }

  class func pushRecentStores(_ store: Store) {
    var list = getRecentStores()
    list = list.filter({ $0.id != store.id})
    //    list.append(store)
    list.insert(store, at: 0)
    UserDefaults.standard.set(try? PropertyListEncoder().encode(list), forKey: "recentStores")
    UserDefaults.standard.synchronize()
  }

  class func deleteRecentStore(storeId: Int) {
    var list = getRecentStores()
    list = list.filter({ $0.id != storeId})
    UserDefaults.standard.set(try? PropertyListEncoder().encode(list), forKey: "recentStores")
    UserDefaults.standard.synchronize()
  }

  class func getRecentStores() -> [Store] {
    if let data = UserDefaults.standard.value(forKey:"recentStores") as? Data {
      return (try? PropertyListDecoder().decode([Store].self, from: data)) ?? []
    } else {
      return []
    }
  }

  class func clearAll() {
    Messaging.messaging().unsubscribe(fromTopic: "marketing")

    UserDefaults.standard.dictionaryRepresentation().keys.forEach { key in
      log.info(key.description)
      if key.description != "isFirstLaunch" {
        UserDefaults.standard.removeObject(forKey: key.description)
      }
    }

    UserDefaults.standard.synchronize()
  }
}

class DataHelperTool {
  static var pushToken: String? {
    guard let pushToken = DataHelper<String>.value(forKey: .pushToken) else { return nil }
    return pushToken
  }
  static var neverShowPopup: Bool {
    guard let neverShowPopup = DataHelper<Bool>.value(forKey: .neverShowPopup) else { return false }
    return neverShowPopup
  }

  static var userId: Int? {
    guard let userId = DataHelper<Int>.value(forKey: .userId) else { return nil }
    return userId
  }

  static var profileImage: String? {
    guard let profileImage = DataHelper<String>.value(forKey: .profileImage) else { return nil }
    return profileImage
  }

  static var email: String? {
    guard let email = DataHelper<String>.value(forKey: .email) else { return nil }
    return email
  }

  static var nickname: String? {
    guard let nickname = DataHelper<String>.value(forKey: .nickname) else { return nil }
    return nickname
  }

  static var accessToken: String? {
    guard let accessToken = DataHelper<String>.value(forKey: .accessToken) else { return nil }
    return accessToken
  }

  static var refreshToken: String? {
    guard let refreshToken = DataHelper<String>.value(forKey: .refreshToken) else { return nil }
    return refreshToken
  }

  static var agreeMarketingPush: Bool {
    guard let agreeMarketingPush = DataHelper<Bool>.value(forKey: .agreeMarketingPush) else { return true }
    return agreeMarketingPush
  }

  static var agreeChatPush: Bool {
    guard let agreeChatPush = DataHelper<Bool>.value(forKey: .agreeChatPush) else { return true }
    return agreeChatPush
  }

  static var pushAdvertisementId: Int? {
    guard let pushAdvertisementId = DataHelper<Int>.value(forKey: .pushAdvertisementId) else { return nil }
    return pushAdvertisementId
  }

  static var pushStoreId: Int? {
    guard let pushStoreId = DataHelper<Int>.value(forKey: .pushStoreId) else { return nil }
    return pushStoreId
  }
  
  static var searchKeywordHistoryList: [String]? {
    guard let searchKeywordHistoryList = DataHelper<[String]>.value(forKey: .searchKeywordHistoryList) else { return [] }
    return searchKeywordHistoryList
  }
}
