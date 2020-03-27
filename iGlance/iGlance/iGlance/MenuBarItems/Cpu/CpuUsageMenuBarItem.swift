//
//  CpuUsageMenuBarItem.swift
//  iGlance
//
//  Created by Dominik on 02.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack

class CpuUsageMenuBarItem: MenuBarItem {
    // MARK: -
    // MARK: Public  Variables
    let barGraph: BarGraph
    let lineGraph: LineGraph

    // MARK: -
    // MARK: Private Variables
    private let userUsageMenuEntry = NSMenuItem(title: "User: \t N/A", action: nil, keyEquivalent: "")
    private let systemUsageMenuEntry = NSMenuItem(title: "System: \t N/A", action: nil, keyEquivalent: "")
    private let idleUsageMenuEntry = NSMenuItem(title: "Idle: \t N/A", action: nil, keyEquivalent: "")

    override init() {
        self.barGraph = BarGraph(maxValue: 100)
        let graphWidth = AppDelegate.userSettings.settings.cpu.usageLineGraphWidth
        self.lineGraph = LineGraph(maxValue: 100, imageWidth: graphWidth)

        super.init()

        // add the menu entrys
        menuItems.append(contentsOf: [userUsageMenuEntry, systemUsageMenuEntry, idleUsageMenuEntry, NSMenuItem.separator()])
    }

    // MARK: -
    // MARK: Protocol Implementations

    func update() {
        let usage = AppDelegate.systemInfo.cpu.getCpuUsage()
        updateMenuBarIcon(usage: usage)
        updateMenuBarMenu(usage: usage)
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Updates the icon of the menu bar item. This function is called during every update interval.
     *
     *  - Parameter usage: The current usage of the cpu.
     */
    private func updateMenuBarIcon(usage: (system: Int, user: Int, idle: Int, nice: Int)) {
        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'CpuUsageMenuBarItem'")
            return
        }

        // get the total usage
        let totalUsage = usage.user + usage.system

        // get all the necessary settings
        let graphColor = AppDelegate.userSettings.settings.cpu.usageGraphColor.nsColor
        let gradientColor: NSColor? = AppDelegate.userSettings.settings.cpu.colorGradientSettings.useGradient ? AppDelegate.userSettings.settings.cpu.colorGradientSettings.secondaryColor.nsColor : nil
        let drawBorder = AppDelegate.userSettings.settings.cpu.showUsageGraphBorder

        if AppDelegate.userSettings.settings.cpu.usageGraphKind == .bar {
            button.image = self.barGraph.getImage(currentValue: Double(totalUsage), graphColor: graphColor, drawBorder: drawBorder, gradientColor: gradientColor)
        } else {
            button.image = self.lineGraph.getImage(currentValue: Double(totalUsage), graphColor: graphColor, drawBorder: drawBorder, gradientColor: gradientColor)
        }

        // add the value to the line graph history
        // this allows us to draw the resent history when the user switches to the line graph
        self.lineGraph.addValue(value: Double(totalUsage))
    }

    /**
     * Updates the menu of the menu bar item. This function is called during every update interval.
     *
     *  - Parameter usage: The current usage of the cpu.
     */
    private func updateMenuBarMenu(usage: (system: Int, user: Int, idle: Int, nice: Int)) {
        userUsageMenuEntry.title = "User: \t \(usage.user)%"
        systemUsageMenuEntry.title = "System: \t \(usage.system)%"
        idleUsageMenuEntry.title = "Idle: \t \(usage.idle)%"
    }
}
