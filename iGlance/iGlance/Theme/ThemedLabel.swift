//
//  ThemedLabel.swift
//  iGlance
//
//  Created by Dominik on 09.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa

class ThemedLabel: NSTextField {
    override func draw(_ dirtyRect: NSRect) {
        // text color has to be set before we draw the rect
        self.textColor = ThemeManager.currentTheme().fontColor

        super.draw(dirtyRect)
    }
}
