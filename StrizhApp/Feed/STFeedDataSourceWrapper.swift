//
//  STFeedDataSource.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 07/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import BrightFutures
import AlamofireImage

class STFeedDataSourceWrapper {

    var dataSource: GenericTableViewDataSource<STPostTableViewCell, STPost>?
    
    private var status = STLoadingStatusEnum.idle
    
    private var page = 1
    
    private var pageSize: Int?
    
    private let section = GenericCollectionSection<STPost>()
    
    private var users = Set<STUser>()
    
    private var hasMore = false
    
    private var onCollectionChanged:(() -> Void)?
    
    
    var canLoadNext: Bool {
        
        return hasMore && status != .loading
    }
    
    init(pageSize: Int? = 20, onCollectionChanged:(() -> Void)? = nil) {
        
        self.pageSize = pageSize
        self.onCollectionChanged = onCollectionChanged
    }
    
    func initialize() {
        
        self.dataSource = GenericTableViewDataSource(nibClass: STPostTableViewCell.self) { [unowned self] (cell, item) in
            
            if item.indexPath.row + 10 > self.section.items.count && self.canLoadNext {
                
                self.loadFeed()
            }
            
            let post = item.item
            
            cell.selectionStyle = .none
            cell.postTitle.text = post.title
            cell.postDetails.text = post.postDescription
            
            if let user = self.users.first(where: { $0.id == post.userId }) {
                
                cell.userName.text = user.lastName + " " + user.firstName
                
                var filters = [ImageFilter]()
                
                filters.append(AspectScaledToFillSizeFilter(size: cell.userIcon.bounds.size))
                filters.append(RoundedCornersFilter(radius: cell.userIcon.bounds.size.width))
                let compositeFilter = DynamicCompositeImageFilter(filters)
                
                cell.userIcon.af_setImage(withURL: URL(string: user.imageUrl!)!,
                                          filter: compositeFilter, completion: nil)
            }
        }
        
        self.dataSource!.sections.append(self.section)
    }
    
    func loadFeed() {
        
        self.status = .loading
        
        AppDelegate.appSettings.api.loadFeed(page: page, pageSize: pageSize ?? 20)
            
            .onSuccess { [unowned self] (posts, users) in
                
                users.forEach({ user in
                    
                    self.users.insert(user)
                })
                
                posts.forEach { post in
                    
                    self.section.add(item: post)
                }
                
                self.hasMore = posts.count == self.pageSize
                
                self.page += 1
                
                self.status = .loaded
                
                self.onCollectionChanged?()
            }
            .onFailure { [unowned self] error in
                
                self.status = .failed
            }
        }
}
