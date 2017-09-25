//
//  STPostAttachmentsController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 10/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import DKImagePickerController
import Dip
import NVActivityIndicatorView

private enum STAttachmentItemsEnum {
    
    case photo, location
}

struct ImageAsset {
    
    var imageId: Int64?
    
    var imageAsset: DKAsset?
    
    
    init(imageId: Int64) {
        
        self.imageId = imageId
    }
    
    init(imageAsset: DKAsset) {
        
        self.imageAsset = imageAsset
    }
}


class STPostAttachmentsController: UITableViewController, NVActivityIndicatorViewable {

    fileprivate var dataSource = TableViewDataSource()
    
    fileprivate var section = TableSection()
    
    fileprivate var imageDataSource: GenericCollectionViewDataSource<STAttachmentPhotoCell, ImageAsset>?
    
    fileprivate let imagesCollectionSection = GenericTableSection<ImageAsset>()
    
    fileprivate var imageUploader = ImageUploader()
    
    fileprivate lazy var postObject: STUserPostObject = {
        
        return try! self.dependencyContainer.resolve(STUserPostObject.self) as! STUserPostObject
        
    }()
    
    deinit {
        
        print("")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.analytics.endTimeEvent(eventName: st_eNewPostStep2)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)

        // checking press back button
        if self.navigationController?.viewControllers.index(of: self) == nil {
            
            self.analytics.endTimeEvent(eventName: st_eBackNewPostStep1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        let rightButtonTitle = self.postObject.isPublic && self.postObject.objectType == .edit ? "contacts_page_create_text".localized : "action_next".localized
        
        let rightItem = UIBarButtonItem(title: rightButtonTitle, style: .plain, target: self, action: #selector(self.nextAction))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.setCustomBackButton()
        
        title = "post_page_attach_to_topic_text".localized
        
        self.imageUploader.completeAllOperations = { [unowned self] in
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.imagesCollectionSection.sectionChanged?()
        }
        
        self.setupDataSource()
        self.createDataSource()
    }
    
    func nextAction() {
        
        var imageIds = [Int64]()
        
        for operation in self.imageUploader.operations.map({ $0.value }) {
            
            if let file = operation.file {
                
                imageIds.append(file.id)
            }
        }
        
        if imageIds.count > 0 {
            
            if self.postObject.imageIds == nil {
                
                self.postObject.imageIds = imageIds
            }
            else {
                
                self.postObject.imageIds!.append(contentsOf: imageIds)
            }
        }
        
        if self.postObject.isPublic && self.postObject.objectType == .edit {
            
            api.updatePost(post: self.postObject)
                
                .onSuccess(callback: { [unowned self] post in
                    
                    self.stopAnimating()
                    
                    // still having the same behavior
                    NotificationCenter.default.post(name: NSNotification.Name(kPostCreatedNotification), object: post)
                    
                    self.showOkAlert(title: "contacts_page_success_title".localized,
                                     message:"contacts_page_success_update_message".localized, okAction: {
                                        
                                        action in self.navigationController?.dismiss(animated: true, completion: nil)
                    })
                })
                .onFailure(callback: { [unowned self] error in
                    
                    self.stopAnimating()
                    self.showError(error: error)
                })
        }
        else {
            
            self.st_router_openContactsController()
        }
    }
    
    fileprivate func setupDataSource() {
        
        self.dataSource.sections.append(self.section)
        
        self.tableView.register(headerFooterNibClass: STContactHeaderCell.self)
        self.tableView.register(nibClass: STAttachmentCell.self)
        self.tableView.register(nibClass: STCommonCollectionViewCell.self)
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
        // collection view data source
        self.imageDataSource = GenericCollectionViewDataSource(cellClass: STAttachmentPhotoCell.self, binding: { [unowned self] (cell, item) in
            
            // delete action
            cell.onDeleteAction = { [unowned self] in
                
                self.imagesCollectionSection.items.remove(object: item)
                self.imagesCollectionSection.sectionChanged?()
            
                if item.item.imageAsset != nil {
                    
                    self.imageUploader.operations.removeValue(forKey: item.item.imageAsset!.localIdentifier)
                }
                else {
                    
                    self.postObject.imageIds?.remove(object: item.item.imageId!)
                }
                
                if self.imagesCollectionSection.items.count == 0 {
                    
                    self.refreshTableView()
                }
            }
            
            if item.item.imageAsset != nil {
                
                let size = CGSize(width: cell.image.frame.size.width * UIScreen.main.scale,
                                  height: cell.image.frame.size.height * UIScreen.main.scale)
                
                item.item.imageAsset!.fetchImageWithSize(size) { (image, info) in
                    
                    cell.image.image = image
                    
                    let upOperation = self.imageUploader.operations[item.item.imageAsset!.localIdentifier]
                    
                    guard let operation = upOperation else { return }
                    
                    switch operation.state {
                        
                    case .finished:
                        
                        if operation.error != nil {
                            
                            DispatchQueue.main.async {
                                
                                cell.error()
                            }
                        }
                        else {
                            
                            DispatchQueue.main.async {
                                
                                cell.uploaded()
                            }
                        }
                        
                        break
                        
                    case .executing:
                        
                        DispatchQueue.main.async {
                            
                            cell.uploading()
                            cell.setProgress(progress: operation.uploadProgress)
                            
                            operation.uploadProgressChanged = { progress in
                                
                                cell.setProgress(progress: progress)
                            }
                            
                            operation.completionBlock = { [unowned operation] in
                                
                                DispatchQueue.main.async {
                                    
                                    if operation.error != nil {
                                        
                                        cell.error()
                                    }
                                    else {
                                        
                                        print("finished operation index: \(item.indexPath.row)")
                                        
                                        cell.uploaded()
                                    }
                                }
                            }
                        }
                        
                        break
                        
                    default:
                        break
                    }
                }
            }
            else {
                
                let imageId = item.item.imageId!
                
                if let images = self.postObject.images {
                    
                    if let image = images.filter({ $0.id == imageId }).first {
                        
                        cell.busyIndicator.startAnimating()
                        cell.uploaded()
                        
                        let url = URL(string: image.url + cell.image.queryResizeString())!
                        
                        cell.image.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3),
                                               runImageTransitionIfCached: true, completion: { [unowned cell] image in
                                                
                                                cell.busyIndicator.stopAnimating()
                                                
                        })
                    }
                }
            }
            
        })
        
        self.imageDataSource?.sections.append(self.imagesCollectionSection)
    }
    
    fileprivate func createDataSource() {
        
        self.section.header(headerClass: STContactHeaderCell.self) { (view, section) in
            
            let header = view as! STContactHeaderCell
            
            header.title.text = "post_page_attach_to_topic_title".localized
            header.title.font = UIFont.systemFont(ofSize: 12)
            header.title.textColor = UIColor.stSteelGrey
            header.topSpace.constant = 16
        }
        
        self.section.headerItem?.cellHeight = 46
        
        self.section.add(itemType: STAttachmentItemsEnum.photo, cellClass: STAttachmentCell.self) { [unowned self] (cell, item) in
            
            let viewCell = cell as! STAttachmentCell
            viewCell.icon.image = UIImage(named: "icon-attachment-image")
            viewCell.title.text = "post_page_photos_text".localized
            viewCell.subtitle.text = "post_page_photos_description_text".localized
            viewCell.collectionView.dataSource = self.imageDataSource
            viewCell.collectionView.delegate = self.imageDataSource
            viewCell.actionButton.setTitle("action_add".localized, for: .normal)
            
            viewCell.actionButton.reactive.tap.observeNext {
                
                // analytics
                self.analytics.endTimeEvent(eventName: st_eAddPostImage)
                
                if item.itemType as? STAttachmentItemsEnum == .photo &&
                    self.imagesCollectionSection.items.count < 10 {
                    
                    let photoController = DKImagePickerController()
                    photoController.maxSelectableCount = 10 - self.imagesCollectionSection.items.count
                    photoController.sourceType = .photo
                    photoController.assetType = .allPhotos
                    
                    photoController.didCancel = {
                        
                        // analytics
                        self.analytics.endTimeEvent(eventName: st_eFinishAddPostImage)
                    }
                    
                    photoController.didSelectAssets = { [unowned self] assets in
                        
                        if assets.count == 0 {
                            
                            return
                        }
                        
                        assets.forEach({ asset in
                            
                            self.imagesCollectionSection.add(item: ImageAsset(imageAsset: asset))
                        })
                        
                        self.imagesCollectionSection.sectionChanged?()
                        
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        
                        // add operations
                        DispatchQueue.global().async {
                            
                            var images = [(Data, String)]()
                            
                            assets.forEach({ asset in
                                
                                asset.fetchImageDataForAsset(true, completeBlock: { (data, info) in
                                    
                                    if let image = data {
                                        
                                        images.append((image, asset.localIdentifier))
                                    }
                                })
                            })
                            
                            self.imageUploader.uploadImages(images)
                            
                            DispatchQueue.main.async {
                                
                                let cell = self.tableView.cellForRow(at: item.indexPath) as! STAttachmentCell
                                cell.collectionView.reloadData()
                            }
                        }
                    }
                    
                    self.present(photoController, animated: true, completion: nil)
                }
                
            }.dispose(in: viewCell.disposeBag)
            
            
            // collection section changed handler
            self.imagesCollectionSection.sectionChanged = { [unowned viewCell, unowned self] in
                
                if self.imagesCollectionSection.items.count > 0 {
                    
                    viewCell.expandCell()
//                    viewCell.collectionView.reloadData()
                }
                else {
                    
                    viewCell.collapsCell()
                }

                viewCell.collectionView.reloadData()
                self.refreshTableView()
            }
            
            // reload collection view
            if self.imagesCollectionSection.items.count > 0 {
                
                viewCell.expandCell()
                viewCell.collectionView.reloadData()
            }
            else {
                
                viewCell.collapsCell()
            }
            
            self.refreshTableView()
        }
        
        // if we have images
        if let imageIds = postObject.imageIds, imageIds.count > 0 {
            
            for imageId in imageIds {
                
                self.imagesCollectionSection.add(item: ImageAsset(imageId: imageId))
            }
        }
        
//        self.section.addItem(cellClass: STAttachmentCell.self, itemType: STAttachmentItemsEnum.location) { (cell, item) in
//            
//            let viewCell = cell as! STAttachmentCell
//            viewCell.icon.image = UIImage(named: "icon-attachment-location")
//            viewCell.title.text = "Адрес"
//            viewCell.subtitle.text = "Неограниченное кол-во"
//        }
    }
    
    func refreshTableView() {
        
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
        })
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
}
