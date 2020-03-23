//
//  PreferenceModalViewController.swift
//  iGlance
//
//  Created by Dominik on 06.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import ServiceManagement
import CocoaLumberjack
import Sparkle

class PreferenceModalViewController: ModalViewController {
    // MARK: -
    // MARK: Outlets
    @IBOutlet private var versionLabel: NSTextField!

    @IBOutlet private var autostartOnBootCheckbox: NSButton! {
        didSet {
            // load the initial value from the user settings
            autostartOnBootCheckbox.state = AppDelegate.userSettings.settings.autostartOnBoot ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBOutlet private var advancedLoggingCheckbox: ThemedButton! {
        didSet {
            advancedLoggingCheckbox.state = DEBUG ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBOutlet private var logoImage: NSImageView!

    @IBOutlet private var updateIntervalSelector: NSPopUpButton! {
        didSet {
            // initialize the selector with the correct value from the user settings
            switch AppDelegate.userSettings.settings.updateInterval {
            case 1.0:
                // select the fast option which is 1 second
                updateIntervalSelector.selectItem(at: 0)
            case 3.0:
                // select the slow option which is 3 seconds
                updateIntervalSelector.selectItem(at: 2)
            default:
                // default to the medium option which is 2 seconds
                updateIntervalSelector.selectItem(at: 1)
            }
        }
    }

    @IBOutlet private var tempUnitSelector: NSPopUpButton! {
        didSet {
            switch AppDelegate.userSettings.settings.tempUnit {
            case .fahrenheit:
                // the second item is celsius
                tempUnitSelector.selectItem(at: 1)
            case .kelvin:
                // the third item is kelvin
                tempUnitSelector.selectItem(at: 2)
            default:
                tempUnitSelector.selectItem(at: 0)
            }
        }
    }

    // MARK: -
    // MARK: Function Overrides

    override func viewWillAppear() {
        super.viewWillAppear()

        // get the version of the app
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            DDLogError("Could not retrieve the version of the app")
            return
        }
        versionLabel.stringValue = appVersion

        // add a callback to change the logo depending on the current theme
        ThemeManager.onThemeChange(self, #selector(onThemeChange))

        // add the correct logo image at startup
        changeLogo()

        DDLogInfo("View did appear")
    }

    // MARK: -
    // MARK: Actions

    /**
     * This function is called when the 'Autostart on boot' checkbox is clicked.
     */
    @IBAction private func autoStartCheckboxChanged(_ sender: NSButton) {
        // set the auto start on boot user setting
        DDLogInfo("'Autostart on Boot'-checkbox changed")
        AppDelegate.userSettings.settings.autostartOnBoot = (sender.state == NSButton.StateValue.on)

        // enable the login item if the checkbox is activated
        if sender.state == NSButton.StateValue.on {
            DDLogInfo("Checkbox is checked")
            if !SMLoginItemSetEnabled(LAUNCHER_BUNDLE_IDENTIFIER as CFString, true) {
                DDLogError("Could not enable the iGlanceLauncher as login item")
            }

            DDLogInfo("Successfully enabled iGlance Launcher as a login item")

            return
        }

        // disable the login item if the checkbox is not activated
        if !SMLoginItemSetEnabled(LAUNCHER_BUNDLE_IDENTIFIER as CFString, false) {
            DDLogError("Could not deactive the iGlanceLauncher as login item")
        }
        DDLogInfo("Successfully disabled the iGlance Launcher as a login item")
    }

    @IBAction private func advancedLoggingCheckboxChanged(_ sender: NSButton) {
        // set the dynamic logging level depending on the state of the button
        if sender.state == NSButton.StateValue.on {
            dynamicLogLevel = .all
            DDLogInfo("Set the log level to 'all'")
            DDLogInfo("Activated 'Advanced Loggin'")
        } else {
            dynamicLogLevel = .error
            DDLogInfo("Set the log level to 'error'")
            DDLogInfo("Deactivated 'Advanced Loggin'")
        }
    }

    @IBAction private func updateIntervalSelectorChanged(_ sender: NSPopUpButton) {
        // set the user settings
        switch updateIntervalSelector.indexOfSelectedItem {
        case 0:
            // the first item is the fast option
            AppDelegate.userSettings.settings.updateInterval = 1.0
        case 2:
            // the third item is the slow option
            AppDelegate.userSettings.settings.updateInterval = 3.0
        default:
            // default to the medium option
            AppDelegate.userSettings.settings.updateInterval = 2.0
        }

        // update the update loop timer
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.changeUpdateLoopTimeInterval(interval: AppDelegate.userSettings.settings.updateInterval)
    }

    @IBAction private func tempUnitSelectorChanged(_ sender: NSPopUpButton) {
        // set the user settings
        switch tempUnitSelector.indexOfSelectedItem {
        case 1:
            // the second item is fahrenheit
            AppDelegate.userSettings.settings.tempUnit = .fahrenheit
        case 2:
            // the third item is kelvin
            AppDelegate.userSettings.settings.tempUnit = .kelvin
        default:
            // the default item (the first one) is celsius
            AppDelegate.userSettings.settings.tempUnit = .celsius
        }
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Called when the os theme changed.
     */
    @objc
    private func onThemeChange() {
        changeLogo()
    }

    /**
     * Set the version label to the current app version.
     */
    private func setVersionLabel() {
        // get the version of the app
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            DDLogError("Could not retrieve the version of the app")
            return
        }
        versionLabel.stringValue = appVersion
    }

    /**
     * Sets the logo according to the current os theme.
     */
    private func changeLogo() {
        if ThemeManager.isDarkTheme() {
            logoImage.image = NSImage(named: "iGlance_logo_white")
        } else {
            logoImage.image = NSImage(named: "iGlance_logo_black")
        }
    }
}
