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
        let maxMemValue = AppDelegate.systemInfo.memory.getTotalMemorySize()
        self.barGraph = BarGraph(maxValue: Double(maxMemValue))
        let graphWidth = AppDelegate.userSettings.settings.memory.usageLineGraphWidth
        self.lineGraph = LineGraph(maxValue: 100, imageWidth: graphWidth)

        super.init()
    }

    // MARK: -
    // MARK: Protocol Implementations
    func update() {
        let usage = AppDelegate.systemInfo.memory.getMemoryUsage()

        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'MemoryUsageMenuBarItem'")
            return
        }

        let totalUsage = usage.active + usage.compressed + usage.wired

        // get all the necessary settings
        let graphColor = AppDelegate.userSettings.settings.memory.usageGraphColor.nsColor
        let gradientColor: NSColor? = AppDelegate.userSettings.settings.memory.colorGradientSettings.useGradient ? AppDelegate.userSettings.settings.memory.colorGradientSettings.secondaryColor.nsColor : nil
        let drawBorder = AppDelegate.userSettings.settings.memory.showUsageGraphBorder

        if AppDelegate.userSettings.settings.memory.usageGraphKind == .bar {
            button.image = self.barGraph.getImage(currentValue: Double(totalUsage), graphColor: graphColor, drawBorder: drawBorder, gradientColor: gradientColor)
        } else {
            button.image = self.lineGraph.getImage(currentValue: Double(totalUsage), graphColor: graphColor, drawBorder: drawBorder, gradientColor: gradientColor)
        }

        // add the value to the line graph history
        // this allows us to draw the resent history when the user switches to the line graph
        self.lineGraph.addValue(value: Double(totalUsage))
    }
}
