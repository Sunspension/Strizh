//
//  TableViewDataSource.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 19/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource {
    
    var sections: [CollectionSection] = []
    
    func item(by: IndexPath) -> CollectionSectionItem {
        
        return sections[by.section].items[by.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].items.count 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        item.indexPath = indexPath
        
        if let cellStyle = item.cellStyle {
            
            let cell = UITableViewCell(style: cellStyle, reuseIdentifier: String(describing: cellStyle.self))
            item.bindingAction?(cell, item)
            return cell;
        }
        
        if let cellClass = item.cellClass {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath)
            item.bindingAction?(cell, item)
            return cell
        }
        
        if let nibClass = item.nibClass {
            
            if let cell = Bundle.main.loadNibNamed(String(describing: nibClass), owner: self, options: nil)!.last as? UITableViewCell {
                
                item.bindingAction?(cell, item)
                return cell
            }
        }
        
        let cell =  UITableViewCell()
        item.bindingAction?(cell, item)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.sections[section].title
    }
}
