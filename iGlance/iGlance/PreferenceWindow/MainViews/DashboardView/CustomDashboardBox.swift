//
//  CustomDashboardBox.swift
//  iGlance
//
//  Created by Dominik on 19.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

/**
 * Custom NSBox class to display info in the dashboard.
 */
class CustomDashboardBox: NSBox {
    // MARK: -
    // MARK: Variable Overrides
    override var borderWidth: CGFloat {
        get {
            return 0.0
        }
        // swiftlint:disable:next unused_setter_value
        set {
            super.borderWidth = 0.0
        }
    }

    override var fillColor: NSColor {
        get {
            return ThemeManager.currentTheme().sidebarColor
        }
        // swiftlint:disable:next unused_setter_value
        set {
            super.fillColor = ThemeManager.currentTheme().sidebarColor
        }
    }

    override var cornerRadius: CGFloat {
        get {
            return 10
        }
        // swiftlint:disable:next unused_setter_value
        set {
            super.cornerRadius = 10
        }
    }

    // MARK: -
    // MARK: Function Overrides
    override func draw(_ dirtyRect: NSRect) {
        // update the color depending on the current theme
        self.fillColor = ThemeManager.currentTheme().sidebarColor

        super.draw(dirtyRect)
    }
}
