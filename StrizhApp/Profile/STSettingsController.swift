//
//  STSettingsController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 15/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RealmSwift

class STSettingsController: UITableViewController {

    fileprivate enum STSettingItemsEnum {
        
        case deals, messages, terms, policy, agreement, logout
    }
    
    fileprivate let dataSource = TableViewDataSource()
    
    fileprivate let section1 = TableSection(title: "settings_page_events_text".localized)
    
    fileprivate let section2 = TableSection(title: "settings_page_about_app_text".localized)
    
    fileprivate let logoutSection = TableSection()
    
    fileprivate var myUser: STUser {
        
        return STUser.objects(by: STUser.self).first!
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    init() {
        
        super.init(style: .grouped)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.analytics.logEvent(eventName: st_eApplicationSettings, timed: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.analytics.endTimeEvent(eventName: st_eApplicationSettings)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.dataSource.sections.append(self.section1)
        self.dataSource.sections.append(self.section2)
        self.dataSource.sections.append(self.logoutSection)
        
        self.tableView.dataSource = self.dataSource
        
        self.tableView.register(nibClass: STFeedFilterSwitchTableViewCell.self)
        
        self.title = "settings_page_title".localized
        
        let leftItem = UIBarButtonItem(title: "action_close".localized, style: .plain, target: self, action: #selector(self.close))
        
        self.navigationItem.leftBarButtonItem = leftItem
        
        self.setCustomBackButton()
        self.createDataSource()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = dataSource.item(by: indexPath)
        
        switch item.itemType as! STSettingItemsEnum {
            
        case .deals:
            
            break
            
        case .policy:
            
            if let path = Bundle.main.path(forResource: "policy", ofType: "pdf") {
                
                self.st_router_openDocumentController(url: URL(fileURLWithPath: path),
                                                                  title: "settings_privacy_policy_text".localized,
                                                                  present: false)
            }
            
            break
            
        case .terms:
            
            if let path = Bundle.main.path(forResource: "terms", ofType: "pdf") {
                
                self.st_router_openDocumentController(url: URL(fileURLWithPath: path),
                                                                  title: "settings_terms_&_condictions_text".localized,
                                                                  present: false)
            }
            
            break
            
        case .agreement:
            
            if let path = Bundle.main.path(forResource: "agreement", ofType: "pdf") {
                
                self.st_router_openDocumentController(url: URL(fileURLWithPath: path),
                                                                  title: "settings_processing_personal_data_text".localized, present: false)
            }
            
            break
            
        case .logout:
            
            self.analytics.logEvent(eventName: st_eLogout)
            self.st_router_logout()
            
            break
            
        default:
            break
        }
    }
    
    func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func createDataSource() {
        
        self.section1.addItem(cellClass: STFeedFilterSwitchTableViewCell.self,
                              item: self.myUser, itemType: STSettingItemsEnum.deals) { (cell, item) in
                                
                                let user = item.item as! STUser
                                let viewCell = cell as! STFeedFilterSwitchTableViewCell
                                viewCell.title.text = "settings_page_topics_text".localized
                                viewCell.toggle.isOn = user.notificationSettings.isTopics
                                viewCell.onTogglePressed = { [viewCell, weak self] isOn in
                                    
                                    viewCell.spiner.startAnimating()
                                    viewCell.toggle.isEnabled = false
                                    
                                    Object.updateObject {
                                        
                                        user.notificationSettings.isTopics = isOn
                                    }
                                    
                                    self?.updateNotificationSettings({ error in
                                    
                                        viewCell.toggle.isEnabled = true
                                        viewCell.spiner.stopAnimating()
                                        
                                        if error == nil {
                                            
                                            return
                                        }
                                        
                                        viewCell.toggle.isOn = user.notificationSettings.isTopics
                                    })
                                }
        }
        
        self.section1.addItem(cellClass: STFeedFilterSwitchTableViewCell.self,
                              item: self.myUser, itemType: STSettingItemsEnum.messages) { (cell, item) in
                                
                                let user = item.item as! STUser
                                let viewCell = cell as! STFeedFilterSwitchTableViewCell
                                viewCell.title.text = "settings_page_messages_text".localized
                                viewCell.toggle.isOn = user.notificationSettings.isMessages
                                viewCell.onTogglePressed = { [viewCell, weak self] isOn in
                                    
                                    viewCell.spiner.startAnimating()
                                    viewCell.toggle.isEnabled = false
                                    
                                    Object.updateObject {
                                        
                                        user.notificationSettings.isMessages = isOn
                                    }
                                    
                                    self?.updateNotificationSettings({ error in
                                        
                                        viewCell.toggle.isEnabled = true
                                        viewCell.spiner.stopAnimating()
                                        
                                        if error == nil {
                                            
                                            return
                                        }
                                        
                                        viewCell.toggle.isOn = user.notificationSettings.isMessages
                                    })
                                }
        }
        
        self.section2.addItem(cellStyle: .default, itemType: STSettingItemsEnum.policy) { (cell, item) in
            
            cell.textLabel?.text = "settings_privacy_policy_text".localized
            cell.accessoryType = .disclosureIndicator
        }
        
        self.section2.addItem(cellStyle: .default, itemType: STSettingItemsEnum.terms) { (cell, item) in
            
            cell.textLabel?.text = "settings_terms_&_condictions_text".localized
            cell.accessoryType = .disclosureIndicator
        }
        
        self.section2.addItem(cellStyle: .default, itemType: STSettingItemsEnum.agreement) { (cell, item) in
            
            cell.textLabel?.text = "settings_processing_personal_data_text".localized
            cell.textLabel?.numberOfLines = 0
            cell.accessoryType = .disclosureIndicator
        }
        
        self.logoutSection.addItem(cellStyle: .default, itemType: STSettingItemsEnum.logout) { (cell, item) in
            
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.stBrick
            cell.textLabel?.text = "settings_page_singout_text".localized
        }
    }
    
    fileprivate func updateNotificationSettings(_ callBack:@escaping (_ error: STError?) -> Void) {
        
        api.updateUserNotificationSettings(settings: self.myUser.notificationSettings, userId: self.myUser.id)
            .onSuccess { user in
            
                user.writeToDB()
                callBack(nil)
            }
            .onFailure { error in
                
                callBack(error)
            }
    }
}
