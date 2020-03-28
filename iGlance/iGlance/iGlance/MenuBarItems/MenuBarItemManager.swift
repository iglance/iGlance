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
