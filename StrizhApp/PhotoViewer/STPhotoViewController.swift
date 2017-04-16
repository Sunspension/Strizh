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
    
    
    var images: [STImage]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.dataSource = self.dataSource
        self.collectionView?.delegate = self.dataSource
        
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
        
        self.setupDataSource()
        self.createDataSource()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        self.dataSource?.sections.append(self.section)
    }
    
    fileprivate func createDataSource() {
        
        guard let images = self.images else {
            
            return
        }
        
        for image in images {
            
            self.section.add(item: image)
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
