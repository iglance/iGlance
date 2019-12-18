//
//  PreferenceWindowController.swift
//  iGlance
//
//  Created by Dominik on 18.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class PreferenceWindowController: NSWindowController {

    @IBOutlet weak var mainWindow: NSWindow!

    override func windowDidLoad() {
        mainWindow.backgroundColor = ThemeManager.currentTheme().titlebarColor

        // set a callback to adjust the background color of the window if the theme changes
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMainWindow),
            name: .AppleInterfaceThemeChangedNotification,
            object: nil
        )
    }

    @objc func updateMainWindow() {
        mainWindow.backgroundColor = ThemeManager.currentTheme().titlebarColor
        mainWindow.update()
    }
}

extension Notification.Name {
    static let AppleInterfaceThemeChangedNotification = Notification.Name("AppleInterfaceThemeChangedNotification")
}
