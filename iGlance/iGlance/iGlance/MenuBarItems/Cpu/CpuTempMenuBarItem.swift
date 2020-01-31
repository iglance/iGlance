//
//  CpuTempMenuBarItem.swift
//  iGlance
//
//  Created by Dominik on 23.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class CpuTempMenuBarItem: MenuBarItem {
    override init() {
        super.init()

        // set the menu for the status item
        self.statusItem.menu = buildMenu()
    }

    // MARK: -
    // MARK: Protocol Implementations
    func update() {
        let temp: Double = SystemInfo.cpu.getCpuTemp(unit: .celius)

        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'CpuTempMenuBarItem'")
            return
        }

        // TODO: add fahrenheit
        button.title = String(Int(temp)) + "°C"
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Returns the menu for the menu bar item.
     */
    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        // add the settings button
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(AppDelegate.showMainWindow), keyEquivalent: "s"))
        menu.addItem(NSMenuItem.separator())

        // add the quit button
        menu.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        return menu
    }
}
