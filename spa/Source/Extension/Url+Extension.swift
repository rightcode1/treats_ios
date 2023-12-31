//
//  Url+Extension.swift
//  Treat
//
//  Created by 이남기 on 2023/08/28.
//

import Foundation

extension URL {
  func appending(_ queryItem: String, value: String?) -> URL {
    if value != nil {
      guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
      
      // Create array of existing query items
      var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
      
      // Create query item
      let queryItem = URLQueryItem(name: queryItem, value: value)
      
      // Append the new query item in the existing query items array
      queryItems.append(queryItem)
      
      // Append updated query items array in the url component object
      urlComponents.queryItems = queryItems
      
      // Returns the url from new url components
      return urlComponents.url!
    } else {
      guard let urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
      
      return urlComponents.url!
    }
  }
}
