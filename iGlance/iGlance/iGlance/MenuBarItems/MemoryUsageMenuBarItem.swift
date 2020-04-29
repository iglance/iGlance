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

class MemoryUsageMenuBarItem: MenuBarItem {
    override init() {
        let maxMemValue = Double(AppDelegate.systemInfo.memory.getTotalMemorySize())
        self.barGraph = BarGraph(maxValue: maxMemValue)
        let graphWidth = AppDelegate.userSettings.settings.memory.usageLineGraphWidth
        self.lineGraph = LineGraph(maxValue: maxMemValue, imageWidth: graphWidth)

        super.init()

        // add the menu entries
        menuItems.append(contentsOf: [appMemoryMenuEntry, activeMemoryMenuEntry, compressedMemoryMenuEntry, wiredMemoryMenuEntry, freeMemoryMenuEntry, NSMenuItem.separator()])
    }

    // MARK: -
    // MARK: Instance Variables

    let barGraph: BarGraph
    let lineGraph: LineGraph

    // MARK: -
    // MARK: Private Variables

    private let appMemoryMenuEntry = NSMenuItem(title: "App Memory: \t N/A", action: nil, keyEquivalent: "")
    private let activeMemoryMenuEntry = NSMenuItem(title: "Active: \t\t\t N/A", action: nil, keyEquivalent: "")
    private let compressedMemoryMenuEntry = NSMenuItem(title: "Compressed: \t N/A", action: nil, keyEquivalent: "")
    private let wiredMemoryMenuEntry = NSMenuItem(title: "Wired: \t\t\t N/A", action: nil, keyEquivalent: "")
    private let freeMemoryMenuEntry = NSMenuItem(title: "Free: \t\t\t N/A", action: nil, keyEquivalent: "")

    // MARK: -
    // MARK: Protocol Implementations

    func update() {
        self.statusItem.isVisible = AppDelegate.userSettings.settings.memory.showUsage
        if !self.statusItem.isVisible {
            return
        }
        let usage = AppDelegate.systemInfo.memory.getMemoryUsage()
        updateMenuBarIcon(memoryUsage: usage)
        updateMenuBarMenu(memoryUsage: usage)
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Updates the icon of the menu bar item. This function is called during every update interval.
     */
    private func updateMenuBarIcon(memoryUsage: (free: Double, active: Double, inactive: Double, wired: Double, compressed: Double, appMemory: Double)) {
        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'MemoryUsageMenuBarItem'")
            return
        }

        let totalUsage = Double(memoryUsage.active + memoryUsage.compressed + memoryUsage.wired)

        // get all the necessary settings
        let graphColor = AppDelegate.userSettings.settings.memory.usageGraphColor.nsColor
        let gradientColor: NSColor? = AppDelegate.userSettings.settings.memory.colorGradientSettings.useGradient ? AppDelegate.userSettings.settings.memory.colorGradientSettings.secondaryColor.nsColor : nil
        let drawBorder = AppDelegate.userSettings.settings.memory.showUsageGraphBorder

        if AppDelegate.userSettings.settings.memory.usageGraphKind == .bar {
            button.image = self.barGraph.getImage(currentValue: totalUsage, graphColor: graphColor, drawBorder: drawBorder, gradientColor: gradientColor)
        } else {
            button.image = self.lineGraph.getImage(currentValue: totalUsage, graphColor: graphColor, drawBorder: drawBorder, gradientColor: gradientColor)
        }

        // add the value to the line graph history
        // this allows us to draw the resent history when the user switches to the line graph
        self.lineGraph.addValue(value: totalUsage)
    }

    /**
     * Updates the menu of the menu bar item. This function is called during every update interval.
     */
    private func updateMenuBarMenu(memoryUsage: (free: Double, active: Double, inactive: Double, wired: Double, compressed: Double, appMemory: Double)) {
        appMemoryMenuEntry.title = "App Memory: \t \(String(format: "%.2f", memoryUsage.appMemory)) GB"
        activeMemoryMenuEntry.title = "Active: \t\t\t \(String(format: "%.2f", memoryUsage.active)) GB"
        wiredMemoryMenuEntry.title = "Wired: \t\t\t \(String(format: "%.2f", memoryUsage.wired)) GB"
        compressedMemoryMenuEntry.title = "Compressed: \t \(String(format: "%.2f", memoryUsage.compressed)) GB"
        freeMemoryMenuEntry.title = "Free: \t\t\t \(String(format: "%.2f", memoryUsage.free)) GB"
    }
}
