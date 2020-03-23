//
//  SidebarViewController.swift
//  iGlance
//
//  Created by Dominik on 18.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class SidebarViewController: NSViewController {
    // MARK: -
    // MARK: Struct Definitions

    /**
     * Structure to save the ID of a NSView of a sidebar button, its corresponding
     * main view storyboard ID which is displayed in the container view when the button is clicked
     * and the name of the icon of the sidebar button.
     */
    struct SidebarButtonIDs {
        let buttonViewID: String
        let mainViewStoryboardID: String
        let buttonIconID: String
    }

    // MARK: -
    // MARK: Outlets

    @IBOutlet private var logoImage: NSImageView!
    @IBOutlet private var sidebarButtonStackView: NSStackView!
    @IBOutlet private var preferenceButton: NSButton!

    // MARK: -
    // MARK: Private Variables

    /** An array containing the IDs to all the sidebar buttons and their corresponding main view storyboard IDs*/
    private var sidebarButtonViewIDs: [SidebarButtonIDs] = [
        SidebarButtonIDs(buttonViewID: "DashboardButtonView", mainViewStoryboardID: "DashboardStoryboardID", buttonIconID: "DashboardMenuIcon"),
        SidebarButtonIDs(buttonViewID: "CpuButtonView", mainViewStoryboardID: "CpuStoryboardID", buttonIconID: "CpuMenuIcon"),
        SidebarButtonIDs(buttonViewID: "MemoryButtonView", mainViewStoryboardID: "MemoryStoryboardID", buttonIconID: "MemoryMenuIcon"),
        SidebarButtonIDs(buttonViewID: "NetworkButtonView", mainViewStoryboardID: "NetworkStoryboardID", buttonIconID: "NetworkMenuIcon"),
        SidebarButtonIDs(buttonViewID: "FanButtonView", mainViewStoryboardID: "FanStoryboardID", buttonIconID: "FanMenuIcon"),
        SidebarButtonIDs(buttonViewID: "BatteryButtonView", mainViewStoryboardID: "BatteryStoryboardID", buttonIconID: "BatteryMenuIcon")
    ]
    private var preferenceModalViewController: PreferenceModalViewController?

    // MARK: -
    // MARK: Function Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // set the storyboard ids of the main views and the the icon ids of the buttons
        for identifier in sidebarButtonViewIDs {
            let buttonView = getSidebarButtonWith(identifier: identifier.buttonViewID)!

            // set the story board ids
            buttonView.mainViewStoryboardID = identifier.mainViewStoryboardID

            // set the icon ids
            buttonView.iconName = identifier.buttonIconID
        }

        // on startup select the dashboard
        getSidebarButtonWith(identifier: sidebarButtonViewIDs[0].buttonViewID)?.highlighted = true

        // add a callback to change the logo depending on the current theme
        ThemeManager.onThemeChange(self, #selector(onThemeChange))

        // call the theme change callback once on startup to set the correct colors
        onThemeChange()
    }

    // MARK: -
    // MARK: Actions

    @IBAction private func preferenceButtonClick(_ sender: NSButton) {
        // instantiate the storyboard (bundle = nil indicates the apps main bundle)
        let storyboard = NSStoryboard(name: "PreferenceWindow", bundle: nil)

        // instantiate the view controller
        guard let preferenceModalViewController = storyboard.instantiateController(withIdentifier: "PreferenceModalViewController") as? PreferenceModalViewController else {
            DDLogError("Could not instantiate 'PreferenceModalViewController'")
            return
        }

        // get the parent window
        guard let parentWindow = self.view.window else {
            DDLogError("Could not unwrap the parent window")
            return
        }

        preferenceModalViewController.showModal(parentWindow: parentWindow)
    }

    // MARK: -
    // MARK: Instance Functions

    /**
     * Adds a on click event handler to each sidebar button view.
     * This event handler is called when one of the buttons is pressed.
     *
     * - Parameter eventHandler: The given callback function which is called when the button is clicked.
     */
    func addOnClickEventHandler(eventHandler: @escaping (_ sender: SidebarButtonView) -> Void) {
        // create a proxy event handler to trigger the onButtonClick function in this class
        let proxyEventHandler = { (_ sender: SidebarButtonView) -> Void in
            self.onButtonClick(sender)
            eventHandler(sender)
        }

        // set the on click events
        for identifier in sidebarButtonViewIDs {
            getSidebarButtonWith(identifier: identifier.buttonViewID)?.onButtonClick(callback: proxyEventHandler)
        }
    }

    /**
     * Called when a button in the sidebar is clicked.
     *
     * - Parameter sender: The sidebar button view which was clicked.
     */
    func onButtonClick(_ sender: SidebarButtonView) {
        for identifier in sidebarButtonViewIDs {
            guard let buttonView = getSidebarButtonWith(identifier: identifier.buttonViewID) else {
                DDLogError("Could not get the sidebar button view with the identifier \(identifier.buttonViewID)")
                return
            }

            if buttonView.identifier == sender.identifier {
                buttonView.highlighted = true
                buttonView.updateFontColor()
            } else if buttonView.highlighted {
                buttonView.highlighted = false
                buttonView.updateFontColor()
            }
        }
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Callback which is called when the theme is changed.
     */
    @objc
    private func onThemeChange() {
        // change the sidebar logo
        changeSidebarLogo()

        // change the preferences logo
        changePreferencesLogo()

        // update the sidebar button font color
        for identifier in sidebarButtonViewIDs {
            getSidebarButtonWith(identifier: identifier.buttonViewID)?.updateFontColor()
        }
    }

    /**
     * Depending on the current theme the white or black iGlance logo is selected.
     */
    private func changeSidebarLogo() {
        if ThemeManager.isDarkTheme() {
            self.logoImage.image = NSImage(named: "iGlance_logo_white")
        } else {
            self.logoImage.image = NSImage(named: "iGlance_logo_black")
        }
    }

    /**
     * Depending on the current theme the grey or blue preference icon is selected.
     */
    private func changePreferencesLogo() {
        if ThemeManager.isDarkTheme() {
            self.preferenceButton.image = self.preferenceButton.image?.tint(color: ThemeManager.currentTheme().fontColor)
        } else {
            self.preferenceButton.image = self.preferenceButton.image?.tint(color: ThemeManager.currentTheme().fontColor)
        }
    }

    /**
     * Gets the view instance of the button with the given identifier.
     * - Returns: The SidebarButtonView instance. If no button with the given identifier was found nil is returned.
     */
    private func getSidebarButtonWith(identifier: String) -> SidebarButtonView? {
        for subView in sidebarButtonStackView.subviews where subView.identifier?.rawValue == identifier {
            return (subView as? SidebarButtonView)!
        }

        return nil
    }
}
