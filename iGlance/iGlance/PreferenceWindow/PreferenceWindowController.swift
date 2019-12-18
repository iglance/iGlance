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
    }
}
