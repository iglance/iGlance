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
    var mainViewStoryboardID: String?
    var highlighted: Bool = false {
        didSet {
            // if highlighted was changed force a redraw
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

        // update the color of the label
        updateFontColor()
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Changes the color of the icon and the label according to the currently selected theme.
     */
    private func updateFontColor() {
        // get the stack view
        let stackView = self.subviews[0] as! NSStackView
        // get the icon and the label
        let icon = stackView.subviews[0] as! NSImageView
        let label = stackView.subviews[1] as! NSTextField

        if highlighted && ThemeManager.currentTheme() == Theme.lightTheme {
            // if the light theme is active, set the font and the icon of the highlighted button
            // to the colors of the dark theme to have more contrast
            label.textColor = Theme.darkTheme.fontColor
            icon.image = icon.image?.tint(color: Theme.darkTheme.fontColor)
            return
        }

        // change the color of the label
        label.textColor = ThemeManager.currentTheme().fontColor
        // change the image according to the theme
        let color = ThemeManager.currentTheme().fontColor
        icon.image = icon.image?.tint(color: color)
    }

    // MARK: -
    // MARK: Instance Functions

    /**
     * Sets the function which is called when the button is clicked.
     */
    func onButtonClick(callback: @escaping (_ sender: SidebarButtonView) -> Void) {
        self.onClickCallback = callback
    }
}
