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
        let usedSpace = DiskInfo.convertToCorrectUnit(bytes: used)
        let freeSpace = DiskInfo.convertToCorrectUnit(bytes: free)

        let menuBarImage = createMenuBarImage(up: usedSpace, down: freeSpace)

        // set the menu bar item image
        button.image = menuBarImage
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Returns the image that can be rendered on the menu bar.
     */
    private func createMenuBarImage(up: (value: String, unit: String), down: (value: String, unit: String)) -> NSImage? {
        // create the attributed strings for the upload and download
        let freeSpaceString = self.createAttributedString(text: "\(down.value) \(down.unit)")
        let usedSpaceString = self.createAttributedString(text: "\(up.value) \(up.unit)")

        let freeStringSize = freeSpaceString.size()
        let usedStringSize = usedSpaceString.size()

        // create the menu bar image for the disk usage.
        let textWidth = max(freeStringSize.width, usedStringSize.width)
        let menuBarImage = NSImage(
            size: NSSize(
                width: iconWidth + textWidth,
                height: CGFloat(self.menuBarHeight)
            )
        )

        // focus the image to render the disk space values
        menuBarImage.lockFocus()

        freeString.draw(at: NSPoint(x: 0, y: menuBarImage.size.height - 10)) // F: is the first line
        usedString.draw(at: NSPoint(x: 0, y: -2))

        // draw the total space string

        freeSpaceString.draw(
            at: NSPoint(
                x: iconWidth + textWidth - freeStringSize.width,
                y: menuBarImage.size.height - 11 // this value was found by trail and error
            )
        )

        // draw the free space string

        // y value was found by trail and error
        usedSpaceString.draw(at: NSPoint(x: iconWidth + textWidth - usedStringSize.width, y: -2))

        // unlock the focus of drawing
        menuBarImage.unlockFocus()

        return menuBarImage
    }

    /**
     * Creates an attributed string that can be drawn on the menu bar image.
     */
    private func createAttributedString(text: String) -> NSAttributedString {
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
