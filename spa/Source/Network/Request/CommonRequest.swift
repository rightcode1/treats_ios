//
//  CommonRequest.swift
//  spa
//
//  Created by 이동석 on 2022/12/04.
//

import Foundation

struct ListRequest: Codable {
  var start: Int
  var perPage: Int
}
