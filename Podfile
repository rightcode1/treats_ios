# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end
  end
end

target 'Treat' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for myrrors

  pod 'Firebase'
  pod 'Firebase/Messaging'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'

  pod 'RxSwift'
  pod 'RxGesture'
  pod 'RxKeyboard'
  #  pod 'RxCoreLocation'

  pod 'Alamofire'
  pod 'RxAlamofire'

  pod 'Moya'
  pod 'Moya/RxSwift'

  pod 'Kingfisher'
  pod 'IQKeyboardManagerSwift'
  pod 'FittedSheets'
  pod 'BSImagePicker'
  pod 'CocoaLumberjack/Swift'
  pod 'Then'
  pod 'JGProgressHUD'
  pod 'CropViewController'
  pod 'ReachabilitySwift'
  pod 'FittedSheets'
  pod 'DropDown'
  pod 'FSPagerView'
  pod 'Socket.IO-Client-Swift'
pod 'DKImagePickerController'
  pod 'iamport-ios'
  pod 'Gifu'

  pod 'KakaoSDKCommon'  # 필수 요소를 담은 공통 모듈
  pod 'KakaoMapsSDK'  # 카카오 맵
  pod 'KakaoSDKAuth'  # 사용자 인증
  pod 'KakaoSDKUser'  # 카카오 로그인, 사용자 관리
  pod 'KakaoSDKShare'
  pod 'RxKakaoSDKCommon'  # 필수 요소를 담은 공통 모듈
  pod 'RxKakaoSDKAuth'  # 사용자 인증
  pod 'RxKakaoSDKUser'  # 카카오 로그인, 사용자 관리
  pod 'RxKakaoSDKShare'
  pod 'GoogleSignIn', '~> 5.0.2'
  pod 'naveridlogin-sdk-ios'
  pod 'SwiftyJSON'


#  pod 'JTAppleCalendar'
end


