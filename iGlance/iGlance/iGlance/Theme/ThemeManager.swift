//
//  ThemeManager.swift
//  iGlance
//
//  Created by Dominik on 17.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Foundation
import AppKit

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
