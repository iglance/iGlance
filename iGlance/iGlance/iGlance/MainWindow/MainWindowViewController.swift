//
//  ViewController.swift
//  iGlance
//
//  Created by Dominik on 15.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class MainWindowViewController: NSViewController {
    // MARK: -
    // MARK: Instance Variables
    var contentManagerViewController: ContentManagerViewController?
    var sidebarViewController: SidebarViewController?

    // MARK: -
    // MARK: Function Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // add the on click event handler to the buttons of the sidebar
        sidebarViewController?.addOnClickEventHandler(eventHandler: displayViewOf(sender:))
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // get the view controller of the main view and the sidebar
        if segue.destinationController is ContentManagerViewController {
            contentManagerViewController = (segue.destinationController as? ContentManagerViewController)
        } else if segue.destinationController is SidebarViewController {
            sidebarViewController = (segue.destinationController as? SidebarViewController)
        }
    }

    override func viewWillAppear() {
        // show the dock icon of the app
        NSApp.setActivationPolicy(.regular)
    }

    override func viewWillDisappear() {
        // hide the dock icon of the app if at least one menu bar item is visible.
        if AppDelegate.menuBarItemManager.menuBarItems.contains(where: { $0.statusItem.isVisible == true }) {
            NSApp.setActivationPolicy(.accessory)
            DDLogInfo("Hide dock icon")
        }
    }

    // MARK: -
    // MARK: Private Functions
    /**
     * Displays the main view of the given sidebar button view.
     * This function is called when the sidebar button is clicked.
     */
    private func displayViewOf(sender: SidebarButtonView) {
        if let viewController = storyboard?.instantiateController(withIdentifier: sender.mainViewStoryboardID!) {
            contentManagerViewController?.addNewViewController(viewController: ((viewController as? NSViewController)!))
        }
    }
}
