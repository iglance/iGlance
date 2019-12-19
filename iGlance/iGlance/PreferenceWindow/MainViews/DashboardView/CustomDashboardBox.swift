//
//  CustomDashboardBox.swift
//  iGlance
//
//  Created by Dominik on 19.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class CustomDashboardBox: NSBox {

    override var borderWidth: CGFloat {
        get {
            return 0.0
        }
        set {
            super.borderWidth = 0.0
        }
    }

    override var fillColor: NSColor {
        get {
            return ThemeManager.currentTheme().sidebarColor
        }
        set {
            super.fillColor = ThemeManager.currentTheme().sidebarColor
        }
    }

    override var cornerRadius: CGFloat {
        get {
            return 10
        }
        set {
            super.cornerRadius = 10
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        // update the color depending on the current theme
        self.fillColor = ThemeManager.currentTheme().sidebarColor

        super.draw(dirtyRect)
    }
}
