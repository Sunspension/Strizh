//
//  GenericTableViewDataSource.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class GenericTableViewDataSource<TableViewCell: UITableViewCell, TableItem: Any>: NSObject, UITableViewDataSource {

    var sections: [GenericCollectionSection<TableItem>] = []
    
    subscript(index: Int) -> GenericCollectionSection<TableItem> {
        
        get {
            
            return sections[index]
        }
        
        set {
            
            sections.insert(newValue, at: index)
        }
    }
    
    var bindingAction: ((_ cell: TableViewCell, _ item: GenericCollectionSectionItem<TableItem>) -> Void)
    
    var cellClass: AnyClass
    
    
    init(cellClass: AnyClass,
         binding: @escaping (_ cell: TableViewCell, _ item: GenericCollectionSectionItem<TableItem>) -> Void) {
        
        self.cellClass = cellClass
        self.bindingAction = binding
        
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].items.count 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.sections[indexPath.section].items[indexPath.row]
        item.indexPath = indexPath
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: cellClass),
                                                 for: indexPath) as! TableViewCell
        self.bindingAction(cell, item)
        return cell
    }
    
    func item(by: IndexPath) -> GenericCollectionSectionItem<TableItem> {
        
        return sections[by.section].items[by.row]
    }
}
