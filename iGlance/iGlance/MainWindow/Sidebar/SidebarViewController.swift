//
//  SidebarViewController.swift
//  iGlance
//
//  Created by Dominik on 18.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa
import os.log

class SidebarViewController: NSViewController {
    // MARK: -
    // MARK: Struct Definitions

    /**
     * Structure to save the ID of a NSView of a sidebar button and its corresponding
     * main view storyboard ID which is displayed in the container view when the button is clicked.
     */
    struct SidebarButtonIDs {
        let buttonViewID: String
        let mainViewStoryboardID: String
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
        SidebarButtonIDs(buttonViewID: "DashboardButtonView", mainViewStoryboardID: "DashboardStoryboardID"),
        SidebarButtonIDs(buttonViewID: "CpuButtonView", mainViewStoryboardID: "CpuStoryboardID"),
        SidebarButtonIDs(buttonViewID: "MemoryButtonView", mainViewStoryboardID: "MemoryStoryboardID"),
        SidebarButtonIDs(buttonViewID: "NetworkButtonView", mainViewStoryboardID: "NetworkStoryboardID"),
        SidebarButtonIDs(buttonViewID: "FanButtonView", mainViewStoryboardID: "FanStoryboardID"),
        SidebarButtonIDs(buttonViewID: "BatteryButtonView", mainViewStoryboardID: "BatteryStoryboardID")
    ]
    private var preferenceModalViewController: PreferenceModalViewController?

    // MARK: -
    // MARK: Function Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // set the storyboard ids of the main views of the buttons
        for identifier in sidebarButtonViewIDs {
            let buttonView = getSidebarButtonWith(identifier: identifier.buttonViewID)!

            buttonView.mainViewStoryboardID = identifier.mainViewStoryboardID
        }

        // on startup select the dashboard
        getSidebarButtonWith(identifier: sidebarButtonViewIDs[0].buttonViewID)?.highlighted = true

        // add a callback to change the logo depending on the current theme
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(onThemeChange),
            name: .AppleInterfaceThemeChangedNotification,
            object: nil
        )

        // add the correct logo image at startup
        changeSidebarLogo()
    }

    // MARK: -
    // MARK: Actions

    @IBAction private func preferenceButtonClick(_ sender: NSButton) {
        // instantiate the view controller
        guard let preferenceModalViewController = self.storyboard?.instantiateController(identifier: "PreferenceModalViewController") as PreferenceModalViewController? else {
            os_log("Could not instantiate 'PreferenceModalViewController'", type: .error)
            return
        }

        // first display the view controller since otherwise its window variable is nil
        presentAsModalWindow(preferenceModalViewController)

        // get the position of the main window
        guard let parentWindowFrame: NSRect = self.view.window?.frame else {
            os_log("Could not retrieve the position of the modal parent window frame", type: .error)
            return
        }

        // get the position of the modal window
        guard let modalWindowFrame: NSRect = preferenceModalViewController.view.window?.frame else {
            os_log("Could not retrieve the position of the modal window", type: .error)
            return
        }

        // get the window of the modal
        guard let modalWindow = preferenceModalViewController.view.window else {
            os_log("Could not retrieve the modal window", type: .error)
            return
        }

        // position the modal in the center of the main window
        // (coordinate center of a window is in the left lower corner)
        let newWindowPosition = NSPoint(
            x: parentWindowFrame.midX - modalWindowFrame.width / 2,
            y: parentWindowFrame.midY + modalWindowFrame.height / 2
        )
        modalWindow.setFrameTopLeftPoint(newWindowPosition)
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
            let buttonView = getSidebarButtonWith(identifier: identifier.buttonViewID)

            if buttonView?.identifier == sender.identifier {
                buttonView?.highlighted = true
            } else {
                buttonView?.highlighted = false
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
    }

    /**
     * Adds the iGlance logo to the top of the sidebar.
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
