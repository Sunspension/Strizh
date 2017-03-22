//
//  STAttachmentPhotoCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import KDCircularProgress

class STAttachmentPhotoCell: UICollectionViewCell {
    
    private var angle = 0.0
    
    private let coloredLayer = CALayer()
    
    var onDeleteAction: (() -> Void)?
    
    @IBOutlet weak var image: UIImageView!

    @IBOutlet weak var delete: UIButton!
    
    @IBOutlet weak var progress: KDCircularProgress!
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    @IBOutlet weak var busyIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.image.layer.cornerRadius = 5
        self.image.clipsToBounds = true
        self.delete.addTarget(self, action: #selector(self.deleteAction), for: .touchUpInside)
        self.initialize()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.coloredLayer.frame = self.image.bounds
    }
    
    override func prepareForReuse() {
        
        self.initialize()
        self.image.image = nil
        self.onDeleteAction = nil
    }
    
    func setProgress(progress: Double) {
        
        let toAngle = 360 * (progress / 1)
        let fromAngle = self.angle
        self.angle = toAngle
        
        self.progress.animate(fromAngle: fromAngle, toAngle: toAngle, duration: 0.5, completion: nil)
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
    
    func deleteAction() {
        
        self.onDeleteAction?()
    }
    
    private func initialize() {
        
        if self.coloredLayer.superlayer == nil {
            
            self.image.layer.addSublayer(self.coloredLayer)
        }
        
        self.loadingLabel.text = "Ожидание"
        self.angle = 0.0
        self.coloredLayer.backgroundColor = UIColor.stCloudyBlue.cgColor
        self.delete.isHidden = true
        self.progress.isHidden = false
        setProgress(progress: 0)
    }
}
