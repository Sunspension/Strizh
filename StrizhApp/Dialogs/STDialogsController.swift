//
//  STDialogsController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage
import ReactiveKit

class STDialogsController: UITableViewController {

    private let dataSource = TableViewDataSource()
    
    private let section = CollectionSection()
    
    private var loadingStatus = STLoadingStatusEnum.idle
    
    private var hasMore = false
    
    private var page = 1
    
    private var pageSize = 20
    
    private var users = Set<STUser>()
    
    private var messages = [STMessage]()
    
    private var myUser: STUser!
    
    private let bag = DisposeBag()
    
    
    deinit {
        
        bag.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorInset = .zero
        
        self.myUser = STUser.objects(by: STUser.self).first!
        
        self.createRefreshControl()
        self.setupDataSource()
        self.loadDialogs()
    }
   
    private func setupDataSource() {
        
        self.dataSource.sections.append(self.section)
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
    }
    
    private func loadDialogs() {
        
        self.loadingStatus = .loading
        self.tableView.showBusy()
        
        api.loadDialogs(page: self.page, pageSize: self.pageSize)
            
            .onSuccess { [unowned self] dialogPage in
            
                self.loadingStatus = .loaded
                self.tableView.hideBusy()
                
                if let control = self.refreshControl, control.isRefreshing {
                    
                    self.section.items.removeAll()
                    control.endRefreshing()
                }
                
                self.page += 1
                
                self.hasMore = dialogPage.dialogs.count == self.pageSize
                
                self.handleResponse(dialogsPage: dialogPage)
                self.tableView.reloadData()
            }
            .onFailure { [unowned self] error in
                
                self.loadingStatus = .failed
                self.tableView.hideBusy()
                
                if let control = self.refreshControl, control.isRefreshing {
                    
                    control.endRefreshing()
                }
                
                self.showError(error: error)
            }
    }
    
    private func handleResponse(dialogsPage: STDialogsPage) {
        
        self.messages.append(contentsOf: dialogsPage.messages)
        
        for user in dialogsPage.users {
            
            self.users.insert(user)
        }
        
        for dialog in dialogsPage.dialogs {
            
            self.section.addItem(cellClass: STDialogCell.self, item: dialog, bindingAction: { (cell, item) in
                
                if item.indexPath.row + 10 > self.section.items.count
                    && self.loadingStatus != .loading && self.hasMore {
                    
                    self.loadDialogs()
                }
                
                let viewCell = cell as! STDialogCell
                let dialog = item.item as! STDialog
                
                viewCell.topicTitle.text = dialog.title
                
                if (dialog.unreadMessageCount == 0) {
                    
                    viewCell.newMessageCounter.isHidden = true
                    viewCell.backgroundView?.backgroundColor = UIColor.clear
                }
                else {
                    
                    viewCell.backgroundView?.backgroundColor = UIColor.stPaleGrey
                    viewCell.newMessageCounter.isHidden = false
                    viewCell.newMessageCounter.setTitle("\(dialog.unreadMessageCount)", for: .normal)
                    viewCell.newMessageCounter.sizeToFit()
                }
                
                // get user
                if let user = self.users.first(where: { $0.id == dialog.ownerUserId }) {
                    
                    viewCell.userName.text = user.firstName + " " + user.lastName
                    
                    if !user.imageUrl.isEmpty {
                        
                        let width = Int(viewCell.userImage.bounds.size.width * UIScreen.main.scale)
                        let height = Int(viewCell.userImage.bounds.size.height * UIScreen.main.scale)
                        
                        let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                        
                        let urlString = user.imageUrl + queryResize
                        
                        let filter = RoundedCornersFilter(radius: CGFloat(width))
                        viewCell.userImage.af_setImage(withURL: URL(string: urlString)!,
                                                          filter: filter,
                                                          completion: nil)
                    }
                }
                
                // get the date and the time
                viewCell.time.text = dialog.createdAt.mediumLocalizedFormat
                
                // get last message
                if let message = self.messages.first(where: { $0.id == dialog.messageId }) {
                    
                    if message.userId == self.myUser.id {
                        
                        viewCell.inOutIcon.isSelected = true
                        
                        let prefixColor = UIColor(red: 75 / 255.0, green: 75 / 255.0, blue: 75 / 255.0, alpha: 1)
                        let prefix = NSMutableAttributedString(attributedString: "Вы: ".string(with: prefixColor))
                        
                        let messageColor = UIColor(red: 129 / 255.0, green: 129 / 255.0, blue: 129 / 255.0, alpha: 1)
                        prefix.append(message.message.string(with: messageColor))
                        
                        viewCell.message.attributedText = prefix
                    }
                    else {
                        
                        viewCell.inOutIcon.isSelected = false
                        viewCell.message.text = message.message
                    }
                }
            })
        }
    }
    
    private func createRefreshControl() {
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.reactive.refreshing.observeNext(with: { [unowned self] refreshing in
            
            if !refreshing {
                
                return
            }
            
            self.page = 1
            self.loadDialogs()
            
        }).dispose(in: bag)
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
