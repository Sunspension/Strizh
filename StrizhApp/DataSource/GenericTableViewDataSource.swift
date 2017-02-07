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
    
    var bindingAction: ((_ cell: TableViewCell, _ item: GenericCollectionSectionItem<TableItem>) -> Void)
    
    var cellClass: AnyClass?
    
    var nibClass: AnyClass?
    
    
    init(nibClass: AnyClass,
         binding: @escaping (_ cell: TableViewCell, _ item: GenericCollectionSectionItem<TableItem>) -> Void) {
        
        self.nibClass = nibClass
        self.bindingAction = binding
        
        super.init()
    }
    
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
        
        if let cellClass = self.cellClass {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: cellClass),
                                                     for: indexPath) as! TableViewCell
            self.bindingAction(cell, item)
            return cell
        }
        
        if let nibClass = self.nibClass {
            
            let cell = Bundle.main.loadNibNamed(String(describing: nibClass), owner: self, options: nil)!.last as! TableViewCell
            
            self.bindingAction(cell, item)
            return cell
        }
        
        let cell =  UITableViewCell() as! TableViewCell
        self.bindingAction(cell, item)
        
        return cell;
    }
}
