//
//  MenuBarItemManager.swift
//  iGlance
//
//  Created by Dominik on 23.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation

class MenuBarItemManager {
    /// The menu bar item for the cpu temperature
    let cpuTemp = CpuTempMenuBarItem()

    /// An array containing all the visible AND not visible menu bar items
    var menuBarItems: [MenuBarItem] = []

    init() {
        menuBarItems.append(cpuTemp)
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
