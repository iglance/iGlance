//
//  Sidebar.swift
//  iGlance
//
//  Created by Dominik on 16.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class Sidebar: NSTableView {

    private func preventDeselection(clickEvent: NSEvent) {
        // if we don't click on a table row don't deselect the currently selected item
        let globalClickLocation = clickEvent.locationInWindow
        let localClickLocation = convert(globalClickLocation, from: nil)
        let clickedRow = row(at: localClickLocation)

        // if we clicked a valid row propagate the click event
        if clickedRow != -1 {
            super.mouseDown(with: clickEvent)
        }
    }

    override func mouseDown(with event: NSEvent) {
        preventDeselection(clickEvent: event)
    }
}
