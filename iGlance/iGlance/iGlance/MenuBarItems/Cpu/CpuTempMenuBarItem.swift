//
//  CpuTempMenuBarItem.swift
//  iGlance
//
//  Created by Dominik on 23.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack

class CpuTempMenuBarItem: MenuBarItem {
    // MARK: -
    // MARK: Protocol Implementations
    func update() {
        let temp = Int(AppDelegate.systemInfo.cpu.getCpuTemp())

        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'CpuTempMenuBarItem'")
            return
        }

        // get the string that is going to be rendered
        let buttonString = createAttributedTempString(value: temp)

        // create an image for the menu bar item
        let imageWidth = 30
        let image = NSImage(size: NSSize(width: imageWidth, height: 18))

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
        let font = NSFont(name: "Apple SD Gothic Neo", size: 14)!

        attribString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        let fontColor = ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black
        attribString.addAttribute(.foregroundColor, value: fontColor, range: NSRange(location: 0, length: string.count))

        return attribString
    }
}
