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
        let graphWidth = AppDelegate.userSettings.settings.cpu.usageLineGraphWidth
        self.lineGraph = LineGraph(maxValue: 100, imageWidth: graphWidth)

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

        let graphColor = AppDelegate.userSettings.settings.cpu.usageGraphColor.nsColor
        if AppDelegate.userSettings.settings.cpu.usageGraphKind == .bar {
            button.image = self.barGraph.getImage(currentValue: Double(totalUsage), graphColor: graphColor)
        } else {
            button.image = self.lineGraph.getImage(currentValue: Double(totalUsage), graphColor: graphColor)
        }

        // add the value to the line graph history
        // this allows us to draw the resent history when the user switches to the line graph
        self.lineGraph.addValue(value: Double(totalUsage))
    }
}