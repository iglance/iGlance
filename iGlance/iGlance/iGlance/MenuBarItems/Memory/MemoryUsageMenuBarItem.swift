//
//  MemoryUsageMenuBarItem.swift
//  iGlance
//
//  Created by Dominik on 12.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class MemoryUsageMenuBarItem: MenuBarItem {
    let barGraph: BarGraph
    let lineGraph: LineGraph

    override init() {
        self.barGraph = BarGraph(maxValue: 100)
        let graphWidth = AppDelegate.userSettings.settings.memory.usageLineGraphWidth
        self.lineGraph = LineGraph(maxValue: 100, imageWidth: graphWidth)

        super.init()
    }

    // MARK: -
    // MARK: Protocol Implementations
    func update() {
        let usage = AppDelegate.systemInfo.memory.getMemoryUsage()

        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'CpuUsageMenuBarItem'")
            return
        }

        let totalUsage = usage.active + usage.compressed + usage.wired

        let graphColor = AppDelegate.userSettings.settings.memory.usageGraphColor.nsColor
        if AppDelegate.userSettings.settings.memory.usageGraphKind == .bar {
            button.image = self.barGraph.getImage(currentValue: Double(totalUsage), graphColor: graphColor)
        } else {
            button.image = self.lineGraph.getImage(currentValue: Double(totalUsage), graphColor: graphColor)
        }

        // add the value to the line graph history
        // this allows us to draw the resent history when the user switches to the line graph
        self.lineGraph.addValue(value: Double(totalUsage))
    }
}
