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

class DiskUsageMenuBarItem: MenuBarItem {
    // MARK: -
    // MARK: Private Variables
    private var freeString = NSAttributedString()
    private var usedString = NSAttributedString()
    private var iconWidth = CGFloat(12)

    override init() {
        super.init()
        freeString = createAttributedString(text: "F:")
        usedString = createAttributedString(text: "U:")
        iconWidth = max(freeString.size().width, usedString.size().width)
    }

    func update() {
        self.statusItem.isVisible = AppDelegate.userSettings.settings.disk.showDiskUsage
        if !self.statusItem.isVisible {
            return
        }

        updateMenuBarIcon()
    }

    /**
     * Updates the icon of the menu bar item. This function is called during every update interval.
     */
    func updateMenuBarIcon() {
        // get the button of the menu bar item
        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'NetworkMenuBarItem'")
            return
        }

        // get the sizes
        let (used, free) = DiskInfo.getFreeDiskUsageInfo()
        let usedSpace = convertToCorrectUnit(bytes: used)
        let freeSpace = convertToCorrectUnit(bytes: free)

        let menuBarImage = createMenuBarImage(used: usedSpace, free: freeSpace)

        // set the menu bar item image
        button.image = menuBarImage
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Returns the image that can be rendered on the menu bar.
     */
    private func createMenuBarImage(used: (value: Double, unit: SystemInfo.ByteUnit), free: (value: Double, unit: SystemInfo.ByteUnit)) -> NSImage? {
        // create the attributed strings for the upload and download
        let usedValueString = used.unit > .Gigabyte ? String(format: "%.2f", free.value) : String(format: "%.1f", free.value)
        let freeValueString = free.unit > .Gigabyte ?String(format: "%.2f", used.value) : String(format: "%.1f", used.value)
        let freeSpaceString = self.createAttributedString(text: "\(usedValueString) \(free.unit.rawValue)")
        let usedSpaceString = self.createAttributedString(text: "\(freeValueString) \(used.unit.rawValue)")

        let freeStringSize = freeSpaceString.size()
        let usedStringSize = usedSpaceString.size()

        // create the menu bar image for the disk usage.
        let textWidth = max(freeStringSize.width, usedStringSize.width)
        let menuBarImage = NSImage(
            size: NSSize(
                width: iconWidth + textWidth,
                height: self.menuBarHeight
            )
        )

        // focus the image to render the disk space values
        menuBarImage.lockFocus()

        freeString.draw(at: NSPoint(x: 0, y: menuBarImage.size.height - 9)) // F: is the first line
        usedString.draw(at: NSPoint(x: 0, y: -1))

        // draw the total space string

        freeSpaceString.draw(
            at: NSPoint(
                x: iconWidth + textWidth - freeStringSize.width,
                y: menuBarImage.size.height - 9 // this value was found by trail and error
            )
        )

        // draw the free space string

        // y value was found by trail and error
        usedSpaceString.draw(at: NSPoint(x: iconWidth + textWidth - usedStringSize.width, y: -1))

        // unlock the focus of drawing
        menuBarImage.unlockFocus()

        return menuBarImage
    }

    /**
     * Creates an attributed string that can be drawn on the menu bar image.
     */
    private func createAttributedString(text: String) -> NSAttributedString {
        func blackOrWhite() -> NSColor {
            var returnColor = NSColor.black
            if #available(macOS 11.0, *) {
                returnColor = NSColor.white
            }
            return returnColor
        }

        let attrString = NSMutableAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.font: NSFont.systemFont(ofSize: 9),
                NSAttributedString.Key.kern: 1.2,
                NSAttributedString.Key.foregroundColor: ThemeManager.isDarkTheme() ? NSColor.white : blackOrWhite()
            ]
        )

        return attrString
    }
}
