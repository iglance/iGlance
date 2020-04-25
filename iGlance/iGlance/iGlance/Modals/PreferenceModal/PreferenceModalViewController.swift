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
import ServiceManagement
import CocoaLumberjack

class PreferenceModalViewController: ModalViewController {
    // MARK: -
    // MARK: Outlets
    @IBOutlet private var versionLabel: NSTextField!

    @IBOutlet private var autostartOnBootCheckbox: NSButton! {
        didSet {
            // load the initial value from the user settings
            autostartOnBootCheckbox.state = AppDelegate.userSettings.settings.autostartOnBoot ? .on : .off
            self.setAutostartOnBoot(buttonState: autostartOnBootCheckbox.state)
        }
    }

    @IBOutlet private var advancedLoggingCheckbox: ThemedButton! {
        didSet {
            advancedLoggingCheckbox.state = AppDelegate.userSettings.settings.advancedLogging ? .on : .off
            self.setAdvancedLogging(buttonState: advancedLoggingCheckbox.state)
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
            self.setUpdateInterval(buttonValue: updateIntervalSelector)
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
            self.setTempUnit(buttonValue: tempUnitSelector)
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

    override func updateGUIComponents() {
        // Call didSet methods of all GUI components
        self.versionLabel = { self.versionLabel }()
        self.autostartOnBootCheckbox = { self.autostartOnBootCheckbox }()
        self.advancedLoggingCheckbox = { self.advancedLoggingCheckbox }()
        self.logoImage = { self.logoImage }()
        self.updateIntervalSelector = { self.updateIntervalSelector }()
        self.tempUnitSelector = { self.tempUnitSelector }()
    }

    // MARK: -
    // MARK: Actions

    /**
     * This function is called when the 'Autostart on boot' checkbox is clicked.
     */
    @IBAction private func autoStartCheckboxChanged(_ sender: NSButton) {
        DDLogInfo("'Autostart on Boot'-checkbox changed")
        self.setAutostartOnBoot(buttonState: sender.state)
    }

    @IBAction private func advancedLoggingCheckboxChanged(_ sender: NSButton) {
        DDLogInfo("Log level checkbox changed")
        self.setAdvancedLogging(buttonState: sender.state)
    }

    @IBAction private func updateIntervalSelectorChanged(_ sender: NSPopUpButton) {
        DDLogInfo("Update interval selector changed")
        self.setUpdateInterval(buttonValue: sender)
    }

    @IBAction private func tempUnitSelectorChanged(_ sender: NSPopUpButton) {
        DDLogInfo("Temp unit selector changed")
        self.setTempUnit(buttonValue: sender)
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

    private func setAutostartOnBoot(buttonState: NSButton.StateValue) {
        // set the auto start on boot user setting
        AppDelegate.userSettings.settings.autostartOnBoot = (buttonState == NSButton.StateValue.on)
        Autostart.updateAutostartOnBoot()
    }

    private func setAdvancedLogging(buttonState: NSButton.StateValue) {
        let activated = (buttonState == .on)
        // set the dynamic logging level depending on the state of the button
        if activated {
            dynamicLogLevel = .all
            DDLogInfo("Set the log level to 'all'")
            DDLogInfo("Activated 'Advanced Loggin'")
        } else {
            dynamicLogLevel = .error
            DDLogInfo("Set the log level to 'error'")
            DDLogInfo("Deactivated 'Advanced Loggin'")
        }

        // set the user setting
        AppDelegate.userSettings.settings.advancedLogging = activated
    }

    private func setUpdateInterval(buttonValue: NSPopUpButton) {
        // set the user settings
        let oldUpdateInterval = AppDelegate.userSettings.settings.updateInterval
        switch buttonValue.indexOfSelectedItem {
        case 0:
            // select the fast option which is 1 second
            AppDelegate.userSettings.settings.updateInterval = 1.0
        case 2:
            // the third item is the slow option
            AppDelegate.userSettings.settings.updateInterval = 3.0
        default:
            // default to the medium option
            AppDelegate.userSettings.settings.updateInterval = 2.0
        }

        // Since this function is also called if the value wasn't changed,
        // avoid unnecessary updateLoopTimeInterval() calls if the value was the same
        if oldUpdateInterval == AppDelegate.userSettings.settings.updateInterval {
            return
        }

        DDLogInfo("Set the update interval to \(updateIntervalSelector.indexOfSelectedItem + 1) seconds")

        // update the update loop timer
        guard let appDelegate = AppDelegate.getInstance() else {
            DDLogError("Could not retrieve the App Delegate Instance")
            return
        }
        appDelegate.changeUpdateLoopTimeInterval(interval: AppDelegate.userSettings.settings.updateInterval)
    }

    private func setTempUnit(buttonValue: NSPopUpButton) {
        // set the user settings
        switch buttonValue.indexOfSelectedItem {
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
}
