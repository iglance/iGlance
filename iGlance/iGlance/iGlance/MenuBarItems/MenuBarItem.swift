//  Copyright (C) 2020  D0miH <https://github.com/D0miH> & Contributors <https://github.com/iglance/iGlance/graphs/contributors>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Cocoa

protocol MenuBarItemProtocol {
    /**
     * Updates the menu bar item. This function is called during every update interval.
     */
    func update()
}

class MenuBarItemClass {
    let statusItem: NSStatusItem

    // define the height of the menu bar
    let menuBarHeight = 18
    let menubarHeightWithMargin = 16

    /// holds all the menu items for the menu. The menu is rebuild everytime an item is added or removed.
    var menuItems: [NSMenuItem] = [] {
        didSet {
            // rebuild the menu if a new item was added
            buildMenu()
        }
    }

    init() {
        // create the status item
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
        menu.addItem(NSMenuItem(title: "Show window", action: #selector(AppDelegate.showMainWindow), keyEquivalent: ","))

        // add the quit button to the menu
        menu.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        // set the menu for the status item
        self.statusItem.menu = menu
    }
}

typealias MenuBarItem = MenuBarItemClass & MenuBarItemProtocol
