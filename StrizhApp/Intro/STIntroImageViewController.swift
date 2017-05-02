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
    
    
    var imageName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.container.layer.cornerRadius = 7
        self.container.clipsToBounds = true
        
        if let name = imageName {

            imageView.image = UIImage(named: name)
        }
    }
}
