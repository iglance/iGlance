//
//  Extensions.swift
//  iGlance
//
//  Created by Dominik on 05.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import Cocoa
import CocoaLumberjack

extension Notification.Name {
    /** The notification name for os theme changes. */
    static let AppleInterfaceThemeChangedNotification = Notification.Name("AppleInterfaceThemeChangedNotification")

    /** Notification name to kill the launcher application */
    static let killLauncher = Notification.Name("killLauncher")
}

extension NSColor {
    /**
     * Returns the corresponding NSColor to the given hex color string.
     *
     * - Parameter hex: The given hex string
     * - Parameter alpha: The alpha value of the color. This value should be between 0.0 and 1.0
     *
     * - Returns: The color as a NSColor
     */
    static func colorFrom(hex: String, alpha: Float? = nil) -> NSColor {
        var colorString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        // remove the hastag if present
        if colorString.hasPrefix("#") {
            colorString.remove(at: colorString.startIndex)
        }

        // if the character count is not correct return the default color gray
        if colorString.count != 6 {
            return NSColor.blue
        }

        var rgbValue: UInt64 = 0
        Scanner(string: colorString).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        return NSColor(
            red: red,
            green: green,
            blue: blue,
            alpha: CGFloat(alpha ?? 1.0)
        )
    }
}

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        // copy the current instance of the image
        guard let image = self.copy() as? NSImage else {
            DDLogError("Could not copy the image")
            return self
        }

        // lock the copied image
        image.lockFocus()

        // set the fill color
        color.set()

        // fill the image with the color
        let imageRect = NSRect(origin: NSPoint.zero, size: image.size)
        imageRect.fill(using: .sourceAtop)

        // unlock the image instance
        image.unlockFocus()

        DDLogInfo("Tinted the image with the name '\(self.name() ?? "no name available")'")

        return image
    }
}
