//
//  PHAsset+Extension.swift
//  winedining
//
//  Created by 이동석 on 2022/03/20.
//

import Foundation
import Photos
import UIKit

extension PHAsset {
  func getImage() -> UIImage {
    var img: UIImage?
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.version = .current
    options.isSynchronous = true
    options.isNetworkAccessAllowed = true
    manager.requestImage(for: self, targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight), contentMode: PHImageContentMode.default, options: options) { image, info in
      img = image
    }

    return img!
  }
}
