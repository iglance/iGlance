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

class FanMenuBarItem: MenuBarItem {
    // MARK: -
    // MARK: Structure Definitions

    /// - Tag: FanMenu
    struct FanMenu {
        var minFanSpeed: NSMenuItem
        var maxFanSpeed: NSMenuItem
        var currentFanSpeed: NSMenuItem
    }

    /// the number of fans of the machine
    private let fanCount: Int
    /// Array that stores all the info of each fan
    private var fanMenus: [FanMenu] = []

    override init() {
        // initially get the number of fans
        fanCount = AppDelegate.systemInfo.fan.getNumberOfFans()

        // call the super initializer
        super.init()

        // get the fan menus
        fanMenus = getFanMenus()

        let entries = createMenuItems()
        // add all the entries at once to prevent rebuilding the menu multiple times
        self.menuItems.append(contentsOf: entries)
    }

    // MARK: -
    // MARK: Protocol Implementations

    func update() {
        self.statusItem.isVisible = AppDelegate.userSettings.settings.fan.showFanSpeed
        if !self.statusItem.isVisible {
            return
        }
        // get the info for every fan
        var fanInfo: [(currentFanSpeed: Int, maxFanSpeed: Int, minFanSpeed: Int)] = []
        for id in 0..<fanCount {
            // get the fan speed for the current fan
            let currentFanSpeed = AppDelegate.systemInfo.fan.getCurrentFanSpeed(id: id)
            let maxFanSpeed = AppDelegate.systemInfo.fan.getMaxFanSpeed(id: id)
            let minFanSpeed = AppDelegate.systemInfo.fan.getMinFanSpeed(id: id)

            fanInfo.append((currentFanSpeed: currentFanSpeed, maxFanSpeed: maxFanSpeed, minFanSpeed: minFanSpeed))
        }

        updateMenuBarIcon(fanInfo: fanInfo)
        updateMenuBarMenu(fanInfo: fanInfo)
    }


    // MARK: -
    // MARK: Private Functions

    /**
    * Updates the icon of the menu bar item. This function is called during every update interval.
    */
    private func updateMenuBarIcon(fanInfo: [(currentFanSpeed: Int, maxFanSpeed: Int, minFanSpeed: Int)]) {
        var curMaxFanSpeed = 0
        for info in fanInfo {
            // get the fan speed for the current fan
            let fanSpeed = info.currentFanSpeed

            // if the rpm of the current fan is higher than the saved fan speed update it
            if curMaxFanSpeed < fanSpeed {
                curMaxFanSpeed = fanSpeed
            }
        }

        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'FanMenuBarItem'")
            return
        }

        // get the string that is going to be rendered
        let buttonString = createAttributedRPMString(value: Int(curMaxFanSpeed), unit: AppDelegate.userSettings.settings.fan.showFanSpeedUnit)

        // create an image for the menu bar item
        let imageWidth = AppDelegate.userSettings.settings.fan.showFanSpeedUnit ? 65 : 40
        let image = NSImage(size: NSSize(width: imageWidth, height: self.menubarHeightWithMargin))

        // lock the image to render the string
        image.lockFocus()

        // render the string
        buttonString.draw(at: NSPoint(x: image.size.width - buttonString.size().width, y: image.size.height / 2 - buttonString.size().height / 2))

        // unlock the focus of the image
        image.unlockFocus()

        button.image = image
    }

    /**
    * Updates the menu of the menu bar item. This function is called during every update interval.
    */
    private func updateMenuBarMenu(fanInfo: [(currentFanSpeed: Int, maxFanSpeed: Int, minFanSpeed: Int)]) {
        // iterate all fans
        for (id, info) in fanInfo.enumerated() {
            // get the current fan speed
            let currentFanSpeed = info.currentFanSpeed

            // get the current fan menu
            let currentFanMenu = fanMenus[id]

            // update the current fan speed entry
            currentFanMenu.currentFanSpeed.title = "Current:\t\t \(currentFanSpeed) RPM"
        }
    }

    /**
     * Returns the attributed string of the current fan RPM that can be rendered on an image.
     *
     *  - Parameter value: The given rpm of the fan
     *  - Parameter unit: Whether the string should contain the unit 'RPM' at the end
     */
    private func createAttributedRPMString(value: Int, unit: Bool) -> NSAttributedString {
        // create the attributed string
        let string = String(value) + " " + (unit ? "RPM" : "")

        // define the attributes
        let attributes = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13),
            NSAttributedString.Key.foregroundColor: ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black
        ]

        // create the string
        let attribString = NSAttributedString(string: string, attributes: attributes)

        return attribString
    }

    /**
     * Creates all the entries of the menu for the fan menu bar item and returns them in an array.
     */
    private func createMenuItems() -> [NSMenuItem] {
        // array for all the menu entries
        var entries: [NSMenuItem] = []

        // get the min and max fan speed for each fan
        for id in 0..<fanCount {
            // create the entries
            let heading = NSMenuItem(title: "Fan \(id + 1)", action: nil, keyEquivalent: "")
            let minEntry = fanMenus[id].minFanSpeed
            let maxEntry = fanMenus[id].maxFanSpeed
            let currentEntry = fanMenus[id].currentFanSpeed
            let separator = NSMenuItem.separator()

            entries.append(contentsOf: [heading, minEntry, maxEntry, currentEntry, separator])
        }

        return entries
    }

    // MARK: -
    // MARK: Static Functions
    /**
     * Returns an array with the [FanMenu](x-source-tag://FanMenu) for every fan.
     */
    private func getFanMenus() -> [FanMenu] {
        var menus: [FanMenu] = []

        for id in 0..<fanCount {
            // get the min, max and current fan speed for the current fan
            let minFanSpeed = AppDelegate.systemInfo.fan.getMinFanSpeed(id: id)
            let maxFanSpeed = AppDelegate.systemInfo.fan.getMaxFanSpeed(id: id)
            let currentFanSpeed = AppDelegate.systemInfo.fan.getCurrentFanSpeed(id: id)

            // create the menu entries
            let minEntry = NSMenuItem(title: "Min: \t\t \(minFanSpeed) RPM", action: nil, keyEquivalent: "")
            let maxEntry = NSMenuItem(title: "Max: \t\t \(maxFanSpeed) RPM", action: nil, keyEquivalent: "")
            let currentEntry = NSMenuItem(title: "Current:\t\t \(currentFanSpeed) RPM", action: nil, keyEquivalent: "")

            menus.append(FanMenu(minFanSpeed: minEntry, maxFanSpeed: maxEntry, currentFanSpeed: currentEntry))
        }

        return menus
    }
}
