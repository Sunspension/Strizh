//
//  STHTTPManager.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 03/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import Alamofire
import BrightFutures
import AlamofireObjectMapper

class STHTTPManager {
    
    private static let alamofireManager: Alamofire.SessionManager = {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    
    private var serverBaseUrlString: String
    
    
    init(serverUrlString: String) {
        
        self.serverBaseUrlString = serverUrlString
    }
    
    func checkSession() -> Future<STSession, STAuthorizationError> {
        
        let p = Promise<STSession, STAuthorizationError>()
        
        request(method: .get, remotePath: serverBaseUrlString + "/api/auth")
            .responseJSON(completionHandler: self.printJSON)
            .validate()
            .responseObject(keyPath: "data",
                            completionHandler: { (response: DataResponse<STSession>) in
                                
                                guard response.result.error == nil else {
                                    
                                    p.failure(.undefinedError(error: response.result.error!))
                                    return
                                }
                                
                                p.success(response.value!)
            })
        
        return p.future
    }
    
    func registration(phoneNumber: String,
                      deviceType: String,
                      deviceToken: String) -> Future<STRegistration, STAuthorizationError> {
        
        let p = Promise<STRegistration, STAuthorizationError>()
        
        let params: [String: Any] = ["phone" : phoneNumber, "device_type" : deviceType, "device_token" : deviceToken];
        
        request(method: .post, remotePath: serverBaseUrlString + "/api/code", params: params)
            .responseJSON(completionHandler: { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    if let statusCode = response.response?.statusCode, statusCode != 200 {
                        
                        switch statusCode {
                            
                        case 422:
                            
                            if let result = response.result.value as? [String : Any] {
                                
                                p.failure(.requiredParameters(json: result))
                            }
                            
                            break
                            
                        case 400:
                            
                            p.failure(.toManyRequests)
                            
                            break
                            
                        default:
                            break
                        }
                    }
                    
                    print("Response result: \(response.result.value)")
                }
            })
            .responseObject(keyPath: "data",
                            completionHandler: { (response: DataResponse<STRegistration>) in
                                
                                guard response.result.error == nil else {
                                    
                                    return
                                }
                                
                                p.success(response.value!)
            })
        
        return p.future
    }
    
    func authorization(phoneNumber: String,
                       deviceToken: String,
                       code: String,
                       type: String,
                       application: String,
                       systemVersion: String,
                       applicationVersion: String) -> Future<STSession, STAuthorizationError> {
        
        let p = Promise<STSession, STAuthorizationError>()
        
        let systemVersion = UIDevice.current.systemVersion;
        let info = Bundle.main.infoDictionary
        let bundleId = Bundle.main.bundleIdentifier
        
        let applicationVersion = info?["CFBundleShortVersionString"]
        
        let params: [String: Any] = ["phone" : phoneNumber,
                                     "code" : code,
                                     "device_type" : "ios",
                                     "device_token" : deviceToken,
                                     "type" : "code",
                                     "application" : bundleId ?? "",
                                     "system_version" : systemVersion,
                                     "application_version" : applicationVersion ?? ""]
        
        request(method: .post, remotePath: serverBaseUrlString + "/api/auth", params: params)
            .responseJSON(completionHandler: { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    if let statusCode = response.response?.statusCode, statusCode != 200 {
                        
                        switch statusCode {
                            
                        case 422:
                            
                            if let result = response.result.value as? [String : Any] {
                                
                                p.failure(.requiredParameters(json: result))
                            }
                            
                            break
                            
                        case 400:
                            
                            p.failure(.codeNotFound)
                            
                            break
                            
                        default:
                            break
                        }
                    }
                    
                    print("Response result: \(response.result.value)")
                }
            })
            .responseObject(keyPath: "data",
                            completionHandler: { (response: DataResponse<STSession>) in
                                
                                guard response.result.error == nil else {
                                    
                                    return
                                }
                                
                                p.success(response.value!)
            })
        
        return p.future
    }
    
    func logout() -> Future<STSession, STAuthorizationError> {
        
        let p = Promise<STSession, STAuthorizationError>()
        
        request(method: .delete, remotePath: serverBaseUrlString + "/api/auth")
            .responseJSON(completionHandler: self.printJSON)
            .validate()
            .responseObject(keyPath: "data",
                            completionHandler: { (response: DataResponse<STSession>) in
                                
                                guard response.result.error == nil else {
                                    
                                    p.failure(.undefinedError(error: response.result.error!))
                                    return
                                }
                                
                                p.success(response.value!)
            })
        
        return p.future
    }
    
    func uploadImage(image: UIImage) -> Future<STImage, STImageUploadError> {
        
        let p = Promise<STImage, STImageUploadError>()
        
        STHTTPManager.alamofireManager.upload(multipartFormData: { multipartFormData in
            
            if let data = UIImageJPEGRepresentation(image, 0.85) {
                
                multipartFormData.append(data, withName: "file", fileName: "jpg", mimeType: "image/jpeg")
            }
            
        }, to: serverBaseUrlString + "/api/image") { encodingResult in
            
            switch encodingResult {
                
            case .success(let upload, _, _):
                
                upload
                    .responseJSON { response in
                        
                        if let error = response.result.error {
                            
                            print("Response error: \(error)")
                        }
                        else {
                            
                            if let statusCode = response.response?.statusCode, statusCode != 200 {
                                
                                switch statusCode {
                                    
                                case 400:
                                    
                                    if let result = response.result.value as? [String : Any] {
                                        
                                        p.failure(.invalidJSON(json: result))
                                    }
                                    
                                    break
                                    
                                default:
                                    break
                                }
                            }
                            
                            print("Response result: \(response.result.value)")
                        }
                    }
                    .responseObject(keyPath: "data") { (response: DataResponse<STImage>) in
                        
                        guard response.result.error == nil else {
                            
                            return
                        }
                        
                        p.success(response.result.value!)
                }
                
            case .failure(let encodingError):
                
                p.failure(.encodingError(message: encodingError.localizedDescription))
                print(encodingError)
            }
        }
        
        return p.future
    }
    
    
    func updateUserInformation(userId: Int,
                               firstName: String? = nil,
                               lastName: String? = nil,
                               email: String? = nil,
                               imageId: Int? = nil) -> Future<STUser, STError>{
        
        var params = [String : Any]()
        
        if let firstName = firstName {
            
            params["first_name"] = firstName
        }
        
        if let lastName = lastName {
            
            params["last_name"] = lastName
        }
        
        if let email = email {
            
            params["email"] = email
        }
        
        if let image = imageId {
            
            params["imaged_id"] = image
        }
        
        let p = Promise<STUser, STError>()
        
        request(method: .put, remotePath: serverBaseUrlString + "/api/user/\(userId)", params: params)
            .responseJSON(completionHandler: self.printJSON)
            .responseObject(keyPath: "data",
                            completionHandler: { (response: DataResponse<STUser>) in
                                
                                guard response.result.error == nil else {
                                    
                                    p.failure(.anyError(error: response.result.error!))
                                    return
                                }
                                
                                p.success(response.value!)
            })
        
        return p.future
    }
    
    
    func loadUser(userId: Int) -> Future<STUser, STError> {
        
        let p = Promise<STUser, STError>()
        
        request(method: .get, remotePath: serverBaseUrlString + "/api/user/\(userId)")
            .responseJSON(completionHandler: self.printJSON)
            .responseObject(keyPath: "data",
                            completionHandler: { (response: DataResponse<STUser>) in
                                
                                guard response.result.error == nil else {
                                    
                                    p.failure(.anyError(error: response.result.error!))
                                    return
                                }
                                
                                p.success(response.value!)
            })
        
        return p.future
    }
    
    
    
    // MARK: - Private methods
    fileprivate func printJSON(_ response: DataResponse<Any>) {
        
        if let error = response.result.error {
            
            print("Response error: \(error)")
        }
        else {
            
            print("Response result: \(response.result.value)")
        }
    }
    
    
    fileprivate func request(method: HTTPMethod, remotePath: URLConvertible, params: [String : Any]? = nil) -> DataRequest {
        
        return self.request(method: method, remotePath: remotePath, params: params, headers: nil);
    }
    
    fileprivate func request(method: HTTPMethod, remotePath: URLConvertible, params: Parameters?, headers: [String : String]?) -> DataRequest {
        
        let request = STHTTPManager.alamofireManager.request(remotePath,
                                                           method: method,
                                                           parameters: params,
                                                           encoding: method != .post ? URLEncoding.default : JSONEncoding.default,
                                                           headers: headers)
        
        print("request: \(request)\n parameters: \(params)")
        return request
    }
}