//
//  ThemeManager.swift
//  iGlance
//
//  Created by Dominik on 17.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Foundation
import AppKit

extension NSColor {
    /**
     * Returns the corresponding NSColor to the given hex color string.
     *
     * - Parameter hex: The given hex string
     * - Parameter alpha: The alpha value of the color. This value should be between 0.0 and 1.0
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

enum Theme: Int {
    case darkTheme, lightTheme

    var titlebarColor: NSColor {
        switch self {
        case .darkTheme:
            return NSColor.colorFrom(hex: "#222326")
        default:
            return NSColor.colorFrom(hex: "#5069B3")
        }
    }

    var sidebarColor: NSColor {
        switch self {
        case .darkTheme:
            return NSColor.colorFrom(hex: "#303440")
        case .lightTheme:
            return NSColor.colorFrom(hex: "#D9D9D9")
        }
    }

    var sidebarFontColor: NSColor {
        switch self {
        case .darkTheme:
            return NSColor.colorFrom(hex: "#D9D9D9")
        case .lightTheme:
            return NSColor.colorFrom(hex: "#5069B3")
        }
    }

    var sidebarButtonHoverColor: NSColor {
        switch self {
        case .darkTheme:
            return NSColor.colorFrom(hex: "#3D4766")
        case .lightTheme:
            return NSColor.colorFrom(hex: "#A3B0D9")
        }
    }

    var sidebarButtonHighlightColor: NSColor {
        switch self {
        case .darkTheme:
            return NSColor.colorFrom(hex: "#3D5499")
        case .lightTheme:
            return NSColor.colorFrom(hex: "#6B7DB3")
        }
    }

}

class ThemeManager {

    public static func isDarkTheme() -> Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") != nil
    }

    static func currentTheme() -> Theme {
        if isDarkTheme() {
            return Theme.darkTheme
        } else {
            return Theme.lightTheme
        }
    }
}
