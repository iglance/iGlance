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

class ThemedButton: NSButton {
    override func draw(_ dirtyRect: NSRect) {
        // create a attributed string to change the font color of the button
        let attributedTitle = NSAttributedString(string: self.title, attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().fontColor])
        self.attributedTitle = attributedTitle

        super.draw(dirtyRect)
    }
}
