//
//  STNewPostController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import Bond

class STNewPostController: UITableViewController {

    
    private var dataSource = TableViewDataSource()
    
    private var requiredFieldsSection = CollectionSection()
    
    private var optionalFieldsSection = CollectionSection()
    
    private var postObject: STNewPostObject?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let leftItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.title = "Новая тема"
    
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.register(cell: STTextFieldCell.self)
        self.tableView.register(cell: STPostButtonsCell.self)
        self.tableView.register(headerFooterCell: STContactHeaderCell.self)
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        self.dataSource.sections.append(self.requiredFieldsSection)
        self.dataSource.sections.append(self.optionalFieldsSection)
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
        self.createDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let navi = self.navigationController as? STNewPostNavigationController {
            
            self.postObject = navi.postObject
        }
    }
    
    func cancel() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func createDataSource() {
        
        self.dataSource.onDidSelectRowAtIndexPath = { (tableView, indexPath, item) in
            
            if let cell = tableView.cellForRow(at: item.indexPath) as? STTextFieldCell {
                
                cell.value.becomeFirstResponder()
            }
        }
        
        self.requiredFieldsSection.header(headerClass: STContactHeaderCell.self) { (view, section) in
            
            let header = view as! STContactHeaderCell
            
            header.title.text = "ОБЯЗАТЕЛЬНЫЕ ПОЛЯ:"
            header.title.font = UIFont.systemFont(ofSize: 12)
            header.title.textColor = UIColor.stSteelGrey
            header.topSpace.constant = 16
        }
        
        self.requiredFieldsSection.headerItem?.cellHeight = 46
        
        self.requiredFieldsSection.addItem(cellClass: STPostButtonsCell.self) { (cell, item) in
            
            let viewCell = cell as! STPostButtonsCell
            
            viewCell.offerButtonSelected(selected: true)
            viewCell.title.text = "Вид темы"
            
            viewCell.offer.reactive.tap.observe { [unowned viewCell] _ in
                
                viewCell.offerButtonSelected(selected: !viewCell.offer.isSelected)
                
                }.dispose(in: viewCell.bag)
            
            viewCell.search.reactive.tap.observe {[unowned viewCell] _ in
                
                viewCell.searchButtonSelected(selected: !viewCell.search.isSelected)
                
                }.dispose(in: viewCell.bag)
        }
        
        self.requiredFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldCell
            
            viewCell.title.text = "Название"
            viewCell.value.placeholder = "Введите название проекта"
            viewCell.value.reactive.text.observeNext { text in
                
                if var postObject = self.postObject {
                    
                    postObject.title = text ?? ""
                }
                
            }.dispose(in: viewCell.bag)
        }
        
        self.requiredFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldCell
            
            viewCell.title.text = "Описание"
            viewCell.value.placeholder = "Введите описание темы"
            
            viewCell.value.reactive.text.observeNext { text in
                
                if var postObject = self.postObject {
                    
                    postObject.details = text ?? ""
                }
                
            }.dispose(in: viewCell.bag)
        }
        
        self.requiredFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldCell
            
            viewCell.title.text = "Срок действия"
            viewCell.value.placeholder = "Выбирете срок действия"
        }
        
        // optional
        self.optionalFieldsSection.header(headerClass: STContactHeaderCell.self) { (view, section) in
            
            let header = view as! STContactHeaderCell
            
            header.title.text = "ДОПОЛНИТЕЛЬНЫЕ ПОЛЯ:"
            header.title.font = UIFont.systemFont(ofSize: 12)
            header.title.textColor = UIColor.stSteelGrey
            header.topSpace.constant = 16
        }
        
        self.optionalFieldsSection.headerItem?.cellHeight = 46
        
        self.optionalFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldCell
            
            viewCell.title.text = "Цена"
            viewCell.value.placeholder = "0.00 руб."
            viewCell.value.keyboardType = .numberPad
            
            viewCell.value.reactive.text.observeNext { text in
                
                if var postObject = self.postObject {
                    
                    postObject.price = Double(text ?? "") ?? 0.0
                }
                
            }.dispose(in: viewCell.bag)
        }
        
        self.optionalFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldCell
            
            viewCell.title.text = "Комментарий к цене"
            viewCell.value.placeholder = "Например: Торг возможен, ниже рыночной цены"
            
            viewCell.value.reactive.text.observeNext { text in
                
                if var postObject = self.postObject {
                    
                    postObject.priceDescription = text ?? ""
                }
                
            }.dispose(in: viewCell.bag)
        }
        
        self.optionalFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldCell
            
            viewCell.title.text = "Агентское вознаграждение"
            viewCell.value.placeholder = "Опишите профит для адресатов"
            
            viewCell.value.reactive.text.observeNext { text in
                
                if var postObject = self.postObject {
                    
                    postObject.profitDescription = text ?? ""
                }
                
            }.dispose(in: viewCell.bag)
        }
    }
}
