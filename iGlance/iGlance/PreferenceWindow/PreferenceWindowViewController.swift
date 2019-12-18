//
//  ViewController.swift
//  iGlance
//
//  Created by Dominik on 15.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class PreferenceWindowViewController: NSViewController {

    var contentManagerViewController: ContentManagerViewController?

    @IBOutlet weak var dashboardButtonView: SidebarButtonView!
    @IBOutlet weak var cpuButtonView: SidebarButtonView!
    @IBOutlet weak var memoryButtonView: SidebarButtonView!
    @IBOutlet weak var networkButtonView: SidebarButtonView!
    @IBOutlet weak var fanButtonView: SidebarButtonView!
    @IBOutlet weak var batteryButtonView: SidebarButtonView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // set the storyboard ids of the main views of the buttons
        dashboardButtonView.mainViewStoryboardID = "DashboardStoryboardID"
        cpuButtonView.mainViewStoryboardID = "CpuStoryboardID"
        memoryButtonView.mainViewStoryboardID = "MemoryStoryboardID"
        networkButtonView.mainViewStoryboardID = "NetworkStoryboardID"
        fanButtonView.mainViewStoryboardID = "FanStoryboardID"
        batteryButtonView.mainViewStoryboardID = "BatteryStoryboardID"

        // set the on click events
        dashboardButtonView.onButtonClick(callback: displayViewOf(sender:))
        cpuButtonView.onButtonClick(callback: displayViewOf(sender:))
        memoryButtonView.onButtonClick(callback: displayViewOf(sender:))
        networkButtonView.onButtonClick(callback: displayViewOf(sender:))
        fanButtonView.onButtonClick(callback: displayViewOf(sender:))
        batteryButtonView.onButtonClick(callback: displayViewOf(sender:))
    }

    /**
     * Displays the main view of the given sidebar button view
     */
    private func displayViewOf(sender: SidebarButtonView) {
        if let viewController = storyboard?.instantiateController(withIdentifier: sender.mainViewStoryboardID!) {
            contentManagerViewController?.addNewViewController(viewController: ((viewController as? NSViewController)!))
        }
    }

    /**
     * Returns the content manager view controller which manages the main views of the preference window
     */
    func retrieveContentManagerController() -> ContentManagerViewController? {
        return self.contentManagerViewController
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.destinationController is ContentManagerViewController {
            contentManagerViewController = (segue.destinationController as? ContentManagerViewController)
        }
    }
}

/**
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
*/
