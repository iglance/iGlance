//
//  MainWindowController.swift
//  iGlance
//
//  Created by Dominik on 18.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    // MARK: -
    // MARK: Outlets
    @IBOutlet private var mainWindow: NSWindow!

    // MARK: -
    // MARK: Function Overrides
    override func windowDidLoad() {
        mainWindow.backgroundColor = ThemeManager.currentTheme().titlebarColor

        // set a callback to adjust the background color of the window if the theme changes
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMainWindow),
            name: .AppleInterfaceThemeChangedNotification,
            object: nil
        )

        // hide the zoom window button
        self.window?.standardWindowButton(.zoomButton)?.isHidden = true
    }

    @objc
    private func updateMainWindow() {
        mainWindow.backgroundColor = ThemeManager.currentTheme().titlebarColor
        mainWindow.update()
    }
}
