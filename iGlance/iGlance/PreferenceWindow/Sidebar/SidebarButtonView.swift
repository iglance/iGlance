//
//  SidebarButton.swift
//  iGlance
//
//  Created by Dominik on 18.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class SidebarButtonView: NSView {

    public var mainViewStoryboardID: String?
    public var highlighted: Bool = false {
        didSet {
            self.needsDisplay = true
        }
    }

    private var hovered: Bool = false
    private var onClickCallback: ((_ sender: SidebarButtonView) -> Void)?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        // remove every current tracking area before adding a new one
        for trackingArea in self.trackingAreas {
            self.removeTrackingArea(trackingArea)
        }

        // create a custom tracking area to listen to mouse entered and mouse exited events
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        let trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }

    override func mouseDown(with event: NSEvent) {
        // call the callback if one is present
        if self.onClickCallback != nil {
            self.onClickCallback!(self)
        }
    }

    override func mouseEntered(with event: NSEvent) {
        self.hovered = true
        self.needsDisplay = true
    }

    override func mouseExited(with event: NSEvent) {
        self.hovered = false
        self.needsDisplay = true
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if highlighted {
            // highlight the button when selected
            ThemeManager.currentTheme().sidebarButtonHighlightColor.setFill()
            dirtyRect.fill()
        } else if hovered {
            // change the color of the button on hover
            ThemeManager.currentTheme().sidebarButtonHoverColor.setFill()
            dirtyRect.fill()
        }
    }

    public func onButtonClick(callback: @escaping (_ sender: SidebarButtonView) -> Void) {
        self.onClickCallback = callback
    }
}
