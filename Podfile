# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

use_frameworks!
workspace 'Attorney'

def inheritFrameworks
   use_frameworks!
   inherit! :search_paths
end

def reactiveModule
  pod 'RxSwift', '~> 6.0'
  pod 'RxCocoa', '~> 6.0'
  pod 'RxDataSources', '~> 5.0'
  pod 'RxGesture', '~> 4.0'
  pod 'RxRealm', '~> 5.0'
end 

def common
  pod 'KeychainAccess', '~> 3.0'
  pod 'RealmSwift', '~> 10.5'
  pod 'EFQRCode', '~> 5.0.0'
  pod 'Instructions', '~> 1.4.0'
  pod 'Kingfisher', '~> 5.0'
  pod 'SwiftyGif'
  pod 'R.swift', '~> 6.1.0'
  pod 'IQKeyboardManagerSwift', '~> 6.0'
  pod 'JWTDecode'
  pod 'SwiftLint'
  pod 'Branch'
  pod "ReCaptcha/RxSwift", '~> 1.6.0'
  pod 'SkeletonView', '~> 1.13'
  pod 'lottie-ios', '~> 3.4.1'
end

def networking
  pod 'Moya/RxSwift', '15.0.0'
  pod 'ReachabilitySwift'
end

target 'Attorney' do
  inheritFrameworks
  reactiveModule
  common
  networking

end
