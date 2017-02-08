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
                
                DispatchQueue.global().async {
                    
                    self.loadFeed()
                }
            }
            
            let post = item.item
            
            cell.selectionStyle = .none
            cell.postTitle.text = post.title
            cell.postDetails.text = post.postDescription
            cell.iconFavorite.isSelected = post.isFavorite
            
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
    }
    
    func loadFeed() {
        
        self.status = .loading
        
        AppDelegate.appSettings.api.loadFeed(page: page, pageSize: pageSize)
            
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
                
                self.onDataSourceChanged?()
            }
            .onFailure { [unowned self] error in
                
                self.status = .failed
            }
        }
}
