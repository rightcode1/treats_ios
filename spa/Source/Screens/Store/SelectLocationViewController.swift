//
//  SelectLocationViewController.swift
//  spa
//
//  Created by 이동석 on 2022/12/06.
//

import UIKit
import CoreLocation
import KakaoMapsSDK

class SelectLocationViewController: BaseViewController {
  @IBOutlet var mapView: MTMapView!
  @IBOutlet var saveButton: UIButton!
  @IBOutlet var addressSearchButton: UIImageView!
  @IBOutlet var addressTextField: UITextField!
  
  @objc func doneButtonClicked(_ sender: Any) {
    if self.addressTextField.text == ""{
      self.callOkCancelMSGDialog(message: "검색어를 입력해주세요.") {
      }
      return
    }
    
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(self.addressTextField.text ?? "") { (placemarks, error) in
      print(placemarks)
        guard let placemark = placemarks?.first,
              let location = placemark.location else {
            // 지오코딩 실패 또는 결과 없음
            return
        }
      
      DispatchQueue.main.async{
        self.mapView?.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)), zoomLevel: -1, animated: false)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    mapView.delegate = self
    addressTextField
      .delegate = self
    addressTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))

    if let coordinate = LocationManager.shared.currentLocation {
      let point = MTMapPoint(geoCoord: MTMapPointGeo(latitude: coordinate.latitude, longitude: coordinate.longitude))
      mapView?.setMapCenter(point, zoomLevel: -1, animated: false)
    }

    saveButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.setCurrentLocation()
      })
      .disposed(by: disposeBag)
    
    addressSearchButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.addressTextField.text ?? "") { (placemarks, error) in
          print(placemarks)
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                // 지오코딩 실패 또는 결과 없음
                return
            }
          
          DispatchQueue.main.async{
            self.mapView?.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)), zoomLevel: -1, animated: false)
          }
        }
      })
      .disposed(by: disposeBag)
  }

  func setCurrentLocation() {
    showHUD()
    let location = mapView.mapCenterPoint.mapPointGeo()
    LocationManager.shared.currentLocation = CLLocationCoordinate2D(
      latitude: location.latitude,
      longitude: location.longitude
    )
    LocationManager.shared.getCrrentLocationAddress {
      self.dismissHUD()
      self.backPress()
    }
  }
}

extension SelectLocationViewController: MTMapViewDelegate {
//  func mapView(_ mapView: MTMapView!, centerPointMovedTo mapCenterPoint: MTMapPoint!) {
//    log.info(mapCenterPoint)
//  }
}
extension SelectLocationViewController: UITextFieldDelegate {
  // 클래스 내용
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // 엔터 버튼을 눌렀을 때 수행할 동작
    if self.addressTextField.text == ""{
      self.callOkCancelMSGDialog(message: "검색어를 입력해주세요.") {
      }
      return true
    }
    
    let geocoder = CLGeocoder()
    
    geocoder.geocodeAddressString(self.addressTextField.text ?? "") { (placemarks, error) in
        guard let placemark = placemarks?.first,
              let location = placemark.location else {
            // 지오코딩 실패 또는 결과 없음
            return
        }
      
      DispatchQueue.main.async{
        self.mapView?.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)), zoomLevel: -1, animated: false)
      }
    }
      textField.resignFirstResponder() // 키보드를 숨기기 위해 텍스트 필드로의 첫 응답자(responder) 상태를 해제합니다.
      return true
  }
}

