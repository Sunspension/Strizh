//
//  STAttachmentPhotoCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import KDCircularProgress
import ReactiveKit

class STAttachmentPhotoCell: UICollectionViewCell {
    
    private var angle = 0.0
    
    private let coloredLayer = CALayer()

    var bag = DisposeBag()
    
    @IBOutlet weak var image: UIImageView!

    @IBOutlet weak var delete: UIButton!
    
    @IBOutlet weak var progress: KDCircularProgress!
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    
    deinit {
        
        self.bag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.image.layer.cornerRadius = 5
        self.image.clipsToBounds = true
        
        self.reset()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.coloredLayer.frame = self.image.bounds
    }
    
    override func prepareForReuse() {
        
        self.angle = 0.0
        self.reset()
        self.bag.dispose()
    }
    
    func setProgress(progress: Double) {
        
        let toAngle = 360 * (progress / 1)
        let fromAngle = self.angle
        self.angle = toAngle
        
        self.progress.animate(fromAngle: fromAngle, toAngle: toAngle, duration: 0.5, completion: nil)
    }
    
    func waiting() {
        
        self.loadingLabel.text = "Ожидание"
    }
    
    func uploading() {
        
        self.loadingLabel.text = "Загрузка..."
    }
    
    func error() {
        
        self.delete.isHidden = false
        self.loadingLabel.text = "Ошибка!"
        self.coloredLayer.backgroundColor = UIColor.stBrownish.cgColor
        self.progress.isHidden = true
    }
    
    func uploaded() {
        
        self.delete.isHidden = false
        self.progress.isHidden = true
        self.loadingLabel.text = ""
        self.coloredLayer.removeFromSuperlayer()
    }
    
    private func reset() {
        
        if self.coloredLayer.superlayer == nil {
            
            self.image.layer.addSublayer(self.coloredLayer)
        }
        
        self.coloredLayer.backgroundColor = UIColor.stCloudyBlue.cgColor
        self.delete.isHidden = true
        self.progress.isHidden = false
        setProgress(progress: 0)
    }
}
