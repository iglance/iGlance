//
//  MenuBarItem.swift
//  iGlance
//
//  Created by Dominik on 23.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa

protocol MenuBarItemProtocol {
    /**
     * Updates the menu bar item. This function is called during every update interval.
     */
    func update()
}

class MenuBarItemClass {
    let statusItem: NSStatusItem

    var menuItems: [NSMenuItem] = [] {
        didSet {
            // rebuild the menu if a new item was added
            buildMenu()
        }
    }

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // build the menu once
        buildMenu()
    }

    /**
     * Displays the menu bar item in the menu bar.
     */
    func show() {
        statusItem.isVisible = true
    }

    /**
     * Hides the menu bar item in the menu bar.
     */
    func hide() {
        statusItem.isVisible = false
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Creates the menu
     */
    private func buildMenu() {
        let menu = NSMenu()

        // add all custom menu items
        for item in menuItems {
            menu.addItem(item)
        }

        // add the settings button to the menu
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(AppDelegate.showMainWindow), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())

        // add the quit button to the menu
        menu.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        // set the menu for the status item
        self.statusItem.menu = menu
    }
}

typealias MenuBarItem = MenuBarItemClass & MenuBarItemProtocol
