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


class STFeedDetailsTableViewController: UIViewController {

    fileprivate enum STItemTypeEnum {
        
        case file, image, location
    }
    
    enum STPostDetailsReasonEnum {
        
        case feedDetails, personalPostDetails, fromChat
    }
    
    
    fileprivate let dataSource = TableViewDataSource()
    
    fileprivate var imageDataSource: GenericCollectionViewDataSource<STPostDetailsPhotoCell, STImage>?
    
    fileprivate let tableSection = TableSection()
    
    fileprivate let collectionSection = GenericTableSection<STImage>()
    
    fileprivate var coordinateBounds = GMSCoordinateBounds()
    
    var reason = STPostDetailsReasonEnum.feedDetails
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var writeMessage: UIButton!
    
    
    var postId: Int?
    
    var user: STUser?
    
    var post: STPost?
    
    var images: [STImage]?
    
    var files: [STFile]?
    
    var locations: [STLocation]?
    
    
    deinit {
        
        print("deinit \(String(describing: self))")
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
        
        self.navigationItem.title = "feed_details_page_title".localized
        
        self.setCustomBackButton()
        self.setupDataSource()
        
        if self.reason == .personalPostDetails {
            
            let moreButton = UIBarButtonItem(image: UIImage(named: "icon-more"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(self.contextActions))
            
            moreButton.tintColor = UIColor.stGreyblue
            self.navigationItem.rightBarButtonItem = moreButton
        }
        
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
                        
                        self?.setupWriteAction()
                        self?.createDataSource()
                        self?.tableView.tableFooterView = UIView()
                        
                        self?.tableView.reloadData()
                    })
                    .onFailure(callback: { (error) in
                    
                        self.hideBusy()
                    })
            }
            
            return
        }
        
        self.setupWriteAction()
        self.createDataSource()
        self.tableView.tableFooterView = UIView()
    }

    func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func openDialogsController() {
        
        guard let post = self.post else {
            
            return
        }
        
        self.analytics.logEvent(eventName: st_ePostDialogList, params: ["post_id" : post.id])
        
        self.st_router_openDialogsController(postId: post.id)
    }
    
    func openChatController() {
        
        guard let post = self.post else {
            
            return
        }
        
        self.analytics.logEvent(eventName: st_eStartDialog, params: ["post_id" : post.id])
        
        self.st_router_openChatController(post: post)
    }
    
    fileprivate func createDataSource() {
        
        guard let post = self.post else {
            
            return
        }
        
        if self.reason == .feedDetails {
            
            self.tableSection.addItem(cellClass: STPostDetailsMainInfoCell.self,
                                      item: self.post) { [unowned self] (cell, item) in
                                        
                                        cell.selectionStyle = .none
                                        
                                        let viewCell = cell as! STPostDetailsMainInfoCell
                                        
                                        viewCell.postTitle.text = post.title
                                        viewCell.favorite.isSelected = post.isFavorite
                                        viewCell.postType.isSelected = post.type == 2 ? true : false
                                        viewCell.postTime.text = post.createdAt?.elapsedInterval()
                                        
                                        viewCell.favorite.reactive.tap.observe {_ in
                                            
                                            let favorite = !viewCell.favorite.isSelected
                                            viewCell.favorite.isSelected = favorite
                                            
                                            AppDelegate.appSettings.api.favorite(postId: post.id, favorite: favorite)
                                                .onSuccess(callback: { postResponse in
                                                    
                                                    post.isFavorite = postResponse.isFavorite
                                                    
                                                    NotificationCenter.default.post(name: NSNotification.Name(kItemFavoriteNotification), object: postResponse)
                                                })
                                            
                                            }.dispose(in: viewCell.bag)
                                        
                                        if let user = self.user {
                                            
                                            viewCell.userName.text = user.lastName + " " + user.firstName
                                            
                                            guard !user.imageUrl.isEmpty else {
                                                
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
        else {
            
            self.tableSection.addItem(cellClass: STPersonalPostDetailsMainInfoCell.self,
                                      item: self.post) { (cell, item) in
                                        
                                        cell.selectionStyle = .none
                                        
                                        let viewCell = cell as! STPersonalPostDetailsMainInfoCell
                                        
                                        viewCell.postTitle.text = post.title
                                        viewCell.postType.isSelected = post.type == 2 ? true : false
                                        viewCell.createdAt.text = post.createdAt?.mediumLocalizedFormat
                                        
                                        if post.dialogCount == 0 {
                                            
                                            viewCell.dialogsCount.isHidden = true
                                            viewCell.openedDialogs.isHidden = true
                                        }
                                        else {
                                            
                                            viewCell.dialogsCount.isHidden = false
                                            viewCell.openedDialogs.isHidden = false
                                            viewCell.openedDialogs.text = post.dialogCount == 1
                                                ? "profile_page_open_one_dialog_text".localized
                                                : "profile_page_open_few_dialogs_text".localized
                                            
                                            let ending = post.dialogCount.ending(yabloko: "profile_page_one_dialog_text".localized,
                                                                                 yabloka: "profile_page_few_dialogs_text".localized,
                                                                                 yablok: "profile_page_many_dialogs_text".localized)
                                            
                                            viewCell.dialogsCount.text = "\(post.dialogCount)" + " " + ending
                                        }
            }
        }
        
        if !post.profitDescription.isEmpty {
            
            self.tableSection.addItem(cellClass: STCommonLabelCell.self, item: post) { (cell, item) in
                
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
            
            self.tableSection.addItem(cellClass: STCommonButtonCell.self,
                                      item: post) { (cell, item) in
                                        
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
            
            self.tableSection.addItem(cellClass: STCommonButtonCell.self,
                                      item: post) { (cell, item) in
                                        
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
            
            self.tableSection.addItem(cellClass: STCommonLabelCell.self, item: post) { (cell, item) in
                
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
            
            self.tableSection.addItem(cellClass: STPostDetailsMapsCell.self,
                                 item: locations,
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
            
            tableSection.addItem(cellClass: STCommonCollectionViewCell.self,
                            item: self.imageDataSource,
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
                
                tableSection.addItem(cellClass: STCommonButtonCell.self,
                                     item: file,
                                     itemType: STItemTypeEnum.file,
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
        
        self.tableSection.addItem(cellClass: STCommonLabelCell.self, item: post) { (cell, item) in
            
            cell.selectionStyle = .none
            
            let viewCell = cell as! STCommonLabelCell
            let post = item.item as! STPost
            
            viewCell.value.text = post.postDescription
        }
    }
    
    func contextActions() {
        
        guard let post = self.post, post.deleted == false else {
            
            return
        }
        
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "action_cancel".localized, style: .cancel, handler: nil)
        
        let actionEdit = UIAlertAction(title: "action_edit".localized, style: .default, handler: { action in
            
            // open edit controller
            let postObject = STUserPostObject(post: post)
            
            if let images = self.images {
                
                postObject.images = Set(images)
            }
            
            self.st_router_openPostController(postObject: postObject)
        })
        
        actionController.addAction(actionEdit)
        
//        if !post.isArchived {
//
//            let actionArchive = UIAlertAction(title: "В архив", style: .default,
//                                              handler: { [unowned self] action in
//                                                
//                                                self.api.archivePost(postId: post.id, isArchived: true)
//                                                    .onSuccess(callback: { _ in
//                                                        
//                                                        post.isArchived = true
//                                                        NotificationCenter.default.post(name: NSNotification.Name(kPostAddedToArchiveNotification), object: post)
//                                                    })
//                                                    .onFailure(callback: { error in
//                                                        
//                                                        self.showError(error: error)
//                                                    })
//            })
//            
//            actionController.addAction(actionArchive)
//        }
        
        let actionDelete = UIAlertAction(title: "action_delete".localized, style: .default, handler: { action in
            
            self.api.deletePost(postId: post.id)
                .onSuccess(callback: { _ in
                    
                    NotificationCenter.default.post(name: NSNotification.Name(kPostDeleteFromDetailsNotification), object: post)
                })
                .onFailure(callback: { error in
                    
                    self.showError(error: error)
                })
        })
        
        actionController.addAction(cancel)
        actionController.addAction(actionDelete)
        
        self.present(actionController, animated: true, completion: nil)
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
