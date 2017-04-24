//
// Created by Vladimir Kokhanevich on 31/08/16.
// Copyright (c) 2016 iConto LLC. All rights reserved.
//

import Foundation
import UIKit

class STIntroImageViewController : UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var imageName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let name = imageName {

            imageView.image = UIImage(named: name)
        }
    }
}
