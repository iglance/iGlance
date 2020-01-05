//
//  SidebarButton.swift
//  iGlance
//
//  Created by Dominik on 18.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class SidebarButtonView: NSView {

    // MARK: -
    // MARK: Public Instance Variables
    public var mainViewStoryboardID: String?
    public var highlighted: Bool = false {
        didSet {
            self.needsDisplay = true
        }
    }

    // MARK: -
    // MARK: Private Instance Variables
    private var hovered: Bool = false
    private var onClickCallback: ((_ sender: SidebarButtonView) -> Void)?

    // MARK: -
    // MARK: Function Overrides
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
        // if the mouse entered the button set the hovered variable to true
        self.hovered = true
        // set the needsDisplay variable to force a re-draw
        self.needsDisplay = true
    }

    override func mouseExited(with event: NSEvent) {
        // if the mouse exited the button set the hovered variable to false
        self.hovered = false
        // set the needsDisplay variable to force a re-draw
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

    // MARK: -
    // MARK: Instance Functions

    /**
     * Sets the function which is called when the button is clicked.
     */
    public func onButtonClick(callback: @escaping (_ sender: SidebarButtonView) -> Void) {
        self.onClickCallback = callback
    }
}
