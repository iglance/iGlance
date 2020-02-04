//
//  CpuUsageMenuBarItem.swift
//  iGlance
//
//  Created by Dominik on 02.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class CpuUsageMenuBarItem: MenuBarItem {
    let barGraph: BarGraph

    override init() {
        self.barGraph = BarGraph(maxValue: 100)

        super.init()
    }

    // MARK: -
    // MARK: Protocol Implementations
    func update() {
        let usage = AppDelegate.systemInfo.cpu.getCpuUsage()

        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'CpuUsageMenuBarItem'")
            return
        }

        // get the total usage
        let totalUsage = usage.user + usage.system

        button.image = self.barGraph.getImage(currentValue: Double(totalUsage))
    }
}
