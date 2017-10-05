source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.3'
use_frameworks!

def common_pods
    
    pod 'Alamofire', '~> 4.3'
    pod 'ObjectMapper'
    pod 'AlamofireObjectMapper'
    pod 'AlamofireImage', '~> 3.1'
    pod 'BrightFutures'
    pod 'Bond'
    pod 'Socket.IO-Client-Swift'
#    pod 'Firebase/Crash'
    #    pod 'PhoneNumberKit', '~> 1.2'
    pod 'SHSPhoneComponent'
    #    pod 'Mortar'
    pod 'NVActivityIndicatorView'
    #    pod 'EmitterKit'
    pod 'GoogleMaps'
    pod 'DKImagePickerController'
    pod 'KDCircularProgress', :git => 'https://github.com/kaandedeoglu/KDCircularProgress.git'
    pod 'Dip'
    pod 'Dip-UI'
    pod 'Flurry-iOS-SDK/FlurrySDK'
    pod 'Fabric'
    pod 'Crashlytics'
    #    pod 'Gemini'
    #    pod 'ActiveLabel'
    #    pod 'TTTAttributedLabel'
    #    pod 'RxSwift', '~> 3.0'
    #    pod 'RxCocoa', '~> 3.0'
    #    pod 'RxDataSources', '~> 1.0'
    #    pod 'APNGKit', '~> 0.6'
end

target 'StrizhApp' do
    
    common_pods
    pod 'RealmSwift'
end

target 'StrizhAppDev' do
    
    common_pods
    pod 'RealmSwift'
end

target 'StrizhAppStage' do
    
    common_pods
    pod 'RealmSwift'
end


target 'StrizhAppTests' do
    
    common_pods
    pod 'Realm'
end

