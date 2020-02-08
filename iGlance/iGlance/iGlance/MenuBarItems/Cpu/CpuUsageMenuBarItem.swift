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
    let lineGraph: LineGraph

    override init() {
        self.barGraph = BarGraph(maxValue: 100)
        self.lineGraph = LineGraph(width: 50)

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

        if AppDelegate.userSettings.settings.cpu.usageGraphKind == .bar {
            let barColor = AppDelegate.userSettings.settings.cpu.usageBarColor
            button.image = self.barGraph.getImage(currentValue: Double(totalUsage), graphColor: barColor.nsColor)
        } else {
            button.image = self.lineGraph.getImage(currentValue: Double(totalUsage), graphColor: NSColor.green)
        }
    }
}
