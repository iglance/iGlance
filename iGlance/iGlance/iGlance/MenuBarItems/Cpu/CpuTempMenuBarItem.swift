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

class CpuTempMenuBarItem: MenuBarItem {
    // MARK: -
    // MARK: Protocol Implementations

    /// the number of fans of the machine
    private let fanCount: Int

    override init() {
        // initially get the number of fans
        fanCount = AppDelegate.systemInfo.fan.getNumberOfFans()
        super.init()
    }

    func update() {
        self.statusItem.isVisible = AppDelegate.userSettings.settings.cpu.showTemperature
        if !self.statusItem.isVisible {
            return
        }
        updateMenuBarIcon()
    }

    // MARK: -
    // MARK: Private Functions

    private func updateMenuBarIcon() {
        let temp = Int(AppDelegate.systemInfo.cpu.getCpuTemp())

        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'CpuTempMenuBarItem'")
            return
        }
        if AppDelegate.userSettings.settings.cpu.showFanSpeed {
            // get the info for every fan
            var fanInfo: [(currentFanSpeed: Int, maxFanSpeed: Int, minFanSpeed: Int)] = []
            for id in 0..<fanCount {
                // get the fan speed for the current fan
                let currentFanSpeed = AppDelegate.systemInfo.fan.getCurrentFanSpeed(id: id)
                let maxFanSpeed = AppDelegate.systemInfo.fan.getMaxFanSpeed(id: id)
                let minFanSpeed = AppDelegate.systemInfo.fan.getMinFanSpeed(id: id)

                fanInfo.append((currentFanSpeed: currentFanSpeed, maxFanSpeed: maxFanSpeed, minFanSpeed: minFanSpeed))
            }
            button.image = createFanTempMenuBarImage(fanInfo: fanInfo, temp: temp)
        } else {
            button.image = createTempMenuBarImage(temp: temp)
        }
    }

    private func createTempMenuBarImage(temp: Int) -> NSImage? {
        // get the string that is going to be rendered
        let buttonString = createAttributedTempString(value: temp)
        // create an image for the menu bar item
        let imageWidth = CGFloat(30)
        let image = NSImage(size: NSSize(width: imageWidth, height: self.menubarHeightWithMargin))

        // lock the image to render the string
        image.lockFocus()

        // render the string
        buttonString.draw(at: NSPoint(x: image.size.width - buttonString.size().width, y: image.size.height / 2 - buttonString.size().height / 2))

        // unlock the focus of the image
        image.unlockFocus()

        return image
    }

    private func createFanTempMenuBarImage(fanInfo: [(currentFanSpeed: Int, maxFanSpeed: Int, minFanSpeed: Int)], temp: Int) -> NSImage? {
        var curMaxFanSpeed = 0
        for info in fanInfo {
            // get the fan speed for the current fan
            let fanSpeed = info.currentFanSpeed

            // if the rpm of the current fan is higher than the saved fan speed update it
            if curMaxFanSpeed < fanSpeed {
                curMaxFanSpeed = fanSpeed
            }
        }

        // get the string that is going to be rendered
        let tempString = createAttributedTempString(value: temp, isSingleLine: false)
        let fanString = createAttributedFanString(value: Int(curMaxFanSpeed))

        let tempStringSize = tempString.size()
        let fanStringSize = fanString.size()

        // create an image for the menu bar item
        let imageWidth = max(tempStringSize.width, fanStringSize.width)
        let image = NSImage(size: NSSize(width: imageWidth, height: self.menubarHeightWithMargin))

        // lock the image to render the string
        image.lockFocus()

        // render the string
        tempString.draw(at: NSPoint(x: 0, y: image.size.height - 9))
        fanString.draw(at: NSPoint(x: 0, y: -1))

        // unlock the focus of the image
        image.unlockFocus()

        return image
    }

    /**
     * Returns the attributed string of the current cpu temperature that can be rendered on an image.
     *
     *  - Parameter value: The given cpu temperature
     */
    private func createAttributedTempString(value: Int, isSingleLine: Bool = true) -> NSAttributedString {
        // create the attributed string
        let string = String(value) + "°"
        let attributes = createAttributes(isForSingleLine: isSingleLine)
        let attribString = NSMutableAttributedString(string: string, attributes: attributes)
        return attribString
    }

    /**
     * Returns the attributed string of the current cpu fan speed that can be rendered on an image.
     *
     *  - Parameter value: The given cpu fan speed
     */
    private func createAttributedFanString(value: Int) -> NSAttributedString {
        // create the attributed string
        let unit = AppDelegate.userSettings.settings.fan.showFanSpeedUnit ? "RMP" : ""
        let string = String(value) + unit
        let attributes = createAttributes(isForSingleLine: false)
        let attribString = NSMutableAttributedString(string: string, attributes: attributes)
        return attribString
    }

    private func createAttributes(isForSingleLine: Bool) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [.foregroundColor: ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black]
        if isForSingleLine {
            attributes[.font] = NSFont.systemFont(ofSize: 13)
        } else {
            attributes[.font] = NSFont.systemFont(ofSize: 9)
            attributes[.kern] = 1.2
        }
        return attributes
    }
}
