//
//  Array+Extension.swift
//  winedining
//
//  Created by 이동석 on 2022/04/29.
//

import Foundation

extension Array {
  func splitInSubArrays(into size: Int) -> [[Element]] {
    return (0..<size).map {
      stride(from: $0, to: count, by: size).map { self[$0] }
    }
  }

  func chunks(_ chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: self.count, by: chunkSize).map {
      Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
    }
  }
}
