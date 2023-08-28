//
//  LocationManager.swift
//  spa
//
//  Created by 이동석 on 2022/12/06.
//

import Foundation
import CoreLocation
import RxSwift

class LocationManager {
  static let shared = LocationManager()
  let disposeBag = DisposeBag()

  var currentLocation: CLLocationCoordinate2D?
  var currentAddress: String?

  private init() {}

  func getCrrentLocationAddress(success: @escaping () -> Void) {
    guard let location = currentLocation else { return }
    let param = GetCoordToAddressRequest(
      x: location.longitude,
      y: location.latitude
    )
    APIService.shared.kakaoAPI.rx.request(.coordToAddress(param: param))
      .map(GetCoordToAddressResponse.self)
      .subscribe(onSuccess: { response in
        if let document = response.documents.first {
          let address = document.road_address?.address_name ?? document.address?.address_name
          log.info(address ?? "[NO ADDRESS]")
          self.currentAddress = address
        }
        success()
      }, onFailure: { error in
        log.error(error)
        success()
      })
      .disposed(by: disposeBag)
  }
}
