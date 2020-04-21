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

    func update() {
        updateMenuBarIcon()
    }

    /**
     * Updates the icon of the menu bar item. This function is called during every update interval.
     *
     * - Parameter currentInterface: The name of the currently used interface.
     */
    func updateMenuBarIcon() {
        // get the button of the menu bar item
        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'NetworkMenuBarItem'")
            return
        }

        // get the sizes
        let (used, free) = DiskInfo.getFreeDiskSize()
        let usedSpace = convertToCorrectUnit(bytes: used)
        let freeSpace = convertToCorrectUnit(bytes: free)

        let menuBarImage = createMenuBarImage(up: usedSpace, down: freeSpace)

        // set the menu bar item image
        button.image = menuBarImage
    }

    // MARK: -
    // MARK: Private Functions

    /**
    *  Takes the amount of space in bytes and returns the correct value according to the unit as a string and the correct unit (KB, MB, GB, TB) as a string.
    *  If the given value of bytes is smaller than 1000 the function will return a value as is and unit of "B".
    *
    *  - Parameter bytes: The given number of bytes
    *
    *      Examples:
    *          512 Bytes -> (value: "512", unit: "B")
    *          5_000 Bytes -> (value: "5", unit: "KB")
    *          5_000_000 Bytes -> (value: "5", unit: "MB")
    *          5_000_000_000 Bytes -> (value: "5", unit: "GB")
    *
    */
    func convertToCorrectUnit(bytes: Int) -> (value: String, unit: String) {
        if bytes < 1000 {
            return (value: "\(bytes)", unit: "B")
        }
        let exp = Int(log2(Double(bytes)) / log2(1000.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(bytes) / pow(1000, Double(exp))

        return (value: String(format: "%.1f", number), unit: unit)
    }

    /**
     * Returns the image that can be rendered on the menu bar.
     */
    private func createMenuBarImage(up: (value: String, unit: String), down: (value: String, unit: String)) -> NSImage? {
        // create the attributed strings for the upload and download
        let freeString = self.crateAttributedString(text: "F:")
        let usedString = self.crateAttributedString(text: "U:")
        let freeSpaceString = self.createAttributedBandwidthString(value: down.value, unit: down.unit)
        let usedSpaceString = self.createAttributedBandwidthString(value: up.value, unit: up.unit)

        // create the menu bar image for the bandwidth.
        let textWidth = CGFloat(55) // this value was found by trail and error
        let iconWidth = CGFloat(12)
        let menuBarImage = NSImage(
            size: NSSize(
                width: textWidth + iconWidth,
                height: CGFloat(self.menuBarHeight)
            )
        )

        // focus the image to render the disk space values
        menuBarImage.lockFocus()

        freeString.draw(at: NSPoint(x: 0, y: menuBarImage.size.height - 9)) // F: is the first line
        usedString.draw(at: NSPoint(x: 0, y: -1))

        // draw the total space string
        let freeStringSize = freeSpaceString.size()
        freeSpaceString.draw(
            at: NSPoint(
                x: iconWidth + textWidth - freeStringSize.width,
                y: menuBarImage.size.height - 11 // this value was found by trail and error
            )
        )

        // draw the free space string
        let usedStringSize = usedSpaceString.size()
        // y value was found by trail and error
        usedSpaceString.draw(at: NSPoint(x: iconWidth + textWidth - usedStringSize.width, y: -2))

        // unlock the focus of drawing
        menuBarImage.unlockFocus()

        return menuBarImage
    }

    /**
     * Creates an attributed string that can be drawn on the menu bar image.
     */
    private func createAttributedBandwidthString(value: String, unit: String) -> NSAttributedString {
        // create the attributed string
        let attrString = NSMutableAttributedString(string: value + " " + unit)

        // define the font for the number value and the unit
        let font = NSFont.systemFont(ofSize: 9)

        // add the attributes
        attrString.addAttribute(.font, value: font, range: NSRange(location: 0, length: attrString.length - 1 - unit.count))
        attrString.addAttribute(.kern, value: 1.2, range: NSRange(location: 0, length: attrString.length - 1 - unit.count))
        attrString.addAttribute(.font, value: font, range: NSRange(location: attrString.length - unit.count, length: unit.count))
        let fontColor = ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black
        attrString.addAttribute(.foregroundColor, value: fontColor, range: NSRange(location: 0, length: attrString.length))

        return attrString
    }

    /**
     * Creates an attributed string that can be drawn on the menu bar image.
     */
    private func crateAttributedString(text: String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.font: NSFont.systemFont(ofSize: 9),
                NSAttributedString.Key.kern: 1.2,
                NSAttributedString.Key.foregroundColor: ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black
            ]
        )

        return attrString
    }
}
