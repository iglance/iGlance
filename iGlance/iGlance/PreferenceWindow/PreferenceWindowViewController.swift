//
//  ViewController.swift
//  iGlance
//
//  Created by Dominik on 15.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class PreferenceWindowViewController: NSViewController {

    struct SidebarItem {
        let label: String
        let storyboardID: String
    }

    @IBOutlet weak var sidebar: Sidebar!
    let sidebarItems: [SidebarItem] = [
        SidebarItem(label: "Dashboard", storyboardID: "DashboardStoryboardID"),
        SidebarItem(label: "CPU", storyboardID: "CpuStoryboardID"),
        SidebarItem(label: "Memory", storyboardID: "MemoryStoryboardID"),
        SidebarItem(label: "Network", storyboardID: "NetworkStoryboardID"),
        SidebarItem(label: "Fan", storyboardID: "FanStoryboardID"),
        SidebarItem(label: "Battery", storyboardID: "BatteryStoryboardID")
    ]

    var contentManagerViewController: ContentManagerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // add the current ViewController as the delegate and data source of the sidebar
        sidebar.delegate = self
        sidebar.dataSource = self
    }

    override func viewWillAppear() {
        // by default select the dashboard
        sidebar.selectRowIndexes(NSIndexSet(index: 0) as IndexSet, byExtendingSelection: false)
    }

    func onSidebarItemClick(itemIndex: Int) {
        let sidebarItem = sidebarItems[itemIndex]

        // show the view of the sidebar item
        displayViewOf(sidebarItem: sidebarItem)
    }

    private func displayViewOf(sidebarItem: SidebarItem) {
        if let viewController = storyboard?.instantiateController(withIdentifier: sidebarItem.storyboardID) {
            contentManagerViewController?.addNewViewController(viewController: (viewController as? NSViewController)!)
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.destinationController is ContentManagerViewController {
            contentManagerViewController = (segue.destinationController as? ContentManagerViewController)
        }
    }

    func retrieveContentManagerController() -> ContentManagerViewController? {
        return self.contentManagerViewController
    }
}

extension PreferenceWindowViewController: NSTableViewDataSource {
    /**
     * Returns the number of rows/items in the sidebar.
     */
    func numberOfRows(in tableView: NSTableView) -> Int {
        return sidebarItems.count
    }
}

extension PreferenceWindowViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let selectedSidebarItem = sidebarItems[row]

        // create the cell view
        if let cellView = tableView.makeView(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SidebarItemID"),
            owner: nil) as? NSTableCellView {

            // set the label and the image
            cellView.textField?.stringValue = selectedSidebarItem.label

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
