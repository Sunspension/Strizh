//
//  STFeedDetailsTableViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 10/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage
import GoogleMaps
import ReactiveKit

enum STPostDetailsReasonEnum {
    
    case usual, fromChat
}

class STFeedDetailsTableViewController: UIViewController {
    
    fileprivate enum STItemTypeEnum {
        
        case file, image, location
    }
    
    fileprivate let dataSource = TableViewDataSource()
    
    fileprivate var imageDataSource: GenericCollectionViewDataSource<STPostDetailsPhotoCell, STImage>?
    
    fileprivate let tableSection = TableSection()
    
    fileprivate let collectionSection = GenericTableSection<STImage>()
    
    fileprivate var coordinateBounds = GMSCoordinateBounds()
    
    fileprivate var myUser: STUser {
        
        return STUser.dbFind(by: STUser.self)!
    }
    
    fileprivate var isPersonal: Bool {
        
        return self.post?.userId == myUser.id
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    var reason = STPostDetailsReasonEnum.usual
    
    var postId: Int?
    
    var user: STUser?
    
    var post: STPost?
    
    var images: [STImage]?
    
    var files: [STFile]?
    
    var locations: [STLocation]?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var writeMessage: UIButton!
    
    
    deinit {

        debugPrint("deinit \(String(describing: self))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        
        if self.presentingViewController != nil {
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "action_close".localized, style: .plain, target: self, action: #selector(self.close))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.analytics.endTimeEvent(eventName: st_ePostDetails)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
        self.tableView.register(nibClass: STPostDetailsMainInfoCell.self)
        self.tableView.register(nibClass: STPostDetailsMapsCell.self)
        self.tableView.register(nibClass: STCommonCollectionViewCell.self)
        self.tableView.register(nibClass: STCommonButtonCell.self)
        self.tableView.register(nibClass: STCommonLabelCell.self)
        self.tableView.register(nibClass: STPersonalPostDetailsMainInfoCell.self)
        
        self.title = "feed_details_page_title".localized
        
        self.setCustomBackButton()
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kPostDeleteNotification), object: nil)
            .observeNext { [unowned self] notification in
                
                let post = notification.object as! STPost
                
                if self.post == post {
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
            .dispose(in: disposeBag)
        
        if reason == .fromChat {
            
            if let postId = self.postId {
                
                self.showBusy()
                
                self.api.loadPost(by: postId)
                    .onSuccess(callback: { [weak self] post in
                        
                        self?.hideBusy()
                        
                        self?.post = post
                        self?.user = post.user
                        self?.images = Array(post.images)
                        self?.files = Array(post.files)
                        self?.locations = Array(post.locations)
                        
                        self?.setupNavigationItems()
                        self?.setupWriteAction()
                        self?.setupDataSource()
                        self?.createDataSource()
                        self?.tableView.reloadData()
                    })
                    .onFailure(callback: { (error) in
                        
                        self.hideBusy()
                    })
            }
            
            return
        }
        
        self.setupNavigationItems()
        self.setupWriteAction()
        self.setupDataSource()
        self.createDataSource()
    }
    
    @objc func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openDialogsController() {
        
        guard let post = self.post else {
            
            return
        }
        
        self.analytics.logEvent(eventName: st_ePostDialogList, params: ["post_id" : post.id])
        
        self.st_router_openDialogsController(postId: post.id)
    }
    
    @objc func openChatController() {
        
        guard let post = self.post else {
            
            return
        }
        
        self.analytics.logEvent(eventName: st_eStartDialog, params: ["post_id" : post.id])
        
        self.st_router_openChatController(post: post)
    }
    
    fileprivate func setupNavigationItems() {
        
        guard let post = self.post else { return }
        
        var rightItems = [UIBarButtonItem]()
        
        if isPersonal {
            
            let more = UIButton(type: .custom)
            more.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            more.setImage(UIImage(named: "icon-more"), for: .normal)
            
            more.reactive.tap.observeNext {
                
                let postObject = STUserPostObject(post: post)
                
                if let images = self.images {
                    
                    postObject.images = Set(images)
                }
                
                if let locations = self.locations {
                    
                    postObject.locations = Set(locations)
                }
                
                if let files = self.files {
                    
                    postObject.files = Set(files)
                }
                
                self.st_action_showMoreActionSheet(postObject: postObject)
            }
            .dispose(in: self.disposeBag)
            
            rightItems.append(UIBarButtonItem(customView: more))
        }
        else {
            
            if !post.isPublic {
                
                let repost = UIButton(type: .custom)
                repost.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
                repost.setImage(UIImage(named: "icon-repost"), for: .normal)
                
                repost.reactive.tap.observeNext {
                    
                    guard let post = self.post else {
                        
                        return
                    }
                    
                    let postObject = STUserPostObject(post: post)
                    
                    if let images = self.images {
                        
                        postObject.images = Set(images)
                    }
                    
                    self.st_action_repostActionSheet(postObject: postObject)
                }
                .dispose(in: self.disposeBag)
                
                rightItems.append(UIBarButtonItem(customView: repost))
            }
        }
        
        let favorite = UIButton(type: .custom)
        favorite.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        favorite.setImage(UIImage(named: "icon-star"), for: .normal)
        favorite.setImage(UIImage(named: "icon-star-selected"), for: .selected)
        
        favorite.isSelected = post.isFavorite
        favorite.reactive.tap.observeNext {
            
            favorite.isSelected = !favorite.isSelected
            AppDelegate.appSettings.api.favorite(postId: post.id, favorite: favorite.isSelected)
                .onSuccess(callback: { postResponse in
                    
                    post.isFavorite = postResponse.isFavorite
                    
                    NotificationCenter.default.post(name: NSNotification.Name(kItemFavoriteNotification), object: postResponse)
                })
            }
            .dispose(in: self.disposeBag)
        
        rightItems.append(UIBarButtonItem(customView: favorite))
        
        self.navigationItem.rightBarButtonItems = rightItems
    }
    
    fileprivate func createDataSource() {
        
        guard let post = self.post else {
            
            return
        }
        
        self.tableSection.add(item: post,
                              cellClass: STPostDetailsMainInfoCell.self) { [unowned self] (cell, item) in
                                
                                cell.selectionStyle = .none
                                
                                let viewCell = cell as! STPostDetailsMainInfoCell
                                
                                viewCell.postTitle.text = post.title
                                viewCell.postTime.text = post.createdAt?.elapsedInterval()
                                
                                let end = post.dialogCount.ending(yabloko: "отклик", yabloka: "отлика", yablok: "откликов")
                                let title = "\(post.dialogCount)" + " " + end
                                
                                viewCell.dialogsCount.setTitle( title, for: .normal)
                                
                                if let user = self.user {
                                    
                                    viewCell.userName.text = user.lastName + " " + user.firstName
                                    
                                    if user.id == self.myUser.id && self.myUser.imageData != nil {
                                        
                                        if let image = UIImage(data: self.myUser.imageData!) {
                                            
                                            let userIcon = image.af_imageAspectScaled(toFill: viewCell.userIcon.bounds.size)
                                            viewCell.userIcon.image = userIcon.af_imageRoundedIntoCircle()
                                        }
                                    }
                                    else {
                                        
                                        guard !user.imageUrl.isEmpty else {
                                            
                                            var defaultImage = UIImage(named: "avatar")
                                            defaultImage = defaultImage?.af_imageAspectScaled(toFill: viewCell.userIcon.bounds.size)
                                            viewCell.userIcon.image = defaultImage?.af_imageRoundedIntoCircle()
                                            
                                            return
                                        }
                                        
                                        let urlString = user.imageUrl + viewCell.userIcon.queryResizeString()
                                        
                                        let filter = RoundedCornersFilter(radius: viewCell.userIcon.bounds.size.width)
                                        viewCell.userIcon.af_setImage(withURL: URL(string: urlString)!,
                                                                      filter: filter,
                                                                      completion: nil)
                                    }
                                }
        }
        
        if !post.profitDescription.isEmpty {
            
            self.tableSection.add(item: post, cellClass: STCommonLabelCell.self) { (cell, item) in
                
                cell.selectionStyle = .none
                
                let viewCell = cell as! STCommonLabelCell
                let post = item.item as! STPost
                
                viewCell.value.textColor = UIColor.stSlateGrey
                viewCell.value.text = post.profitDescription
                viewCell.topSpace.constant = 0
                viewCell.bottomSpace.constant = 0
            }
        }
        
        if post.dateFrom != nil && post.dateTo != nil {
            
            self.tableSection.add(item: post,
                                  cellClass: STCommonButtonCell.self) { (cell, item) in
                                    
                                    cell.selectionStyle = .none
                                    
                                    let viewCell = cell as! STCommonButtonCell
                                    let post = item.item as! STPost
                                    
                                    viewCell.title.setImage(UIImage(named: "icon-time"), for: .normal)
                                    
                                    let period = post.dateFrom!.mediumLocalizedFormat +
                                        " - " + post.dateTo!.mediumLocalizedFormat
                                    
                                    viewCell.title.setTitle(period, for: .normal)
                                    viewCell.title.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0)
                                    viewCell.title.setTitleColor(UIColor.black, for: .normal)
            }
        }
        
        if !post.price.isEmpty {
            
            self.tableSection.add(item: post,
                                  cellClass: STCommonButtonCell.self) { (cell, item) in
                                    
                                    cell.selectionStyle = .none
                                    
                                    let viewCell = cell as! STCommonButtonCell
                                    let post = item.item as! STPost
                                    
                                    viewCell.title.setImage(UIImage(named: "icon-rub"), for: .normal)
                                    viewCell.title.setTitle(post.price, for: .normal)
                                    viewCell.title.imageEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0)
                                    viewCell.title.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0)
                                    viewCell.title.setTitleColor(UIColor.black, for: .normal)
            }
        }
        
        if !post.priceDescription.isEmpty {
            
            self.tableSection.add(item: post, cellClass: STCommonLabelCell.self) { (cell, item) in
                
                cell.selectionStyle = .none
                
                let viewCell = cell as! STCommonLabelCell
                let post = item.item as! STPost
                
                viewCell.value.textColor = UIColor.stSlateGrey
                viewCell.value.text = post.priceDescription
                viewCell.topSpace.constant = 0
                viewCell.bottomSpace.constant = 0
            }
        }
        
        if let locations = self.locations, locations.count > 0 {
            
            self.tableSection.add(item: locations,
                                  cellClass: STPostDetailsMapsCell.self,
                                  bindingAction: { [unowned self] (cell, item) in
                                    
                                    let locations = item.item as! [STLocation]
                                    let viewCell = cell as! STPostDetailsMapsCell
                                    viewCell.isUserInteractionEnabled = false
                                    viewCell.selectionStyle = .none
                                    
                                    locations.forEach({ location in
                                        
                                        let marker = GMSMarker()
                                        marker.icon = UIImage(named: "icon-pin")
                                        marker.position = CLLocation(latitude: location.lat, longitude: location.lon).coordinate
                                        marker.map = viewCell.mapView
                                        self.coordinateBounds = self.coordinateBounds.includingCoordinate(marker.position)
                                        
                                        if locations.count == 1 {
                                            
                                            viewCell.mapView.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 15)
                                        }
                                    })
                                    
                                    if locations.count > 1 {
                                        
                                        viewCell.mapView.animate(with: GMSCameraUpdate.fit(self.coordinateBounds, withPadding: 30))
                                    }
            })
        }
        
        if let images = self.images, images.count > 0 {
            
            // collection view data source
            self.imageDataSource = GenericCollectionViewDataSource(cellClass: STPostDetailsPhotoCell.self, binding: { (cell, item) in
                
                cell.busy.startAnimating()
                
                let url = URL(string: item.item.url + cell.image.queryResizeString())!
                
                cell.image.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3),
                                       runImageTransitionIfCached: true, completion: { [weak cell] image in
                                        
                                        cell?.busy.stopAnimating()
                })
            })
            
            self.imageDataSource?.sections.append(self.collectionSection)
            
            images.forEach({ image in
                
                self.collectionSection.add(item: image)
            })
            
            tableSection.add(item: self.imageDataSource,
                             cellClass: STCommonCollectionViewCell.self,
                             bindingAction: { (cell, item) in
                                
                                let viewCell = cell as! STCommonCollectionViewCell
                                viewCell.selectionStyle = .none
                                let dataSource = item.item as! GenericCollectionViewDataSource<STPostDetailsPhotoCell, STImage>
                                
                                viewCell.collectionView.register(nib: STPostDetailsPhotoCell.self)
                                viewCell.collectionView.dataSource = dataSource
                                viewCell.collectionView.delegate = dataSource
                                viewCell.collectionView.reloadData()
            })
            
            self.imageDataSource?.onDidSelectRowAtIndexPath = { [unowned self] (collectionView, indexPath, item) in
                
                let photoIndex = indexPath.row
                self.st_router_openPhotoViewer(images: self.images!, index: photoIndex)
            }
        }
        
        if let files = self.files {
            
            files.forEach({ file in
                
                tableSection.add(item: file,
                                 itemType: STItemTypeEnum.file,
                                 cellClass: STCommonButtonCell.self,
                                 bindingAction: { (cell, item) in
                                    
                                    let viewCell = cell as! STCommonButtonCell
                                    let file = item.item as! STFile
                                    
                                    viewCell.title.setTitle(file.title, for: .normal)
                                    viewCell.title.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
                                    viewCell.title.isUserInteractionEnabled = false
                })
            })
        }
        
        if post.postDescription.isEmpty {
            
            return
        }
        
        self.tableSection.add(item: post, cellClass: STCommonLabelCell.self) { (cell, item) in
            
            cell.selectionStyle = .none
            
            let viewCell = cell as! STCommonLabelCell
            let post = item.item as! STPost
            
            viewCell.value.text = post.postDescription
        }
    }
    
    fileprivate func setupDataSource() {
        
        // setup data source
        self.dataSource.onDidSelectRowAtIndexPath = { (tableView: UITableView, indexPath: IndexPath, item: TableSectionItem) in
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            guard let itemType = item.itemType as? STItemTypeEnum else {
                
                return
            }
            
            switch itemType {
                
            case .file:
                
                let file = item.item as! STFile
                let url = URL(string: file.url)!
                self.st_router_openDocumentController(url: url, title: file.title)
                
                break
                
            default:
                break
            }
        }
        
        self.dataSource.sections.append(self.tableSection)
    }
    
    fileprivate func setupWriteAction() {
        
        if let post = self.post {
            
            let myUser = STUser.objects(by: STUser.self).first!
            
            if reason == .fromChat {
                
                self.writeMessage.setTitle("feed_details_page_button_write_back_to_dialog_title".localized, for: .normal)
                self.writeMessage.addTarget(self, action: #selector(self.close), for: .touchUpInside)
                
                return
            }
            
            if post.dialogCount == 0 {
                
                if post.userId == myUser.id {
                    
                    self.writeMessage.setTitle("feed_details_page_button_have_no_dialogs_title".localized, for: .normal)
                    writeMessage.isEnabled = false
                    writeMessage.alpha = 0.7
                }
                else {
                    
                    self.writeMessage.setTitle("feed_details_page_button_write_message_title".localized, for: .normal)
                    self.writeMessage.addTarget(self, action: #selector(self.openChatController), for: .touchUpInside)
                }
            }
            else {
                
                if post.userId == myUser.id && post.dialogCount > 1 {
                    
                    self.writeMessage.setTitle("feed_details_page_button_write_go_to_dialogs_title".localized + "(\(post.dialogCount))", for: .normal)
                    self.writeMessage.addTarget(self, action: #selector(self.openDialogsController), for: .touchUpInside)
                }
                else {
                    
                    self.writeMessage.setTitle("feed_details_page_button_write_go_to_dialog_title".localized, for: .normal)
                    self.writeMessage.addTarget(self, action: #selector(self.openChatController), for: .touchUpInside)
                }
            }
        }
    }
}
