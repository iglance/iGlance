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
    // MARK: -
    // MARK: Protocol Implementations
    func update() {
        let temp: Double = AppDelegate.systemInfo.cpu.getCpuTemp()

        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'CpuTempMenuBarItem'")
            return
        }

        button.title = String(Int(temp)) + "°"
    }
}
