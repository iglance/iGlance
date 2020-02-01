//
//  MainWindowController.swift
//  iGlance
//
//  Created by Dominik on 18.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class MainWindowController: NSWindowController {
    // MARK: -
    // MARK: Outlets
    @IBOutlet private var mainWindow: NSWindow!

    override init(window: NSWindow?) {
        super.init(window: window)

        // show the dock icon if no menu bar item is visible
        // this prevents that the app is running but the user has no means to interact with the app
        if AppDelegate.menuBarItemManager.menuBarItems.contains(where: { $0.statusItem.isVisible == true }) {
            NSApp.setActivationPolicy(.regular)
            DDLogInfo("Dock icon is shown because no menu bar icon is visible")
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: -
    // MARK: Function Overrides
    override func windowDidLoad() {
        mainWindow.backgroundColor = ThemeManager.currentTheme().titlebarColor

        // set a callback to adjust the background color of the window if the theme changes
        ThemeManager.onThemeChange(self, #selector(updateMainWindow))

        // hide the zoom window button
        self.window?.standardWindowButton(.zoomButton)?.isHidden = true

        // center the window
        self.window?.center()
    }

    @objc
    private func updateMainWindow() {
        mainWindow.backgroundColor = ThemeManager.currentTheme().titlebarColor
        mainWindow.update()
    }
}
