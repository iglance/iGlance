//  Copyright (C) 2020  D0miH <https://github.com/D0miH> & Contributors <https://github.com/iglance/iGlance/graphs/contributors>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
        self.statusItem.isVisible = AppDelegate.userSettings.settings.cpu.showUsage
        if !self.statusItem.isVisible {
            return
        }
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
        // this allows us to draw the recent history when the user switches to the line graph
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
