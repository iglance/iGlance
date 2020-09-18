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

    var mainViewBackgroundColor: NSColor {
        switch self {
        case .darkTheme:
            return #colorLiteral(red: 0.1294117647, green: 0.1568627451, blue: 0.1960784314, alpha: 1)
        case .lightTheme:
            return NSColor.colorFrom(hex: "FFFFFF")
        }
    }

    var accentColor: NSColor {
        switch self {
        case .darkTheme:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.08)
        case .lightTheme:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.08)
        }
    }

    var fontColor: NSColor {
        switch self {
        case .darkTheme:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }

    var fontHighlightColor: NSColor {
        switch self {
        case .darkTheme:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }

    var sidebarButtonHoverColor: NSColor {
        switch self {
        case .darkTheme:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.05)
        case .lightTheme:
            return #colorLiteral(red: 0.1137254902, green: 0.4901960784, blue: 1, alpha: 0.25)
        }
    }

    var sidebarButtonHighlightColor: NSColor {
        switch self {
        case .darkTheme:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.15)
        case .lightTheme:
            return #colorLiteral(red: 0.1137254902, green: 0.4901960784, blue: 1, alpha: 0.75)
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
        UserDefaults.standard.string(forKey: "AppleInterfaceStyle") != nil
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
