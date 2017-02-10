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
    
    private var pageSize: Int
    
    private let section = GenericCollectionSection<STPost>()
    
    private var filter: STFeedFilter?
    
    private var users = Set<STUser>()
    
    private var hasMore = false
    
    private var onDataSourceChanged:(() -> Void)?
    
    private var isFavorite: Bool

    
    var canLoadNext: Bool {
        
        return hasMore && status != .loading
    }
    
    
    init(pageSize: Int = 20, isFavorite: Bool = false, onDataSourceChanged:(() -> Void)? = nil) {
        
        self.pageSize = pageSize
        self.isFavorite = isFavorite
        self.onDataSourceChanged = onDataSourceChanged
    }
    
    func initialize() {
        
        self.dataSource = GenericTableViewDataSource(cellClass: STPostTableViewCell.self) { [unowned self] (cell, item) in
            
            if item.indexPath.row + 10 > self.section.items.count && self.canLoadNext {
                
                self.loadFeed()
            }
            
            let post = item.item
            
            cell.selectionStyle = .none
            cell.postTitle.text = post.title
            cell.postDetails.text = post.postDescription
            cell.iconFavorite.isSelected = post.isFavorite
            cell.postType.isSelected = post.type == 2 ? true : false
            cell.postTime.text = post.createdAt?.elapsedInterval()
            
            if post.dateFrom != nil && post.dateTo != nil {
                
                cell.durationDate.isHidden = false
                let period = post.dateFrom!.shortLocalizedFormat + " - " + post.dateTo!.shortLocalizedFormat
                cell.durationDate.setTitle(period , for: .normal)
            }
            else {
                
                cell.durationDate.isHidden = true
            }
            
            if post.fileIds.count > 0 {
                
                cell.documents.isEnabled = true
                cell.documents.setTitle("\(post.fileIds.count)", for: .normal)
            }
            else {
                
                cell.documents.isEnabled = false
                cell.documents.setTitle("\(0)", for: .normal)
            }
            
            if post.imageIds.count > 0 {
                
                cell.images.isEnabled = true
                cell.images.setTitle("\(post.imageIds.count)", for: .normal)
            }
            else {
                
                cell.images.isEnabled = false
                cell.images.setTitle("\(0)", for: .normal)
            }
            
            if post.locationIds.count > 0 {
                
                cell.locations.isEnabled = true
                cell.locations.setTitle("\(post.locationIds.count)", for: .normal)
            }
            else {
                
                cell.locations.isEnabled = false
                cell.locations.setTitle("\(0)", for: .normal)
            }
            
            if let user = self.users.first(where: { $0.id == post.userId }) {
                
                cell.userName.text = user.lastName + " " + user.firstName
                
                guard !user.imageUrl.isEmpty else {
                    
                    return
                }
                
                let width = Int(cell.userIcon.bounds.size.width * UIScreen.main.scale)
                let height = Int(cell.userIcon.bounds.size.height * UIScreen.main.scale)
                
                let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                
                let urlString = user.imageUrl + queryResize
                
                let filter = RoundedCornersFilter(radius: cell.userIcon.bounds.size.width)
                cell.userIcon.af_setImage(withURL: URL(string: urlString)!,
                                          filter: filter,
                                          completion: nil)
            }
        }
        
        self.dataSource!.sections.append(self.section)
        
        self.filter = AppDelegate.appSettings.feedFilter
    }
    
    func loadFeedIfNotYet() {
        
        if self.section.items.count == 0 && self.status == .idle {
            
            loadFeed()
        }
    }
    
    
    func reloadFilter(notify: Bool) {
        
        self.filter = AppDelegate.appSettings.feedFilter
        self.section.items.removeAll()
        self.page = 1
        self.loadFeed(notify: notify)
    }
    
    
    func loadFeed(notify: Bool = true) {
        
        self.status = .loading
        
        AppDelegate.appSettings.api.loadFeed(filter: self.filter!, page: page, pageSize: pageSize, isFavorite: self.isFavorite)
            
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
                
                if notify {
                    
                    self.onDataSourceChanged?()
                }
            }
            .onFailure { [unowned self] error in
                
                self.status = .failed
            }
        }
}
