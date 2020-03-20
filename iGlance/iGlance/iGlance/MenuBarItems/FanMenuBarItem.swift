//
//  FanMenuBarItem.swift
//  iGlance
//
//  Created by Dominik on 18.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack

class FanMenuBarItem: MenuBarItem {
    private let fanCount: Int

    override init() {
        fanCount = AppDelegate.systemInfo.fan.getNumberOfFans()

        super.init()
    }

    // MARK: -
    // MARK: Protocol Implementations
    func update() {
        var curMaxFanSpeed = 0
        for id in 0..<fanCount {
            // get the fan speed for the current fan
            let fanSpeed = AppDelegate.systemInfo.fan.getCurrentFanSpeed(id: id)

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
     * Returns the attributed string of the current fan RPM that can be rendered on an image.
     *
     *  - Parameter value: The given rpm of the fan
     *  - Parameter unit: Whether the string should contain the unit 'RPM' at the end
     */
    private func createAttributedRPMString(value: Int, unit: Bool) -> NSAttributedString {
        // create the attributed string
        let string = String(value) + " " + (unit ? "RPM" : "")
        let attribString = NSMutableAttributedString(string: string)

        // define the font
        let font = NSFont(name: "Apple SD Gothic Neo", size: 14)

        attribString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        let fontColor = ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black
        attribString.addAttribute(.foregroundColor, value: fontColor, range: NSRange(location: 0, length: string.count))

        return attribString
    }
}
