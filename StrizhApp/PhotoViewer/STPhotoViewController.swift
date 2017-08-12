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
    
    var images: [STImage]!
    
    var photoIndex: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = self.collectionView!.bounds.size
        
        let leftItem = UIBarButtonItem(title: "action_cancel".localized, style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.collectionView?.scrollToItem(at: IndexPath(item: self.photoIndex, section: 0), at: .centeredHorizontally, animated: false)
        
        self.title = "\(self.photoIndex! + 1)/\(self.images!.count)"
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let viewCell = cell as! STPhotoViewerCell
        let item = self.images[indexPath.row]
        
        viewCell.spiner.startAnimating()
        
        let url = URL(string: item.url)!
        
        viewCell.imageView.af_setImage(withURL: url,
                                       imageTransition: .crossDissolve(0.3),
                                       runImageTransitionIfCached: true, completion: { [weak viewCell] image in
                                        
                                        viewCell?.spiner.stopAnimating()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: STPhotoViewerCell.self),
                                                      for: indexPath) as! STPhotoViewerCell
        return cell
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let rect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        let point = CGPoint(x: rect.midX , y: rect.midY)
        
        let collectionView = scrollView as! UICollectionView
        
        if let indexPath = collectionView.indexPathForItem(at: point) {
            
            self.title = "\(indexPath.row + 1)/\(self.images.count)"
        }
    }
    
    func cancel() {
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension UICollectionViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = collectionView.bounds.size
        
        return CGSize(width: size.width, height: size.height - collectionView.contentInset.top)
    }
}
