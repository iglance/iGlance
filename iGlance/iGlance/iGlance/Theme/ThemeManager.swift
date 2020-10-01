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
import AppKit
import CocoaLumberjack

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

    var fontColor: NSColor {
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
    /**
     * Indicates whether the theme of the os is dark.
     *
     * - Returns: True if dark mode is enabled. Returns false otherwise.
     */
    static func isDarkTheme() -> Bool {
        var darkTheme = false

        // Special thanks to @ruiaureliano <https://github.com/ruiaureliano> for investigating this issue and providing
        // a fix: https://github.com/ruiaureliano/macOS-Appearance/blob/master/Appearance/Source/AppDelegate.swift
        if #available(OSX 10.15, *) {
            let appearanceDesc = NSApplication.shared.effectiveAppearance.debugDescription.lowercased()
            darkTheme = appearanceDesc.contains("dark")
        } else if #available(OSX 10.14, *) {
            if let interfaceStyle = UserDefaults.standard.object(forKey: "AppleInterfaceStyle") as? String {
                darkTheme = interfaceStyle.lowercased().contains("dark")
            }
        }

        return darkTheme
    }

    /**
     * Returns the current theme of the app.
     */
    static func currentTheme() -> Theme {
        if isDarkTheme() {
            return Theme.darkTheme
        } else {
            return Theme.lightTheme
        }
    }

    private init() {}

    static func onThemeChange(_ observer: Any, _ selector: Selector) {
        // add a callback to change the logo depending on the current theme
        DistributedNotificationCenter.default.addObserver(
            observer,
            selector: selector,
            name: .AppleInterfaceThemeChangedNotification,
            object: nil
        )
    }
}
