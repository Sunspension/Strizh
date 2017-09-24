//
//  STContactsController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 25/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ReactiveKit
import Bond
import Dip
import AlamofireImage
import MessageUI

fileprivate enum SectionItemTypeEnum {
    
    case invite, notRegistered
}

class STContactsController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, NVActivityIndicatorViewable, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let notRegisteredContactsSection = TableSection()
    
    private let inviteSection = TableSection()
    
    private var searchString = ""
    
    private var keyBoardHeight: CGFloat = 0
    
    private lazy var textToShare: String = {
        
        var textToShare = "https://strizhapp.ru"
        
        if let user = STUser.objects(by: STUser.self).first {
            
            textToShare += "/?ref=\(user.id)"
        }
        
        return textToShare
    }()
    
    private var smsController: MFMessageComposeViewController?
    
    let dataSource = TableViewDataSource()
    
    let searchDataSource = TableViewDataSource()
    
    var contactsProvider: STContactsProvider {
        
        return STContactsProvider.sharedInstance
    }
    
    var disposeBag = DisposeBag()
    
    var myUser: STUser {
        
        return STUser.objects(by: STUser.self).first!
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if self.navigationController != nil && self.navigationController!.isBeingPresented {
            
            let leftItem = UIBarButtonItem(title: "action_cancel".localized, style: .plain, target: self, action: #selector(self.close))
            self.navigationItem.leftBarButtonItem = leftItem
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.stLightBlueGrey
        
        self.tableView.backgroundView = backgroundView
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
        self.tableView.register(nibClass: STContactCell.self)
        self.tableView.register(headerFooterNibClass: STContactHeaderCell.self)
        
        self.title = "contacts_page_title".localized
        
        setup()
        setCustomBackButton()
        setupDataSource()
        synchronizeContacts()
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let height = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            self.keyBoardHeight = height
        }
        
        if let dummy = self.dummyView() {
            
            let inset = self.tableView.contentInset
            let bounds = self.view.bounds
            let visibleRect = CGRect(x: bounds.minX,
                                     y: inset.top,
                                     width: bounds.width,
                                     height: bounds.height - self.keyBoardHeight)
            
            dummy.center = CGPoint(x: dummy.center.x, y: visibleRect.midY)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        if let dummy = self.dummyView() {
            
            let inset = self.tableView.contentInset
            let bounds = self.view.bounds
            let visibleRect = CGRect(x: bounds.minX,
                                     y: inset.top,
                                     width: bounds.width,
                                     height: bounds.height - inset.bottom)
            
            dummy.center = CGPoint(x: dummy.center.x, y: visibleRect.midY)
        }
    }
    
    //MARK: - UISearchBar delegate implementation
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        self.tableView.dataSource = self.searchDataSource
        self.tableView.delegate = self.searchDataSource
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        self.reloadTableView()
    }
    
    //MARK: - UISearchResultUpdating delegate implementation
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let string = searchController.searchBar.text {
            
            let query = string
            
            let time = DispatchTime.now() + 0.3
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                
                guard searchController.searchBar.text == query else {
                    
                    return
                }
                
                self.searchContacts(searchString: query)
                self.analytics.logEvent(eventName: st_eContactSearch, params: ["query" : query])
            }
        }
    }
    
    func setup() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kUserUpdatedNotification), object: nil)
            .observeNext { [unowned self] notification in
                
                self.tableView.reloadData()
            }
            .dispose(in: disposeBag)
    }
    
    //MARK: - Private methods
    
    @objc fileprivate func close() {
        
        self.dismiss(animated: true, completion: nil)
    }

    func setupDataSource() {
        
        self.dataSource.onDidSelectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) in
            
            if let type = item.itemType as? SectionItemTypeEnum {
                
                switch type {
                    
                case .invite:
                    
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.inviteContacts()
                    
                    return
                    
                case .notRegistered:
                    
                    return
                }
            }
            
            // TODO handle tap on not registered contact
            
            
            let contact = item.item as! STContact
            self.st_router_openUserProfile(userId: contact.contactUserId)
        }
        
        self.contactsProvider.loadingStatusChanged = { loadingStatus in
            
            switch loadingStatus {
                
            case .loading:
                
                self.tableView.showBusy()
                
            default:
                
                self.tableView.hideBusy()
            }
        }
    }
    
    func synchronizeContacts() {
        
        _ = self.contactsProvider.contacts.andThen { result in
            
            if let contacts = result.value {
                
                self.inviteSection.add(itemType: SectionItemTypeEnum.invite,
                                       cellClass: STContactCell.self, bindingAction: { (cell, item) in
                                        
                                        let viewCell = cell as! STContactCell
                                        viewCell.contactImage.setImage(UIImage(named: "icon-invite"), for: .normal)
                                        viewCell.contactImage.isUserInteractionEnabled = false
                                        viewCell.contactName.text = "Пригласить в STRIZHAPP"
                                        viewCell.contactName.font = UIFont.systemFont(ofSize: 16)
                                        viewCell.contactName.textColor = UIColor.stBrightBlue
                                        viewCell.accessoryType = .none
                                        viewCell.disableSelection = true
                                        viewCell.selectionStyle = .default
                                        viewCell.invite.isHidden = true
                })
                
                self.dataSource.sections.append(self.inviteSection)
                
                self.createDataSource(for: self.dataSource, contacts: contacts)
                self.setupSearchController()
                self.reloadTableView()
            }
        }
    }
    
    func searchContacts(searchString: String) {
        
        self.searchDataSource.sections.removeAll()
        
        _ = self.contactsProvider.contacts.andThen { result in
            
            guard let contacts = result.value else {
                
                return
            }
            
            if searchString.isEmpty {
                
                self.createDataSource(for: self.searchDataSource, contacts: contacts)
                self.reloadTableView()
                return
            }
            
            let items = contacts.filter({ $0.firstName.contains(searchString) || $0.lastName.contains(searchString) })
            self.createDataSource(for: self.searchDataSource, contacts: items)
            self.reloadTableView()
        }
    }
    
    func createDataSource(for dataSource: TableViewDataSource, contacts: [STContact]) {
        
        for contact in contacts {
            
            if contact.isRegistered {
                
                let letter = String(contact.firstName.characters.first!)
                var section = dataSource.sections.filter({ $0.title == letter }).first
                
                if section == nil {
                    
                    section = TableSection(title: letter)
                    
                    section!.header(item: letter, headerClass: STContactHeaderCell.self, bindingAction: { (cell, item) in
                        
                        let header = cell as! STContactHeaderCell
                        let title = item.item as! String
                        
                        header.title.textColor = UIColor.black
                        header.title.text = title
                    })
                    
                    section!.headerItem!.cellHeight = 30
                    
                    dataSource.sections.append(section!)
                }
                
                section!.add(item: contact,
                             cellClass: STContactCell.self,
                             bindingAction: self.binding)
            }
            else {
                
                self.notRegisteredContactsSection.add(item: contact,
                                                      itemType: SectionItemTypeEnum.notRegistered,
                                                      cellClass: STContactCell.self,
                                                      bindingAction: self.binding)
            }
        }
        
        // sorting
        dataSource.sections.sort { (oneSection, otherSection) -> Bool in
            
            return oneSection.title! < otherSection.title!
        }
        
        if self.notRegisteredContactsSection.items.count > 0 {
            
            dataSource.sections.append(self.notRegisteredContactsSection)
            
            self.notRegisteredContactsSection.header(headerClass: STContactHeaderCell.self, bindingAction: { (cell, item) in
                
                let header = cell as! STContactHeaderCell
                header.title.text = "contacts_page_users_who_don't_use_app_title".localized
                header.title.textColor = UIColor.stSteelGrey
            })
            
            self.notRegisteredContactsSection.headerItem?.cellHeight = 30
        }
    }
    
    func setupSearchController() {
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "placeholder_search".localized
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor.stLightBlueGrey
        searchController.searchBar.backgroundImage = UIImage()
        
        if let textField = searchController.searchBar.value(forKey: "_searchField") as? UITextField {
            
            textField.backgroundColor = UIColor.stPaleGreyTwo
        }
        
        self.definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func binding(_ cell: UITableViewCell, item: TableSectionItem) {
        
        let viewCell = cell as! STContactCell
        let contact = item.item as! STContact
        
        viewCell.contactName.textColor = UIColor.black
        viewCell.contactName.text = contact.firstName + " " + contact.lastName
        viewCell.layoutMargins = UIEdgeInsets.zero
        viewCell.separatorInset = UIEdgeInsets.zero
        viewCell.selectionStyle = .default
        viewCell.disableSelection = true
        viewCell.accessoryType = .none
        viewCell.contactImage.isUserInteractionEnabled = false
        
        if contact.userId == myUser.id && self.myUser.imageData != nil {
            
            if let image = UIImage(data: self.myUser.imageData!) {
                
                let userIcon = image.af_imageAspectScaled(toFill: viewCell.contactImage.bounds.size)
                viewCell.contactImage.setImage(userIcon.af_imageRoundedIntoCircle(), for: .normal)
            }
        }
        else {
            
            if contact.imageUrl.isEmpty {
                
                var defaultImage = UIImage(named: "avatar")
                defaultImage = defaultImage?.af_imageAspectScaled(toFill: viewCell.contactImage.bounds.size)
                viewCell.contactImage.setImage(defaultImage?.af_imageRoundedIntoCircle(), for: .normal)
            }
            else {
                
                let urlString = contact.imageUrl + viewCell.contactImage.queryResizeString()
                let filter = RoundedCornersFilter(radius: viewCell.contactImage.bounds.size.width)
                viewCell.contactImage.af_setImage(for: .normal, url: URL(string: urlString)!, filter: filter)
            }
        }
        
        if contact.isRegistered {
            
            viewCell.invite.isHidden = true
            viewCell.selectionStyle = .default
        }
        else {
            
            viewCell.invite.isHidden = false
            viewCell.selectionStyle = .none
            viewCell.invite.reactive.tap.observeNext {
                
                let phoneNumber = "+" + contact.phone
                self.iviteViaSMS(phoneNumber: phoneNumber)
            }
            .dispose(in: viewCell.disposeBag)
        }
    }
    
    func reloadTableView(animation: Bool = false) {
        
        if animation {
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        else {
            
            self.tableView.reloadData()
        }
        
        if self.tableView.numberOfSections == 0
            || self.tableView.numberOfRows(inSection: 0) == 0 {
            
            if self.keyBoardHeight != 0 {
                
                let inset = self.tableView.contentInset
                let bounds = self.view.bounds
                let visibleRect = CGRect(x: bounds.minX,
                                         y: inset.top,
                                         width: bounds.width,
                                         height: bounds.height - self.keyBoardHeight)
                
                self.showDummyView(imageName: "empty-contacts",
                                   title: "contacts_page_empty_contacts_title".localized,
                                   subTitle: "contacts_page_empty_contacts_message".localized,
                                   inRect: visibleRect)
                return
            }
            
            self.showDummyView(imageName: "empty-contacts",
                               title: "contacts_page_empty_contacts_title".localized,
                               subTitle: "contacts_page_empty_contacts_message".localized)
        }
        else {
            
            self.hideDummyView()
        }
    }
    
    @objc private func inviteContacts() {
        
        let activity = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
        
        // analytics
        let container = AppDelegate.appSettings.dependencyContainer
        let analytics: STAnalytics = try! container.resolve()
        analytics.logEvent(eventName: st_eContactInvite)
    }
    
    private func iviteViaSMS(phoneNumber: String) {
        
        if MFMessageComposeViewController.canSendText() {
            
            smsController = MFMessageComposeViewController()
            smsController!.body = textToShare
            smsController!.recipients = [phoneNumber]
            smsController!.messageComposeDelegate = self
            self.present(smsController!, animated: true, completion: nil)
        }
    }
    
    //MARK: - MFMessageComposeViewControllerDelegate implementation
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        smsController!.dismiss(animated: true, completion: nil)
    }
}
