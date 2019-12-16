//
//  ViewController.swift
//  iGlance
//
//  Created by Dominik on 15.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var sidebar: Sidebar!
    let sidebarItems: [String] = ["Dashboard", "CPU", "Memory", "Network"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make window transparent
        view.window?.isOpaque = false
        view.window?.backgroundColor = NSColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 0)

        // add the current ViewController as the delegate and data source of the sidebar
        sidebar.delegate = self
        sidebar.dataSource = self
        
        // by default select the dashboard
        sidebar.selectRowIndexes(NSIndexSet(index: 0) as IndexSet, byExtendingSelection: false)
    }
    
    func onSidebarItemClick(itemIndex: Int) {
        print(sidebarItems[itemIndex])
    }
}

extension ViewController: NSTableViewDataSource {
    /**
     * Returns the number of rows/items in the sidebar.
     */
    func numberOfRows(in tableView: NSTableView) -> Int {
        return sidebarItems.count
    }
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let selectedSidebarItem = sidebarItems[row]
        
        // create the cell view
        if let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SidebarItemID"), owner: nil) as? NSTableCellView {
            // set the label and the image
            cellView.textField?.stringValue = selectedSidebarItem
            
            cellView.imageView?.image = NSImage(named: NSImage.actionTemplateName)
            
            // return the created cell view
            return cellView
        } else {
            return nil
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.onSidebarItemClick(itemIndex: sidebar.selectedRow)
    }
}

