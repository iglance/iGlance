//
//  PreferenceModalViewController.swift
//  iGlance
//
//  Created by Dominik on 06.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import ServiceManagement
import os.log

class PreferenceModalViewController: NSViewController {
    // MARK: -
    // MARK: Outlets
    @IBOutlet private var versionLabel: NSTextField!
    @IBOutlet private var autostartOnBootCheckbox: NSButton! {
        didSet {
            autostartOnBootCheckbox.state = (AppDelegate.userSettings.settings.autostartOnBoot) ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    // MARK: -
    // MARK: Private Variables
    private var onDisappearCallback: (() -> Void)?

    // MARK: -
    // MARK: Function Overrides

    override func viewWillAppear() {
        super.viewWillAppear()

        // get the version of the app
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            os_log("Could not retrieve the version of the app", type: .error)
            return
        }

        versionLabel.stringValue = appVersion
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        // change the window appearance by making the titlebar transparent
        self.view.window?.styleMask.insert(.fullSizeContentView)
        self.view.window?.titlebarAppearsTransparent = true
        self.view.window?.titleVisibility = .hidden

        // disable resizing of the window
        self.view.window?.styleMask.remove(.resizable)

        // hide all unused window buttons
        self.view.window?.standardWindowButton(.zoomButton)?.isHidden = true
        self.view.window?.standardWindowButton(.miniaturizeButton)?.isHidden = true

        // make the window unmovable
        self.view.window?.isMovable = false
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        // call the callback
        if let unwrappedCallback = self.onDisappearCallback {
            unwrappedCallback()
        }
    }

    // MARK: -
    // MARK: Actions

    @IBAction private func autoStartCheckboxChanged(_ sender: NSButton) {
        // set the auto start on boot user setting
        AppDelegate.userSettings.settings.autostartOnBoot = (sender.state == NSButton.StateValue.on)

        // enable the login item if the checkbox is activated
        if sender.state == NSButton.StateValue.on {
            if !SMLoginItemSetEnabled(LAUNCHER_BUNDLE_IDENTIFIER as CFString, true) {
                os_log("Could not enable the iGlanceLauncher as login item", type: .error)
            }

            return
        }

        // disable the login item if the checkbox is not activated
        if !SMLoginItemSetEnabled(LAUNCHER_BUNDLE_IDENTIFIER as CFString, false) {
            os_log("Could not deactive the iGlanceLauncher as login item", type: .error)
        }
    }

    // MARK: -
    // MARK: Instance Functions

    func onDisappear(callback: @escaping () -> Void) {
        self.onDisappearCallback = callback
    }
}
