//
//  STPostAttachmentsController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 10/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import DKImagePickerController

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


class STPostAttachmentsController: UITableViewController {

    private var dataSource = TableViewDataSource()
    
    private var section = CollectionSection()
    
    private var imageDataSource: GenericCollectionViewDataSource<STAttachmentPhotoCell, ImageAsset>?
    
    private let imagesCollectionSection = GenericCollectionSection<ImageAsset>()
    
    private var imageUploader = ImageUploader()
    
    var postObject: STUserPostObject?
    
    
    deinit {
        
        print("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        let rightItem = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(self.nextAction))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.setCustomBackButton()
        
        title = "Прикрепить к теме"
        
        self.imageUploader.completeAllOperations = { [unowned self] in
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        self.setupDataSource()
        self.createDataSource()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//        super.viewWillAppear(animated)
//        
//        if let navi = self.navigationController as? STNewPostNavigationController {
//            
//            self.postObject = navi.postObject
//            
//            // if we have images
//            if let postObject = self.postObject, let imageIds = postObject.imageIds {
//                
//                if imageIds.count > 0 {
//                    
//                    self.imagesCollectionSection.items.removeAll()
//                    
//                    for imageId in imageIds {
//                        
//                        self.imagesCollectionSection.add(item: ImageAsset(imageId: imageId))
//                    }
//                    
//                    self.imagesCollectionSection.sectionChanged?()
//                }
//            }
//        }
//    }
    
    func nextAction() {
        
        var imageIds = [Int64]()
        
        for operation in self.imageUploader.operations {
            
            if let file = operation.file {
                
                imageIds.append(file.id)
            }
        }
        
        if imageIds.count > 0 {
            
            self.postObject!.imageIds = imageIds
            
//            if let navi = self.navigationController as? STNewPostNavigationController {
//                
//                navi.postObject = self.postObject!
//            }
        }
        
        self.st_router_openContactsController()
    }
    
    private func setupDataSource() {
        
        self.dataSource.sections.append(self.section)
        
        self.tableView.register(headerFooterNibClass: STContactHeaderCell.self)
        self.tableView.register(nibClass: STAttachmentCell.self)
        self.tableView.register(nibClass: STCommonCollectionViewCell.self)
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
        // collection view data source
        self.imageDataSource = GenericCollectionViewDataSource(cellClass: STAttachmentPhotoCell.self, binding: { [unowned self] (cell, item) in
            
            if item.item.imageAsset != nil {
                
                let size = CGSize(width: cell.image.frame.size.width * UIScreen.main.scale,
                                  height: cell.image.frame.size.height * UIScreen.main.scale)
                
                item.item.imageAsset!.fetchImageWithSize(size) { (image, info) in
                    
                    cell.image.image = image
                    cell.onDeleteAction = { [unowned self] in
                        
                        self.imagesCollectionSection.items = self.imagesCollectionSection.items.filter({ $0.item.imageAsset! != item.item.imageAsset! })
                        self.imagesCollectionSection.sectionChanged?()
                        self.imageUploader.operations.remove(at: item.indexPath.row)
                        
                        if self.imagesCollectionSection.items.count == 0 {
                            
                            self.refreshTableView()
                        }
                    }
                    
                    // setup for operation
                    guard self.imageUploader.operations.count > item.indexPath.row else {
                        
                        return
                    }
                    
                    let operation = self.imageUploader.operations[item.indexPath.row]
                    
                    operation.uploadProgressChanged = { progress in
                        
                        cell.setProgress(progress: progress)
                    }
                    
                    operation.completionBlock = { [unowned operation] in
                        
                        DispatchQueue.main.async {
                            
                            if operation.error != nil {
                                
                                cell.error()
                            }
                            else {
                                
                                cell.uploaded()
                            }
                        }
                    }
                    
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
                        }
                        
                        break
                        
                    default:
                        break
                    }
                }
            }
            else {
                
                let imageId = item.item.imageId!
                
                if let postObject = self.postObject {
                    
                    if let images = postObject.images {
                        
                        if let image = images.filter({ $0.id == imageId }).first {
                            
                            cell.busyIndicator.startAnimating()
                            
                            let width = Int(cell.image.bounds.size.width * UIScreen.main.scale)
                            let height = Int(cell.image.bounds.size.height * UIScreen.main.scale)
                            
                            let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                            
                            let url = URL(string: image.url + queryResize)!
                            
                            cell.image.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3),
                                                   runImageTransitionIfCached: true, completion: { [unowned cell] image in
                                                    
                                                    cell.busyIndicator.stopAnimating()
                                                    cell.uploaded()
                                                    
                            })
                        }
                    }
                }
            }
            
        })
        
        self.imagesCollectionSection.sectionChanged = {
            
            self.refreshTableView()
        }
        
        self.imageDataSource?.sections.append(self.imagesCollectionSection)
    }
    
    private func createDataSource() {
        
        self.section.header(headerClass: STContactHeaderCell.self) { (view, section) in
            
            let header = view as! STContactHeaderCell
            
            header.title.text = "ПРИКРЕПИТЬ К ТЕМЕ:"
            header.title.font = UIFont.systemFont(ofSize: 12)
            header.title.textColor = UIColor.stSteelGrey
            header.topSpace.constant = 16
        }
        
        self.section.headerItem?.cellHeight = 46
        
        self.section.addItem(cellClass: STAttachmentCell.self, itemType: STAttachmentItemsEnum.photo) { [unowned self] (cell, item) in
            
            let viewCell = cell as! STAttachmentCell
            viewCell.icon.image = UIImage(named: "icon-attachment-image")
            viewCell.title.text = "Фотографии"
            viewCell.subtitle.text = "До 10 фотографий"
            viewCell.collectionView.dataSource = self.imageDataSource
            viewCell.collectionView.delegate = self.imageDataSource
            
            viewCell.actionButton.reactive.tap.observeNext {
                
                print("operations count: \(self.imageUploader.operations.count)")
                
                if item.itemType as? STAttachmentItemsEnum == .photo &&
                    self.imagesCollectionSection.items.count < 10 {
                    
                    let photoController = DKImagePickerController()
                    photoController.maxSelectableCount = 10 - self.imagesCollectionSection.items.count
                    photoController.sourceType = .photo
                    photoController.assetType = .allPhotos
                    photoController.didSelectAssets = { [unowned viewCell, unowned self] assets in
                        
                        if assets.count == 0 {
                            
                            return
                        }
                        
                        assets.forEach({ asset in
                            
                            self.imagesCollectionSection.add(item: ImageAsset(imageAsset: asset))
                        })
                        
                        self.imagesCollectionSection.sectionChanged?()
                        viewCell.expandCellIfNeeded()
                        self.refreshTableView()
                        
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        
                        DispatchQueue.global().async {
                            
                            var images = [Data]()
                            
                            assets.forEach({ asset in
                                
                                asset.fetchImageDataForAsset(true, completeBlock: { (data, info) in
                                    
                                    if let image = data {
                                        
                                        images.append(image)
                                    }
                                })
                            })
                            
                            self.imageUploader.uploadImages(images: images)
                            
                            DispatchQueue.main.async {
                                
                                self.tableView.reloadRows(at: [item.indexPath], with: .automatic)
                            }
                        }
                    }
                    
                    self.present(photoController, animated: true, completion: nil)
                }
                
            }.dispose(in: viewCell.bag)
            
            self.imagesCollectionSection.sectionChanged = { [unowned viewCell] in
                
                viewCell.collectionView.reloadData()
                viewCell.expandCellIfNeeded()
            }
            
            viewCell.collectionView.reloadData()
            viewCell.expandCellIfNeeded()
        }
        
        // if we have images
        if let postObject = self.postObject, let imageIds = postObject.imageIds {
            
            if imageIds.count > 0 {
                
                self.imagesCollectionSection.items.removeAll()
                
                for imageId in imageIds {
                    
                    self.imagesCollectionSection.add(item: ImageAsset(imageId: imageId))
                }
                
//                self.imagesCollectionSection.sectionChanged?()
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
