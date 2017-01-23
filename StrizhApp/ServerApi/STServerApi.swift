//
//  STServerApi.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import Alamofire
import BrightFutures
import AlamofireObjectMapper
import SocketIO

struct STServerApi: PRemoteServerApi {
    
    private static let alamofireManager: Alamofire.SessionManager = {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    private var socket: SocketIOClient
    
    private var serverBaseUrlString: String
    
    
    init(serverUrlString: String) {
        
        self.serverBaseUrlString = serverUrlString
        let config: SocketIOClientConfiguration = [.log(true), .forcePolling(true)]
        self.socket = SocketIOClient(socketURL: URL(string: serverBaseUrlString)!, config: config)
    }
    
    func checkSession() -> Future<Session, STAuthorizationError> {
        
        let p = Promise<Session, STAuthorizationError>()
        
        request(method: .get, remotePath: serverBaseUrlString + "/api/auth")
        .responseJSON(completionHandler: self.printJSON)
        .validate()
        .responseObject(keyPath: "data",
                        completionHandler: { (response: DataResponse<Session>) in
                            
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
                      deviceToken: String) -> Future<Registration, STAuthorizationError> {
        
        let p = Promise<Registration, STAuthorizationError>()
        
        request(method: .post, remotePath: serverBaseUrlString + "/api/code")
        .responseJSON(completionHandler: { response in
            
            if let error = response.result.error {
                
                print("Response error: \(error)")
            }
            else {
                
                if let statusCode = response.response?.statusCode {
                    
                    switch statusCode {
                        
                    case 422:
                        
                        if let result = response.result.value as? [String : Any] {
                            
                            p.failure(.requiredParameters(json: result))
                        }
                        
                    case 400:
                        
                        p.failure(.toManyRequests)
                        
                    default:
                        
                        p.failure(.undefinedError(error: response.result.error!))
                    }
                }
                
                print("Response result: \(response.result.value)")
            }
        })
        .responseObject(keyPath: "data",
                        completionHandler: { (response: DataResponse<Registration>) in
                            
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
                       applicationVersion: String) -> Future<Session, STAuthorizationError> {
        
        let p = Promise<Session, STAuthorizationError>()
        
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
        
        request(method: .post, remotePath: serverBaseUrlString + "/api/auth", parameters: params)
            .responseJSON(completionHandler: { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    if let statusCode = response.response?.statusCode {
                        
                        switch statusCode {
                            
                        case 422:
                            
                            if let result = response.result.value as? [String : Any] {
                                
                                p.failure(.requiredParameters(json: result))
                            }
                            
                        case 400:
                            
                            p.failure(.codeNotFound)
                            
                        default:
                            
                            p.failure(.undefinedError(error: response.result.error!))
                        }
                    }
                    
                    print("Response result: \(response.result.value)")
                }
            })
            .responseObject(keyPath: "data",
                            completionHandler: { (response: DataResponse<Session>) in
                                
                                guard response.result.error == nil else {
                                    
                                    return
                                }
                                
                                p.success(response.value!)
            })
        
        return p.future
    }
    
    func logout() -> Future<Session, STAuthorizationError> {
        
        let p = Promise<Session, STAuthorizationError>()
        
        request(method: .delete, remotePath: serverBaseUrlString + "/api/auth")
            .responseJSON(completionHandler: self.printJSON)
            .validate()
            .responseObject(keyPath: "data",
                            completionHandler: { (response: DataResponse<Session>) in
                                
                                guard response.result.error == nil else {
                                    
                                    p.failure(.undefinedError(error: response.result.error!))
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
    
    fileprivate func request(method: HTTPMethod, remotePath: URLConvertible) -> DataRequest {
        
        return self.request(method: method, remotePath: remotePath, parameters: nil)
    }
    
    fileprivate func request(method: HTTPMethod, remotePath: URLConvertible, parameters: [String : Any]?) -> DataRequest {
        
        return self.request(method: method, remotePath: remotePath, parameters: parameters, headers: nil);
    }
    
    fileprivate func request(method: HTTPMethod, remotePath: URLConvertible, parameters: Parameters?, headers: [String : String]?) -> DataRequest {
        
        let request = STServerApi.alamofireManager.request(remotePath,
                                                           method: method,
                                                           parameters: parameters,
                                                           encoding: method != .post ? URLEncoding.default : JSONEncoding.default,
                                                           headers: headers)
        
        print("request: \(request)\n parameters: \(parameters)")
        return request
    }
}
