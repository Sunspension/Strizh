source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.3'
use_frameworks!

def common_pods
    
    pod 'Alamofire', '~> 4.3'
    pod 'ObjectMapper', '< 2.2.9'
    pod 'AlamofireObjectMapper', '~> 4.0'
    pod 'AlamofireImage', '~> 3.1'
    pod 'BrightFutures'
    pod 'Bond', '< 6.2.7'
    pod 'Socket.IO-Client-Swift', '< 12'
    pod 'Firebase/Crash'
    #    pod 'PhoneNumberKit', '~> 1.2'
    pod 'SHSPhoneComponent'
    #    pod 'Mortar'
    pod 'NVActivityIndicatorView'
    #    pod 'EmitterKit'
    pod 'GoogleMaps'
    pod 'DKImagePickerController'
    pod 'KDCircularProgress'
    pod 'Dip'
    pod 'Dip-UI'
    pod 'Flurry-iOS-SDK/FlurrySDK'
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
