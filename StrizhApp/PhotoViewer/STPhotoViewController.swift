//
//  STPhotoViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 15/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage

class STPhotoViewController: UICollectionViewController {

    private var dataSource: GenericCollectionViewDataSource<STPhotoViewerCell, STImage>?
    
    private var section = GenericTableSection<STImage>()
    
    
    var images: [STImage]!
    
    var photoIndex: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
        
        self.setupDataSource()
        self.createDataSource()
        
        self.collectionView?.dataSource = self.dataSource
        self.collectionView?.delegate = self.dataSource
        
        let leftItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem = leftItem
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.collectionView?.scrollToItem(at: IndexPath(item: self.photoIndex, section: 0), at: .centeredHorizontally, animated: false)
        
        self.title = "\(self.photoIndex! + 1)/\(self.images!.count)"
    }
    
    func cancel() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupDataSource() {
        
        self.dataSource = GenericCollectionViewDataSource(cellClass: STPhotoViewerCell.self,
                                                          binding: { (cell, item) in
                                                            
                                                            cell.spiner.startAnimating()
                                                            
                                                            let url = URL(string: item.item.url + cell.imageView.queryResizeString())!
                                                            
                                                            cell.imageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3),
                                                                                   runImageTransitionIfCached: true, completion: { [weak cell] image in
                                                                                    
                                                                                    cell?.spiner.stopAnimating()
                                                            })
        })
        
        self.dataSource!.sections.append(self.section)
        
        self.dataSource!.onDidScrollToCellIndexPath = { (collectionView, indexPath) in
            
            self.title = "\(indexPath.row + 1)/\(self.images!.count)"
        }
    }
    
    fileprivate func createDataSource() {
        
        guard let images = self.images else {
            
            return
        }
        
        for image in images {
            
            self.section.add(item: image)
        }
    }
}
