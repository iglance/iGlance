//
//  SidebarButton.swift
//  iGlance
//
//  Created by Dominik on 18.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

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
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Returns the icon of the sidebar button.
     */
    private func getButtonIcon() -> NSImageView? {
        // get the stack view
        guard let stackView = self.subviews[0] as? NSStackView else {
            DDLogError("Could not cast subview to 'NSStackView'")
            return nil
        }
        // get the icon and the label
        guard let icon = stackView.subviews[0] as? NSImageView else {
            DDLogError("Could not cast the subview to 'NSImageView'")
            return nil
        }

        return icon
    }

    /**
     * Returns the label of the sidebar button.
     */
    private func getButtonLabel() -> NSTextField? {
        // get the stack view
        guard let stackView = self.subviews[0] as? NSStackView else {
            DDLogError("Could not cast subview to 'NSStackView'")
            return nil
        }
        // get the icon and the label
        guard let label = stackView.subviews[1] as? NSTextField else {
            DDLogError("Could not cast the subview to 'NSTextField'")
            return nil
        }

        return label
    }

    // MARK: -
    // MARK: Instance Functions

    /**
     * Changes the color of the icon and the label according to the currently selected theme.
     */
    func updateFontColor() {
        guard let label = getButtonLabel(), let icon = getButtonIcon() else {
            DDLogError("Could not retrieve label or the icon of the sidebar button")
            return
        }

        // when current theme is light set the font color to a light color on active sidebar buttons
        if highlighted && ThemeManager.currentTheme() == Theme.lightTheme {
            // change the color of the label
            label.textColor = Theme.darkTheme.fontColor
            // change the image according to the theme
            let color = Theme.darkTheme.fontColor
            icon.image = icon.image?.tint(color: color)
            return
        }

        // change the color of the label
        label.textColor = ThemeManager.currentTheme().fontColor
        // change the image according to the theme
        let color = ThemeManager.currentTheme().fontColor
        icon.image = icon.image?.tint(color: color)
    }

    /**
     * Sets the function which is called when the button is clicked.
     */
    func onButtonClick(callback: @escaping (_ sender: SidebarButtonView) -> Void) {
        self.onClickCallback = callback
    }
}
