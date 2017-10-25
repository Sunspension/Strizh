//
//  ChatView.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/10/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

protocol ChatViewOutputable: class {
    
    func viewWillAppear()
    
    func viewWillDisappear()
    
    func viewDidLoad()
    
    func popAction()
}

protocol ChatViewInputable {
    
    func showActivityIndicator()
    
    func hideActivityIndicator()
    
    func updateViewAfterLoadMore()
    
    func scrollToLastMessage(indexPath: IndexPath, animated: Bool)
    
    func reloadTableView(animation: Bool)
    
    func onError(error: STError)
}

class ChatView: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomToolbar: UIView!
    
    @IBOutlet weak var placeHolder: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var bottomToolbarSpace: NSLayoutConstraint!
    
    var presenter: ChatViewOutputable!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setupView()
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.presenter.viewWillDisappear()
        
        // checking press back button
        if self.navigationController?.viewControllers.index(of: self) == nil {
            
            presenter.popAction()
        }
    }
    
    private func setupView() {
        
        // textview
        self.textView.layer.cornerRadius = 5
        self.textView.clipsToBounds = true
        self.textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
    }
}

extension ChatView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.placeHolder.isHidden = !textView.text.isEmpty
    }
}

extension ChatView: ChatViewInputable {
    
    func reloadTableView(animation: Bool) {
        
        if animation {
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        else {
            
            self.tableView.reloadData()
        }
        
        if self.tableView.numberOfSections == 0
            || self.tableView.numberOfRows(inSection: 0) == 0 {
            
            self.showDummyView(imageName: "empty-messages",
                               title: "dummy_chat_empty_mesages_title".localized,
                               subTitle: "dummy_chat_empty_mesages_subtitle".localized) { view in
                                
                                view.backgroundColor = UIColor.white
            }
        }
        else {
            
            self.hideDummyView()
        }
    }
    
    func scrollToLastMessage(indexPath: IndexPath, animated: Bool) {
        
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
    
    func updateViewAfterLoadMore() {
        
        let sizeBefore = self.tableView.contentSize
        let offSet = self.tableView.contentOffset
        
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        
        let sizeAfter = self.tableView.contentSize
        let newOffsetY = offSet.y + sizeAfter.height - sizeBefore.height
        
        self.tableView.contentOffset = CGPoint(x: 0, y: newOffsetY)
    }

    func showActivityIndicator() {
        
        self.tableView.showBusy()
    }
    
    func hideActivityIndicator() {
        
        self.tableView.hideBusy()
    }
}
