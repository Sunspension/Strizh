//
//  STTabBarViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 01/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STTabBarViewController: UITabBarController {

    private var newPostButton: UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.newPostButton = UIBarButtonItem(image: UIImage(named: "icon-new-post"), style: .plain, target: self, action: #selector(self.openNewPostController))
        
        self.newPostButton = UIButton(type: .custom)
        self.newPostButton?.setImage(UIImage(named: "icon-new-post"), for: .normal)
        self.newPostButton?.sizeToFit()
        
//        let button = UIButton(type: .custom)
//        
//        self.newPostButton?.setImage(UIImage(named: "icon-new-post"), for: .normal)
//        self.newPostButton?.sizeToFit()

        
        self.tabBar.insertSubview(self.newPostButton!, at: 2)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openNewPostController() {
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let tabFrame = self.tabBar.frame
        
        let spaceBetween: CGFloat = 4
        
//        let totalWidth = self.tabBar.subviews.reduce(CGFloat(0.0), { $0.0 + $0.1.frame.size.width })
        
        let buttonWidth: CGFloat = (tabFrame.size.width - (CGFloat(self.tabBar.subviews.count) * spaceBetween)) / CGFloat(self.tabBar.subviews.count - 1)
        
        var x: CGFloat = 2
        
        self.tabBar.subviews.forEach { view in
            
            let viewFrame = view.frame
            
            let y: CGFloat = (tabFrame.size.height - viewFrame.size.height) / 2
            
            let newFrame = CGRect(x: x, y: y, width: buttonWidth, height: viewFrame.size.height)
            
            view.frame = newFrame
            
            x += (buttonWidth + spaceBetween)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
