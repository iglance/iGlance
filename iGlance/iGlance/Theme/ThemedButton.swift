//
//  ThemedButtonCell.swift
//  iGlance
//
//  Created by Dominik on 09.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa

class ThemedButton: NSButton {
    override func draw(_ dirtyRect: NSRect) {
        // create a attributed string to change the font color of the button
        let attributedTitle = NSAttributedString(string: self.title, attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().sidebarFontColor])
        self.attributedTitle = attributedTitle

        super.draw(dirtyRect)
    }
}
