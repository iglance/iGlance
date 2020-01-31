//
//  MenuBarItemManager.swift
//  iGlance
//
//  Created by Dominik on 23.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation

class MenuBarItemManager {
    var menuBarItems: [MenuBarItem] = []

    init() {
        menuBarItems.append(CpuTempMenuBarItem())
    }

    /**
     * Updates all menu bar items.
     */
    func updateMenuBarItems() {
        // iterate all menu bar items and call the update function
        for item in menuBarItems {
            item.update()
        }
    }
}
