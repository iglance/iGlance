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
import CocoaLumberjack

class SidebarButtonView: NSView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        self.wantsLayer = true
        self.layer?.cornerRadius = 8
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        self.layer?.cornerRadius = 8
    }

    // MARK: -
    // MARK: Public Instance Variables
    var mainViewStoryboardID: String?
    var iconName: String?
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

    /// - Tag: buttonIcon
    private var buttonIcon: NSImage?

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

    /**
     * This function is needed in order to find the accessibility identifier in the ui tests.
     */
    override func isAccessibilityElement() -> Bool {
        true
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Sets the [buttonIcon](x-source-tag://buttonIcon) variable to the correctly tinted button image.
     *
     * - Parameter color: The color in which the button icon should be tinted.
     */
    private func setButtonIcon(color: NSColor) {
        // get the stack view
        guard let stackView = self.subviews[0] as? NSStackView else {
            DDLogError("Could not cast subview to 'NSStackView'")
            return
        }

        // set the icon
        guard let imageName = self.iconName else {
            DDLogError("Sidebar icon name of sidebar button to view \(String(describing: mainViewStoryboardID)) is nil")
            return
        }

        // get the image view
        guard let imageView = stackView.subviews[0] as? NSImageView else {
            DDLogError("Could not cast the subview to 'NSImageView'")
            return
        }

        if self.buttonIcon == nil {
            // if the icon is not set yet, set it
            self.buttonIcon = NSImage(named: imageName)
        }

        imageView.image = self.buttonIcon?.tint(color: color)
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
        guard let label = getButtonLabel() else {
            DDLogError("Could not retrieve label or the icon of the sidebar button")
            return
        }

        // get the font color
        var fontColor = ThemeManager.currentTheme().fontColor
        let fontColorHighlighted = ThemeManager.currentTheme().fontHighlightColor
        if highlighted {
            // change the font color
            fontColor = fontColorHighlighted
        }

        // set the color of the icon
        setButtonIcon(color: fontColor)
        // set the color of the label
        label.textColor = fontColor
    }

    /**
     * Sets the function which is called when the button is clicked.
     */
    func onButtonClick(callback: @escaping (_ sender: SidebarButtonView) -> Void) {
        self.onClickCallback = callback
    }
}
