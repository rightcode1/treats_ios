//
//  CommonResponse.swift
//  spa
//
//  Created by 이동석 on 2022/12/05.
//

import Foundation

struct ListResponse<T: Codable>: Codable {
  var total: Int
  var data: [T]
}
