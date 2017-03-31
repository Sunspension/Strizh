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

    fileprivate var dataSource = TableViewDataSource()
    
    fileprivate var section = CollectionSection()
    
    fileprivate var imageDataSource: GenericCollectionViewDataSource<STAttachmentPhotoCell, ImageAsset>?
    
    fileprivate let imagesCollectionSection = GenericCollectionSection<ImageAsset>()
    
    fileprivate var imageUploader = ImageUploader()
    
    fileprivate lazy var postObject: STUserPostObject = {
        
        return try! self.dependencyContainer.resolve(STUserPostObject.self) as! STUserPostObject
        
    }()
    
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
        
        self.st_router_openContactsController()
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
                        
                        let width = Int(cell.image.bounds.size.width * UIScreen.main.scale)
                        let height = Int(cell.image.bounds.size.height * UIScreen.main.scale)
                        
                        let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                        
                        let url = URL(string: image.url + queryResize)!
                        
                        cell.image.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3),
                                               runImageTransitionIfCached: true, completion: { [unowned cell] image in
                                                
                                                cell.busyIndicator.stopAnimating()
                                                
                        })
                    }
                }
            }
            
        })
        
        self.imagesCollectionSection.sectionChanged = {
            
            self.refreshTableView()
        }
        
        self.imageDataSource?.sections.append(self.imagesCollectionSection)
    }
    
    fileprivate func createDataSource() {
        
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
