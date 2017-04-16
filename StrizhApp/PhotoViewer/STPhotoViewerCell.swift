//
//  STPhotoViewerCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 15/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STPhotoViewerCell: UICollectionViewCell {
    
    @IBOutlet weak var scroller: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var spiner: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        scroller.delegate = self
        scroller.zoomScale = 1
        scroller.maximumZoomScale = 8
        scroller.isScrollEnabled = false
        scroller.showsVerticalScrollIndicator = false
        scroller.showsHorizontalScrollIndicator = false
    }
    
    override func prepareForReuse() {
        
        imageView.image = nil
        scroller.zoomScale = 1
    }
}


extension STPhotoViewerCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        if !scroller.isScrollEnabled {
            
            scroller.isScrollEnabled = true
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        scroller.isScrollEnabled = scale > 1
    }
}
