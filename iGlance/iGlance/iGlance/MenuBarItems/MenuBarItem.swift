//
//  MenuBarItem.swift
//  iGlance
//
//  Created by Dominik on 23.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa

protocol MenuBarItemProtocol {
    func update()
}

class MenuBarItemClass {
    let statusItem: NSStatusItem

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
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
}

typealias MenuBarItem = MenuBarItemClass & MenuBarItemProtocol
