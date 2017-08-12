//
//  STAnyUserProfileController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage

class STAnyUserProfileController: UITableViewController {
    
    fileprivate let initialNaviLabelOffset: CGFloat = 36.0
    
    fileprivate let naviLabelStopOffset: CGFloat = -20
    
    fileprivate var feedItems: STUserFeedDataSource?
    
    fileprivate var sections = [TSection]()
    
    fileprivate let userInfoSection = TSection()
    
    fileprivate let userFeedSection = TSection()
    
    fileprivate let headerLabel = UILabel()
    
    var backgroundBarView: UIView?
    
    var labelContainerView = UIView()
    
    var backgroundBarViewAlpha: CGFloat = 1
    
    fileprivate var user: STUser
    
    fileprivate var myUser: STUser {
        
        return STUser.objects(by: STUser.self).first!
    }
    
    deinit {
        
        print("")
    }
    
    init(user: STUser) {
        
        self.user = user
        self.feedItems = STUserFeedDataSource(userId: user.id)
        
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.stLightBlueGrey
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 176
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 18, left: 0, bottom: 7, right: 0)
        
        tableView.register(nibClass: STProfileHeaderCell.self)
        tableView.register(nibClass: STUserPostCell.self)
        tableView.register(headerFooterNibClass: STProfileFooterCell.self)
        
        automaticallyAdjustsScrollViewInsets = false
        
        headerLabel.textAlignment = .center
        
        headerLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
        headerLabel.text = user.firstName + " " + user.lastName
        headerLabel.sizeToFit()
        
        labelContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        labelContainerView.addSubview(headerLabel)
        labelContainerView.clipsToBounds = true
        labelContainerView.backgroundColor = UIColor.clear
        labelContainerView.isUserInteractionEnabled = false
        
        setCustomBackButton()
        
        setupDataSource()
        feedItems?.loadFeed()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
     
        UIView.animate(withDuration: 0.3) { 
            
            self.headerLabel.alpha = 0
        }
        
        // checking press back button
        if self.navigationController?.viewControllers.index(of: self) == nil {
            
            backgroundBarView?.alpha = 1
            labelContainerView.removeFromSuperview()
            headerLabel.removeFromSuperview()
        }
        else {
            
            // save state
            if let backNavView = backgroundBarView {
                
                backgroundBarViewAlpha = backNavView.alpha
                backNavView.alpha = 1
            }
        }
    }
    
    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.5) { 
            
            self.headerLabel.alpha = 1
        }
        
        if labelContainerView.superview != nil {
            
            if let backNavView = backgroundBarView {
                
                backNavView.alpha = backgroundBarViewAlpha
            }
            
            return
        }
        
        guard let bar = navigationController?.navigationBar else {
            
            return
        }
        
        backgroundBarView = bar.subviews.first(where: { String(describing: $0.self).contains("_UIBarBackground") })
        backgroundBarView?.alpha = 0
        
        bar.insertSubview(labelContainerView, at: 0)
        
        labelContainerView.frame = bar.bounds
        
        headerLabel.layer.transform = CATransform3DMakeTranslation(0, initialNaviLabelOffset, 0)
        headerLabel.center = bar.center
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.sections[indexPath.section].items[indexPath.row]
        
        switch indexPath.section {
            
        case 0:
        
            let cell: STProfileHeaderCell = tableView.dequeueReusableCell(for: indexPath)
            
            let user = item.model as! STUser
            
            cell.userName.text = user.firstName + " " + user.lastName
            
            if let imageData = user.imageData {
                
                var image = UIImage(data: imageData)!
                image = image.af_imageAspectScaled(toFill: cell.userImage.bounds.size)
                cell.setImageWithTransition(image: image.af_imageRoundedIntoCircle())
            }
            else {
                
                if !self.user.imageUrl.isEmpty {
                    
                    let urlString = self.user.imageUrl + cell.userImage.queryResizeString()
                    let filter = RoundedCornersFilter(radius: cell.userImage.bounds.width)
                    
                    cell.userImage.af_setImage(withURL: URL(string: urlString)!, filter: filter, imageTransition: .crossDissolve(0.3))
                }
                else {
                    
                    var defaultImage = UIImage(named: "avatar")
                    defaultImage = defaultImage?.af_imageAspectScaled(toFill: cell.userImage.bounds.size)
                    cell.setImageWithTransition(image: defaultImage?.af_imageRoundedIntoCircle())
                }
            }
            
            cell.edit.alpha = 0
            cell.settings.alpha = 0
            cell.selectionStyle = .none
            
            return cell
            
        case 1:
            
            if indexPath.row + 10 > self.userFeedSection.items.count &&
                self.feedItems!.canLoadNext {
                
                self.feedItems!.loadFeed()
            }
            
            let cell: STUserPostCell = tableView.dequeueReusableCell(for: indexPath)
            let post = item.model as! STPost
            
            cell.selectionStyle = .none
            cell.postTitle.text = post.title
            cell.postDetails.text = post.postDescription
            cell.postTime.text = post.createdAt?.mediumLocalizedFormat
            cell.isSearch = post.type == 2
            
            cell.onFavoriteButtonTap = { [cell, unowned self] in
                
                let favorite = !cell.iconFavorite.isSelected
                cell.iconFavorite.isSelected = favorite
                
                self.api.favorite(postId: post.id, favorite: favorite)
                    .onSuccess(callback: { [post] postResponse in
                        
                        post.isFavorite = postResponse.isFavorite
                        NotificationCenter.default.post(name: NSNotification.Name(kItemFavoriteNotification), object: postResponse)
                    })
            }
            
            if post.dateFrom != nil && post.dateTo != nil {
                
                cell.durationDate.isHidden = false
                let period = post.dateFrom!.mediumLocalizedFormat + " - " + post.dateTo!.mediumLocalizedFormat
                cell.durationDate.setTitle(period , for: .normal)
            }
            else {
                
                cell.durationDate.isHidden = true
            }
            
            // user
            cell.userName.text = user.lastName + " " + user.firstName
            
            if user.id == user.id && self.myUser.imageData != nil {
                
                if let image = UIImage(data: self.myUser.imageData!) {
                    
                    let userIcon = image.af_imageAspectScaled(toFill: cell.userIcon.bounds.size)
                    cell.userIcon.imageView?.image = userIcon.af_imageRoundedIntoCircle()
                }
            }
            else {
                
                if user.imageUrl.isEmpty {
                    
                    var defaultImage = UIImage(named: "avatar")
                    defaultImage = defaultImage?.af_imageAspectScaled(toFill: cell.userIcon.bounds.size)
                    cell.userIcon.imageView?.image = defaultImage?.af_imageRoundedIntoCircle()
                }
                else {
                    
                    let urlString = user.imageUrl + cell.userIcon.queryResizeString()
                    let filter = RoundedCornersFilter(radius: cell.userIcon.bounds.size.width)
                    cell.userIcon.af_setImage(for: .normal, url: URL(string: urlString)!, filter: filter)
                }
            }
            
            return cell
            
        default:
            
            return UITableViewCell()
        }
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        guard indexPath.section != 0 else {
            
            return
        }
        
        let post = self.feedItems!.posts[indexPath.row]
        
        let images = self.feedItems!.imagesBy(post: post)
        
        let files = self.feedItems!.filesBy(post: post)
        
        let locations = self.feedItems!.locationsBy(post: post)
        
        self.st_router_openPostDetails(post: post, user: user, images: images,
                                       files: files, locations: locations)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section != 0 {
            
            return nil
        }
        
        let footer: STProfileFooterCell = tableView.dequeueReusableHeaderFooterView()
        footer.label.text = "settings_page_topics_text".localized.uppercased() + ":"
        
        return footer
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return section == 0 ? 40 : 0
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        if offset > 0 {
            
            let labelTransform = CATransform3DMakeTranslation(0, max(naviLabelStopOffset, initialNaviLabelOffset - offset), 0)
            headerLabel.layer.transform = labelTransform
        }
        else {
            
            headerLabel.layer.transform = CATransform3DMakeTranslation(0, initialNaviLabelOffset, 0)
        }

        var alpha = offset / 35
        
        if alpha > 1 {
            
           alpha = 1
        }
        else if alpha < 0 {
            
            alpha = 0
        }
        
        backgroundBarView?.alpha = alpha
    }
    
    fileprivate func setupDataSource() {
        
        self.sections.append(contentsOf: [userInfoSection, userFeedSection])
        
        self.userInfoSection.add(model: self.user)
        
        self.feedItems?.onNextItems = { [unowned self] items in
            
            self.userFeedSection.add(models: items)
        }
        
        self.feedItems?.onLoadingStatusChanged = { status in
            
            switch status {
                
            case .loading:
                
                self.tableView.showBusy()
                
            default:
                
                self.tableView.hideBusy()
            }
        }
        
        self.feedItems?.onDataSourceChanged = { [unowned self] in
            
            self.tableView.reloadData()
        }
    }
}
