//
//  SelectLocationViewController.swift
//  spa
//
//  Created by 이동석 on 2022/12/06.
//

import UIKit
import CoreLocation
import KakaoMapsSDK
import Alamofire
import SwiftyJSON

class SelectLocationViewController: BaseViewController {
  @IBOutlet var mapView: MTMapView!
  @IBOutlet var saveButton: UIButton!
  @IBOutlet var addressSearchButton: UIImageView!
  @IBOutlet var addressTextField: UITextField!
  
  @objc func doneButtonClicked(_ sender: Any) {
    searchAddress()
  }
  func searchAddress(){
      if self.addressTextField.text == ""{
        self.callOkCancelMSGDialog(message: "검색어를 입력해주세요.") {
        }
        return
      }
      self.getCoordinates(self.addressTextField.text ?? "") { latitude, longitude in
          self.mapView?.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude)), zoomLevel: -1, animated: false)
      }
  }
  
  func getCoordinates(_ location: String, completion: @escaping (Double, Double) -> Void) {
    self.showHUD()
    
    let apiurl = "https://dapi.kakao.com/v2/local/search/keyword"
    let url = URL(string: "\(apiurl)")!
    let requestURL = url
      .appending("query", value: location)
    
    var request = URLRequest(url: requestURL)
    request.httpMethod = HTTPMethod.get.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("KakaoAK 38913938658c43e926d58c656dc123ee", forHTTPHeaderField: "Authorization")
    
    AF.request(request).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        print(value)
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        if let data = jsonData, let value = try? decoder.decode(ResponseData.self, from: data) {
          self.dismissHUD()
          guard let placemark = value.documents.first else{
            return
          }
          completion(Double(placemark.y)!, Double(placemark.x)!)
        }
        break
      case .failure:
        print("error: \(response.error!)")
        self.dismissHUD()
        break
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
        self.searchAddress()
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
      self.searchAddress()
      textField.resignFirstResponder() // 키보드를 숨기기 위해 텍스트 필드로의 첫 응답자(responder) 상태를 해제합니다.
      return true
  }
}

