//
//  PreferenceWindowView.swift
//  iGlance
//
//  Created by Dominik on 06.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa

class PreferenceView: NSView {
    /**
     * Prevent dragging of the window
     */
    override var mouseDownCanMoveWindow: Bool {
        return false
    }
}
