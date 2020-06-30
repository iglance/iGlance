//
//  MainWindowDelegate.swift
//  iGlance
//
//  Created by Dominik on 30.06.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class MainWindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // hide the dock icon of the app if at least one menu bar item is visible.
        if AppDelegate.menuBarItemManager.menuBarItems.contains(where: { $0.statusItem.isVisible == true }) {
            NSApp.setActivationPolicy(.accessory)
            DDLogInfo("Hide dock icon")
        }
    }
}
