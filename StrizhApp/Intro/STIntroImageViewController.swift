//
// Created by Vladimir Kokhanevich on 31/08/16.
// Copyright (c) 2016 iConto LLC. All rights reserved.
//

import Foundation
import UIKit

class STIntroImageViewController : UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var mainTitle: UILabel!
    
    @IBOutlet weak var subtitle: UILabel!
    
    @IBOutlet weak var nextAction: UIButton!
    
    @IBOutlet weak var container: UIView!
    
    var introObject: STIntroObject?
    
    var nextActionClosure: (() -> Void)?
    
    
    var imageName: String?

    
    override func loadView() {
        
        super.loadView()
        
        self.container.layer.cornerRadius = 15
        self.container.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let object = introObject {

            imageView.image = UIImage(named: object.imageName)
            mainTitle.text = object.title
            subtitle.text = object.subtitle
            nextAction.addTarget(self, action: #selector(self.nextActionHandler), for: .touchUpInside)
            nextAction.setTitle(object.nextTitle, for: .normal)
        }
    }
    
    @objc func nextActionHandler() {
        
        self.nextActionClosure?()
    }
}
