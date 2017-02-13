//
//  STProfileTableViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 13/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RealmSwift
import AlamofireImage

class STProfileTableViewController: UITableViewController {

    private let dataSource = TableViewDataSource()
    
    private let headerSection = CollectionSection()
    
    private let postsSection = CollectionSection()
    
    private var user: STUser?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 176
        self.tableView.separatorStyle = .none
        
        self.tableView.register(cell: STProfileHeaderCell.self)
        self.tableView.register(headerFooterCell: STProfilePostHeader.self)
        
        self.setupDataSource()
        
        if let user = STUser.objects(by: STUser.self).first {
            
            self.user = user
            self.createDataSource()
        }
        else {
            
            if let session = STSession.objects(by: STSession.self).first {
                
                api.loadUser(transport: .webSocket, userId: session.userId)
                    .onSuccess(callback: { [unowned self] user in
                        
                        self.user = user
                        user.updateUserImage()
                        
                        self.createDataSource()
                        self.tableView.reloadData()
                    })
            }
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


    private func setupDataSource() {
        
        self.dataSource.sections.append(self.headerSection)
        self.dataSource.sections.append(self.postsSection)
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
    }
    
    private func createDataSource() {
        
        self.headerSection.addItem(cellClass: STProfileHeaderCell.self,
                                   item: self.user) { (cell, item) in
                                    
                                    let viewCell = cell as! STProfileHeaderCell
                                    
                                    if let user = item.item as? STUser {
                                        
                                        viewCell.userName.text = user.firstName + " " + user.lastName
                                        viewCell.edit.makeCircular()
                                        viewCell.settings.makeCircular()
                                        
                                        if let imageData = user.imageData {
                                            
                                            viewCell.userImage.image = UIImage(data: imageData)
                                            viewCell.userImage.makeCircular()
                                        }
                                        else {
                                            
                                            guard !user.imageUrl.isEmpty else {
                                                
                                                return
                                            }
                                            
                                            let width = Int(viewCell.userImage.bounds.size.width * UIScreen.main.scale)
                                            let height = Int(viewCell.userImage.bounds.size.height * UIScreen.main.scale)
                                            
                                            let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                                            
                                            let urlString = user.imageUrl + queryResize
                                            
                                            let filter = RoundedCornersFilter(radius: viewCell.userImage.bounds.size.width)
                                            viewCell.userImage.af_setImage(withURL: URL(string: urlString)!,
                                                                           filter: filter) { response in
                                                                            
                                                                            if let image = response.result.value {
                                                                                
                                                                                self.user?.imageData = UIImageJPEGRepresentation(image, 1)
                                                                                self.user?.writeToDB()
                                                                            }
                                            }
                                        }
                                    }
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
