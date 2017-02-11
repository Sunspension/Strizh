//
//  STFeedDetailsTableViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 10/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage

class STFeedDetailsTableViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var actionWrite: UIButton!
    
    private let dataSource = TableViewDataSource()
    
    private let section = CollectionSection()
    
    var user: STUser?
    
    var post: STPost?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        
        self.tableView.dataSource = self.dataSource
        
        self.tableView.register(cell: STPostDetailsMainInfoCell.self)
        self.tableView.register(cell: STPostDetailsMapsCell.self)
        
        self.navigationItem.title = "Информация"
    
        self.dataSource.sections.append(self.section)
        
        self.createDataSource()
    }

    private func createDataSource() {
        
        self.section.addItem(cellClass: STPostDetailsMainInfoCell.self,
                             item: self.post) { [unowned self] (cell, item) in
                                
                                cell.selectionStyle = .none
                                
                                let viewCell = cell as! STPostDetailsMainInfoCell
                                
                                if let post = item.item as? STPost {
                                    
                                    viewCell.postTitle.text = post.title
                                    viewCell.postDetails.text = post.postDescription
                                    viewCell.favorite.isSelected = post.isFavorite
                                    viewCell.postType.isSelected = post.type == 2 ? true : false
                                    viewCell.postTime.text = post.createdAt?.elapsedInterval()
                                    
                                    if let user = self.user {
                                        
                                        viewCell.userName.text = user.lastName + " " + user.firstName
                                        
                                        guard !user.imageUrl.isEmpty else {
                                            
                                            return
                                        }
                                        
                                        let width = Int(viewCell.userIcon.bounds.size.width * UIScreen.main.scale)
                                        let height = Int(viewCell.userIcon.bounds.size.height * UIScreen.main.scale)
                                        
                                        let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                                        
                                        let urlString = user.imageUrl + queryResize
                                        
                                        let filter = RoundedCornersFilter(radius: viewCell.userIcon.bounds.size.width)
                                        viewCell.userIcon.af_setImage(withURL: URL(string: urlString)!,
                                                                  filter: filter,
                                                                  completion: nil)
                                    }
                                }
        }
        
//        self.section.addItem(cellClass: STPostDetailsMapsCell.self,
//                             item: <#T##Any?#>, itemType: <#T##Any?#>, bindingAction: <#T##BindingAction?##BindingAction?##(UITableViewCell, CollectionSectionItem) -> Void#>)
    }
}
