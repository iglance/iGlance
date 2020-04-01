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

    func update() {
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

        // get the string that is going to be rendered
        let buttonString = createAttributedTempString(value: temp)

        // create an image for the menu bar item
        let imageWidth = 30
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
     * Returns the attributed string of the current cpu temperature that can be rendered on an image.
     *
     *  - Parameter value: The given cpu temperature
     */
    private func createAttributedTempString(value: Int) -> NSAttributedString {
        // create the attributed string
        let string = String(value) + "°"
        let attribString = NSMutableAttributedString(string: string)

        // define the font
        let font = NSFont.systemFont(ofSize: 13)

        attribString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        let fontColor = ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black
        attribString.addAttribute(.foregroundColor, value: fontColor, range: NSRange(location: 0, length: string.count))

        return attribString
    }
}
