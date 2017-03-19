//
//  STSocketPayLoad.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 03/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import Contacts

private enum PayLoadParametersEnum : String {
    
    case path = "path"
    case method = "method"
    case body = "body_params"
    case query = "query_params"
    case requestId = "request_id"
}

private enum QueryParametersEnum : String {
    
    case page = "page"
    case pageSize = "page_size"
    case sortingOrder = "order"
    case conditions = "conditions"
    case filters = "filters"
    case extend = "extend"
    case query = "query"
}

enum STSocketRequestBuilder {
    
    case loadUser(id: Int)
    
    case loadFeed(filter: STFeedFilter, page: Int, pageSize: Int,
        isFavorite: Bool, searchString: String?)
    
    case loadPersonalPosts(minId: Int, pageSize: Int)
    
    case favorite(postId: Int, favorite: Bool)
    
    case updateUserInformation(userId: Int,
        firstName: String?,
        lastName: String?,
        email: String?,
        imageId: Int64?)
    
    case archivePost(postId: Int, isArchived: Bool)
    
    case deletePost(postId: Int)
    
    case loadContacts
    
    case uploadContacts(contacts: [CNContact])
    
    case createPost(post: STNewPostObject)
    
    
    var request: STSocketRequest {
        
        var payLoad = [String : Any]()
        
        var query = [String : Any]()
        
        
        switch self {
            
        case .loadUser(let id):
            
            self.addToPayload(&payLoad, type: .path, value: "/api/user/\(id)")
            self.addToPayload(&payLoad, type: .method, value: "GET")
            
            break
            
        case .updateUserInformation(let userId, let firstName, let lastName, let email, let imageId):
            
            self.addToPayload(&payLoad, type: .path, value: "/api/user/\(userId)")
            self.addToPayload(&payLoad, type: .method, value: "PUT")
            
            var body = [String : Any]()
            
            body["first_name"] = firstName
            body["last_name"] = lastName
            
            if let email = email {
                
                body["email"] = email
            }
            
            if let imageId = imageId {
                
                body["image_id"] = imageId
            }
            
            self.addToPayload(&payLoad, type: .body, value: body)
            
            break
            
        case .loadPersonalPosts(let minId, let pageSize):
            
            // query
            if minId > 0 {
                
                self.addToQuery(&query, type: .conditions, value: ["id" : ["<" : minId]])
            }
            
            self.addToQuery(&query, type: .pageSize, value: pageSize)
            self.addToQuery(&query, type: .sortingOrder, value: ["id" : "desc"])
            self.addToQuery(&query, type: .extend, value: "user, file, location, image")
            
            // payload
            self.addToPayload(&payLoad, type: .path, value: "/api/post")
            self.addToPayload(&payLoad, type: .method, value: "GET")
            
            break
            
        case .loadFeed(let filter, let page, let pageSize, let isFavorite, let searchString):
            
            // query
            self.addToQuery(&query, type: .page, value: page)
            self.addToQuery(&query, type: .pageSize, value: pageSize)
            self.addToQuery(&query, type: .sortingOrder, value: ["id" : "desc"])
            
            if let queryString = searchString {
                
                self.addToQuery(&query, type: .query, value: queryString)
            }
            
            var filters: [String : Any] = [:]
            
            if isFavorite {
                
                filters["is_favorite"] = true
//                self.addToQuery(&query, type: .sortingOrder, value: ["updated_at" : "desc"])
            }
            else {
                
                filters["feed"] = true
//                self.addToQuery(&query, type: .sortingOrder, value: ["id" : "desc"])
            }
            
            // archived
            var archived = [Bool]()
            
            if filter.showArchived {
                
                archived.append(contentsOf: [true, false])
            }
            else {
                
                archived.append(false)
            }
            
            filters["is_archived"] = archived
            
            // post types
            var types = [Int]()
            
            if filter.offer {
                
                types.append(1)
            }
            
            if filter.search {
                
                types.append(2)
            }
            
            filters["type"] = types
            
            self.addToQuery(&query, type: .filters, value: filters)
            self.addToQuery(&query, type: .extend, value: "user, file, location, image")
            
            // payload
            self.addToPayload(&payLoad, type: .path, value: "/api/post")
            self.addToPayload(&payLoad, type: .method, value: "GET")
            
            break
            
        case .favorite(let postId, let favorite):
            
            // payload
            self.addToPayload(&payLoad, type: .path, value: "/api/post/\(postId)")
            self.addToPayload(&payLoad, type: .method, value: "PUT")
            self.addToPayload(&payLoad, type: .body, value: ["is_favorite" : favorite])
            
            break
            
        case .archivePost(let postId, let isArchived):
            
            // payload
            self.addToPayload(&payLoad, type: .path, value: "/api/post/\(postId)")
            self.addToPayload(&payLoad, type: .method, value: "PUT")
            self.addToPayload(&payLoad, type: .body, value: ["is_archived" : isArchived])
            
            break
            
        case .deletePost(let postId):
            
            // payload
            self.addToPayload(&payLoad, type: .path, value: "/api/post/\(postId)")
            self.addToPayload(&payLoad, type: .method, value: "DELETE")
            
            break
            
        case .loadContacts:
            
            self.addToPayload(&payLoad, type: .path, value: "/api/contact")
            self.addToPayload(&payLoad, type: .method, value: "GET")
            
            break
            
        case .uploadContacts(let contacts):
            
            self.addToPayload(&payLoad, type: .path, value: "/api/contact")
            self.addToPayload(&payLoad, type: .method, value: "POST")
            
            var body = [[String : Any]]()
            
            contacts.forEach({ contact in
                
                var cn = [String: Any]()
                
                if let phone = contact.phoneNumbers.first {
                    
                    var phoneNumber = phone.value.stringValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    
                    if phoneNumber.characters.first == "8" {
                        
                       phoneNumber = "7" + String(phoneNumber.characters.dropFirst())
                    }
                    
                    if phoneNumber.characters.count != 11 {
                        
                        return
                    }
                    
                    cn["phone"] = phoneNumber
                    cn["first_name"] = contact.givenName
                    cn["last_name"] = contact.familyName
                    
                    body.append(cn)
                }
            })
            
            self.addToPayload(&payLoad, type: .body, value: body)
            
            break
            
        case .createPost(let post):
            
            // payload
            self.addToPayload(&payLoad, type: .path, value: "/api/post")
            self.addToPayload(&payLoad, type: .method, value: "POST")
            
            var body = [String : Any]()
            
            body["title"] = post.title
            body["description"] = post.details
            body["type"] = post.type
            
            if !post.price.isEmpty {
                
                body["price"] = post.price
            }
            
            if !post.priceDescription.isEmpty {
                
                body["price_description"] = post.priceDescription
            }
            
            if !post.profitDescription.isEmpty {
                
                body["profit_description"] = post.profitDescription
            }
            
            if post.imageIds != nil {
                
                body["image_ids"] = post.imageIds!
            }
            
            if post.userIds.count > 0 {
                
                body["user_ids"] = post.userIds
            }
            
            if post.locationIds != nil {
                
                body["location_ids"] = post.locationIds!
            }
            
            self.addToPayload(&payLoad, type: .body, value: body)
            
            break
        }
     
        if query.count > 0 {
            
            self.addToPayload(&payLoad, type: .query, value: query)
        }
        
        let requestId = UUID().uuidString
        self.addToPayload(&payLoad, type: .requestId, value: requestId)
        
        return STSocketRequest(payLoad: payLoad, requestId: requestId)
    }
    
    private func addToQuery(_ params: inout [String : Any], type: QueryParametersEnum, value: Any) {
        
        params[type.rawValue] = value
    }
    
    private func addToPayload(_ params: inout [String : Any], type: PayLoadParametersEnum, value: Any) {
        
        params[type.rawValue] = value
    }
}
