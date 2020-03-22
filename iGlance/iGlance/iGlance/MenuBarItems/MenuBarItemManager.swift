//
//  MenuBarItemManager.swift
//  iGlance
//
//  Created by Dominik on 23.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation

class MenuBarItemManager {
    /// The cpu temperature menu bar item
    let cpuTemp = CpuTempMenuBarItem()
    /// The cpu usage menu bar item
    let cpuUsage = CpuUsageMenuBarItem()
    // The memory usage menu bar item
    let memoryUsage = MemoryUsageMenuBarItem()
    // The fan menu bar item
    let fan = FanMenuBarItem()
    /// The network menu bar item
    let network = NetworkMenuBarItem()
    /// The battery menu bar item
    let battery = BatteryMenuBarItem()

    /// An array containing all the visible AND not visible menu bar items
    var menuBarItems: [MenuBarItem] = []

    init() {
        menuBarItems.append(cpuTemp)
        menuBarItems.append(cpuUsage)
        menuBarItems.append(memoryUsage)
        menuBarItems.append(fan)
        menuBarItems.append(network)
        menuBarItems.append(battery)
    }

    /**
     * Updates all menu bar items.
     */
    func updateMenuBarItems() {
        // iterate all menu bar items and call the update function for the visible ones
        for item in menuBarItems where item.statusItem.isVisible {
            item.update()
        }
    }
}
