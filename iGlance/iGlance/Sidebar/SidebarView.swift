//
//  SidebarView.swift
//  iGlance
//
//  Created by Dominik on 16.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class SidebarView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // set the background color of the sidebar
        NSColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1).setFill()
        dirtyRect.fill()
    }
}
