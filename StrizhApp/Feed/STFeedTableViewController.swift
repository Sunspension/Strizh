//
//  STFeedTableViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 05/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage

class STFeedTableViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    private var dataSource: GenericTableViewDataSource<STPostTableViewCell, STPost>?
    
    private let tableSection = GenericCollectionSection<STPost>()
    
    private var users = Set<STUser>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 155
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        
        self.dataSource = GenericTableViewDataSource(nibClass: STPostTableViewCell.self) { [unowned self] (cell, item) in
            
            let post = item.item
            
            cell.selectionStyle = .none
            cell.postTitle.text = post.title
            cell.postDetails.text = post.postDescription
            
            if let user = self.users.first(where: { $0.id == post.userId }) {
                
                cell.userName.text = user.lastName + " " + user.firstName
                
                var filters = [ImageFilter]()
                
                filters.append(AspectScaledToFillSizeFilter(size: cell.userIcon.bounds.size))
                filters.append(RoundedCornersFilter(radius: cell.userIcon.bounds.size.width))
                let compositeFilter = DynamicCompositeImageFilter(filters)
                
                cell.userIcon.af_setImage(withURL: URL(string: user.imageUrl!)!,
                                          filter: compositeFilter, completion: nil)
            }
            else {
                
                self.api.loadUser(transport: .webSocket, userId: post.userId)
                    .onSuccess(callback: { [unowned self] user in
                        
                        self.users.insert(user)
                        cell.userName.text = user.lastName + " " + user.firstName
                        
                        var filters = [ImageFilter]()
                        
                        filters.append(AspectScaledToFillSizeFilter(size: cell.userIcon.bounds.size))
                        filters.append(RoundedCornersFilter(radius: cell.userIcon.bounds.size.width))
                        let compositeFilter = DynamicCompositeImageFilter(filters)
                        
                        cell.userIcon.af_setImage(withURL: URL(string: user.imageUrl!)!,
                                                  filter: compositeFilter, completion: nil)
                    })
            }
        }
        
        self.dataSource!.sections.append(self.tableSection)
        
        self.tableView.dataSource = self.dataSource
        
        api.loadFeed(page: 0, pageSize: 20).onSuccess { [unowned self] feed in
            
            self.createDataSource(feed: feed)
            self.tableView.reloadData()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Private methods
    
    private func createDataSource(feed: [STPost]) {
        
        feed.forEach { post in
            
            self.tableSection.add(item: post)
        }
    }
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
