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

import Cocoa

/**
 * Custom NSBox class to display info in the dashboard.
 */
class CustomDashboardBox: NSBox {
    // MARK: -
    // MARK: Variable Overrides
    override var borderWidth: CGFloat {
        get {
            0.0
        }
        // swiftlint:disable:next unused_setter_value
        set {
            super.borderWidth = 0.0
        }
    }

    override var fillColor: NSColor {
        get {
            ThemeManager.currentTheme().accentColor
        }
        // swiftlint:disable:next unused_setter_value
        set {
            super.fillColor = ThemeManager.currentTheme().accentColor
        }
    }

    override var cornerRadius: CGFloat {
        get {
            10
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
        self.fillColor = ThemeManager.currentTheme().accentColor

        super.draw(dirtyRect)
    }
}
