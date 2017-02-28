//
//  GenericTableViewDataSource.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class GenericTableViewDataSource<TableViewCell: UITableViewCell, TableItem: Any>: NSObject, UITableViewDataSource, UITableViewDelegate {

    var sections: [GenericCollectionSection<TableItem>] = []
    
    var onDidSelectRowAtIndexPath: ((_ tableView: UITableView, _ indexPath: IndexPath, _ item: GenericCollectionSectionItem<TableItem>) -> Void)?
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.onDidSelectRowAtIndexPath?(tableView, indexPath, self.item(by: indexPath))
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let section = self.sections[section]
        
        if let header = section.headerItem {
            
            if let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: header.headerFooterClass.self)) {
                
                header.bindingAction?(view, header)
                return view
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let section = self.sections[section]
        
        if let footer = section.footerItem {
            
            if let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: footer.headerFooterClass.self)) {
                
                footer.bindingAction?(view, footer)
                return view
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard let header = self.sections[section].headerItem else {
            
            return 0.01
        }
        
        return header.cellHeight ?? 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        guard let footer = self.sections[section].footerItem else {
            
            return 0.01
        }
        
        return footer.cellHeight ?? 0.01
    }
    
    func item(by: IndexPath) -> GenericCollectionSectionItem<TableItem> {
        
        return sections[by.section].items[by.row]
    }
}
