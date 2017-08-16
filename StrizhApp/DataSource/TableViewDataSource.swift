//
//  TableViewDataSource.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 19/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var sections: [TableSection] = []
    
    var onDidSelectRowAtIndexPath: ((_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) -> Void)?
    
    var onDidDeselectRowAtIndexPath: ((_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) -> Void)?
    
    var onDidScrollUp: (() -> Void)?
    
    subscript(index: Int) -> TableSection {
        
        get {
            
            return sections[index]
        }
        
        set {
            
            sections.insert(newValue, at: index)
        }
    }
    
    
    func item(by: IndexPath) -> TableSectionItem {
        
        return sections[by.section].items[by.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard self.sections.count > 0 else {
            
            return 0
        }
        
        return self.sections[section].items.count 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.sections[indexPath.section].items[indexPath.row]
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
        
        let cell =  UITableViewCell()
        item.bindingAction?(cell, item)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let item = self.item(by: indexPath)
        return item.cellHeight ?? UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.onDidSelectRowAtIndexPath?(tableView, indexPath, self.item(by: indexPath))
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        self.onDidDeselectRowAtIndexPath?(tableView, indexPath, self.item(by: indexPath))
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.sections[section].title
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 else {
            
            return
        }
        
        self.onDidScrollUp?()
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
        
        guard self.sections.count > 0, let header = self.sections[section].headerItem else {
            
            return 0.01
        }
        
        return header.cellHeight ?? UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        guard self.sections.count > 0, let footer = self.sections[section].footerItem else {
            
            return 0.01
        }
        
        return footer.cellHeight ?? 0.01
    }
}
