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
    
    private var section = CollectionSection()
    
    private var imageDataSource: GenericCollectionViewDataSource<STPostDetailsPhotoCell, STImage>?
    
    private let imagesCollectionSection = GenericCollectionSection<STImage>()
    
    
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
        
        self.dataSource.sections.append(self.section)
        
        self.tableView.register(headerFooterNibClass: STContactHeaderCell.self)
        self.tableView.register(nibClass: STAttachmentCell.self)
        self.tableView.register(nibClass: STPostDetailsCollectionViewCell.self)
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
        // collection view data source
        self.imageDataSource = GenericCollectionViewDataSource(cellClass: STPostDetailsPhotoCell.self, binding: { (cell, item) in
            
            cell.busy.startAnimating()
            
            let width = Int(cell.image.bounds.size.width * UIScreen.main.scale)
            let height = Int(cell.image.bounds.size.height * UIScreen.main.scale)
            
            let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
            
            let url = URL(string: item.item.url + queryResize)!
            
            cell.image.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3),
                                   runImageTransitionIfCached: true, completion: { [weak cell] image in
                                    
                                    cell?.busy.stopAnimating()
            })
        })
    }
    
    private func createDataSource() {
    
        self.dataSource.onDidSelectRowAtIndexPath = { (tableView, indexPath, item) in
            
            if item.itemType as! STAttachmentItemsEnum == .photo {
                
                let photoController = DKImagePickerController()
                photoController.maxSelectableCount = 10
                photoController.sourceType = .photo
                photoController.didSelectAssets = { [] assets in
                    
                    print("didSelectAssets")
                    print(assets)
                }
                
                self.present(photoController, animated: true, completion: nil)
            }
        }
        
        self.section.header(headerClass: STContactHeaderCell.self) { (view, section) in
            
            let header = view as! STContactHeaderCell
            
            header.title.text = "ПРИКРЕПИТЬ К ТЕМЕ:"
            header.title.font = UIFont.systemFont(ofSize: 12)
            header.title.textColor = UIColor.stSteelGrey
            header.topSpace.constant = 16
        }
        
        self.section.headerItem?.cellHeight = 46
        
        self.section.addItem(cellClass: STAttachmentCell.self, itemType: STAttachmentItemsEnum.photo) { (cell, item) in
            
            let viewCell = cell as! STAttachmentCell
            viewCell.icon.image = UIImage(named: "icon-attachment-image")
            viewCell.title.text = "Фотографии"
            viewCell.subtitle.text = "Выбрать фотографии"
        }
        
        self.section.addItem(cellClass: STAttachmentCell.self, itemType: STAttachmentItemsEnum.location) { (cell, item) in
            
            let viewCell = cell as! STAttachmentCell
            viewCell.icon.image = UIImage(named: "icon-attachment-location")
            viewCell.title.text = "Адрес"
            viewCell.subtitle.text = "Добавить адрес"
        }
    }
}
