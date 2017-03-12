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


class STPostAttachmentsController: UITableViewController {

    private var dataSource = TableViewDataSource()
    
    private var photoSection = CollectionSection()
    
    private var selectedPhotosSection = CollectionSection()
    
    private var locationSection = CollectionSection()
    
    private var selectedLocationsSection = CollectionSection()
    
    private var imageDataSource: GenericCollectionViewDataSource<STAttachmentPhotoCell, DKAsset>?
    
    private let imagesCollectionSection = GenericCollectionSection<DKAsset>()
    
    private let imageUploader = ImageUploader()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        let rightItem = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(self.nextAction))
        self.navigationItem.rightBarButtonItem = rightItem
        
        title = "Прикрепить к теме"
        
        self.setupDataSource()
        self.createDataSource()
    }
    
    func nextAction() {
    
        
    }
    
    private func setupDataSource() {
        
        self.dataSource.sections.append(self.photoSection)
        self.dataSource.sections.append(self.selectedPhotosSection)
        self.dataSource.sections.append(self.locationSection)
        self.dataSource.sections.append(self.selectedLocationsSection)
        
        self.tableView.register(headerFooterNibClass: STContactHeaderCell.self)
        self.tableView.register(nibClass: STAttachmentCell.self)
        self.tableView.register(nibClass: STCommonCollectionViewCell.self)
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
        // collection view data source
        self.imageDataSource = GenericCollectionViewDataSource(cellClass: STAttachmentPhotoCell.self, binding: { (cell, item) in
            
            let size = CGSize(width: cell.image.frame.size.width * UIScreen.main.scale,
                              height: cell.image.frame.size.height * UIScreen.main.scale)
            
            item.item.fetchImageWithSize(size) { (image, info) in
                
                cell.image.image = image
                cell.waiting()
                
                cell.delete.reactive.tap.observeNext { [unowned self] in
                 
                    self.imagesCollectionSection.items = self.imagesCollectionSection.items.filter({ $0.item != item.item })
                    self.imagesCollectionSection.sectionChanged?()
                    
                    if self.imagesCollectionSection.items.count == 0 {
                        
                        self.tableView.reloadData()
                    }
                    
                }.dispose(in: cell.bag)
                
                // setup for operation
                guard self.imageUploader.operations.count > item.indexPath.row else {
                    
                    return
                }
                
                let operation = self.imageUploader.operations[item.indexPath.row] as! ImageUploadOperation
                
                operation.uploadProgressChanged = { progress in
                    
                    cell.setProgress(progress: progress)
                }
                
                operation.didChangeState = { [unowned operation, unowned self] state in
                
                    DispatchQueue.main.async {
                    
                        switch state {
                            
                        case .finished:
                            
                            self.imageUploader.startWaitingTasks()
                            
                            if operation.error != nil {
                                
                                cell.error()
                            }
                            else {
                                
                                cell.uploaded()
                            }
                            
                            break
                            
                        case .executing:
                            
                            cell.uploading()
                            cell.setProgress(progress: operation.uploadProgress)
                            
                            break
                            
                        default:
                            break
                        }
                    }
                }
                
                switch operation.state {
                    
                case .finished:
                    
                    if operation.error != nil {
                        
                        cell.error()
                    }
                    else {
                        
                        cell.uploaded()
                    }
                    
                    break
                    
                case .executing:
                    
                    cell.uploading()
                    cell.setProgress(progress: operation.uploadProgress)
                    
                    break
                    
                default:
                    
                    cell.waiting()
                    
                    break
                }
            }
        })
        
        self.imageDataSource?.sections.append(self.imagesCollectionSection)
    }
    
    private func createDataSource() {
    
        self.dataSource.onDidSelectRowAtIndexPath = { (tableView, indexPath, item) in
            
            if item.itemType as? STAttachmentItemsEnum == .photo {
                
                let photoController = DKImagePickerController()
                photoController.maxSelectableCount = 10
                photoController.sourceType = .photo
                photoController.assetType = .allPhotos
                photoController.didSelectAssets = { [unowned self] assets in
                    
                    self.imagesCollectionSection.items.removeAll()
                    
                    assets.forEach({ asset in
                        
                        self.imagesCollectionSection.add(item: asset)
                    })
                    
                    DispatchQueue.global().async {
                        
                        assets.forEach({ asset in
                            
                            asset.fetchImageDataForAsset(true, completeBlock: { (data, info) in
                                
                                if let image = data {
                                    
                                    self.imageUploader.uploadImage(image: image)
                                }
                            })
                        })
                        
                        DispatchQueue.main.async {
                            
                            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                        }
                    }
                    
                    self.selectedPhotosSection.items.removeAll()
                    self.selectedPhotosSection.addItem(cellClass: STCommonCollectionViewCell.self,
                                                       item: self.imageDataSource,
                                                       bindingAction: { [unowned self] (cell, item) in
                                                        
                                                        let dataSource = item.item as! GenericCollectionViewDataSource<STAttachmentPhotoCell, DKAsset>
                                                        
                                                        let viewCell = cell as! STCommonCollectionViewCell
                                                        
                                                        self.imagesCollectionSection.sectionChanged = {
                                                            
                                                            viewCell.collectionView.reloadData()
                                                        }
                                                        
                                                        viewCell.leftMargin.constant = 16
                                                        viewCell.rightMargin.constant = 16
                                                        viewCell.itemSize = CGSize(width: 88, height: 68)
                                                        viewCell.collectionViewHeight.constant = 68
                                                        viewCell.collectionView.register(nib: STAttachmentPhotoCell.self)
                                                        viewCell.collectionView.dataSource = dataSource
                                                        viewCell.collectionView.delegate = dataSource
                                                        viewCell.collectionView.reloadData()
                    })
                    
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
                
                self.present(photoController, animated: true, completion: nil)
            }
        }
        
        self.photoSection.header(headerClass: STContactHeaderCell.self) { (view, section) in
            
            let header = view as! STContactHeaderCell
            
            header.title.text = "ПРИКРЕПИТЬ К ТЕМЕ:"
            header.title.font = UIFont.systemFont(ofSize: 12)
            header.title.textColor = UIColor.stSteelGrey
            header.topSpace.constant = 16
        }
        
        self.photoSection.headerItem?.cellHeight = 46
        
        self.photoSection.addItem(cellClass: STAttachmentCell.self, itemType: STAttachmentItemsEnum.photo) { (cell, item) in
            
            let viewCell = cell as! STAttachmentCell
            viewCell.icon.image = UIImage(named: "icon-attachment-image")
            viewCell.title.text = "Фотографии"
            viewCell.subtitle.text = "Выбрать фотографии"
        }
        
        self.locationSection.addItem(cellClass: STAttachmentCell.self, itemType: STAttachmentItemsEnum.location) { (cell, item) in
            
            let viewCell = cell as! STAttachmentCell
            viewCell.icon.image = UIImage(named: "icon-attachment-location")
            viewCell.title.text = "Адрес"
            viewCell.subtitle.text = "Добавить адрес"
        }
    }
}
