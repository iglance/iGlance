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

import Foundation
import CocoaLumberjack
import SMCKit

// MARK: -
// MARK: User Settings Structs

struct ColorGradientSettings: Codable {
    var useGradient: Bool
    var secondaryColor: CodableColor
}

struct CpuSettings: Codable {
    var showTemperature: Bool = true
    var showUsage: Bool = true
    var usageGraphColor = CodableColor(nsColor: NSColor.green)
    var usageGraphKind: GraphKind = .bar
    var usageLineGraphWidth: Int = 50
    var showUsageGraphBorder: Bool = true

    var colorGradientSettings = ColorGradientSettings(
        useGradient: false,
        secondaryColor: CodableColor(nsColor: NSColor.red)
    )
}

struct MemorySettings: Codable {
    var showUsage: Bool = true
    var usageGraphColor = CodableColor(nsColor: NSColor.blue)
    var usageGraphKind: GraphKind = .bar
    var usageLineGraphWidth: Int = 50
    var showUsageGraphBorder: Bool = true

    var colorGradientSettings = ColorGradientSettings(
        useGradient: false,
        secondaryColor: CodableColor(nsColor: NSColor.red)
    )
}

struct FanSettings: Codable {
    var showFanSpeed: Bool = true
    var showFanSpeedUnit: Bool = true
}

struct NetworkSettings: Codable {
    var showBandwidth: Bool = true
}

struct BatteryNotificationSettings: Codable {
    var notifyUser: Bool
    var value: Int
}

struct BatterySettings: Codable {
    var showBatteryMenuBarItem: Bool = AppDelegate.systemInfo.battery.hasBattery()
    /// Is true when the percentage of the battery charge is displayed. If the value is false, the remaining time is displayed instead
    var showPercentage: Bool = false
    var lowBatteryNotification = BatteryNotificationSettings(notifyUser: true, value: 20)
    var highBatteryNotification = BatteryNotificationSettings(notifyUser: true, value: 90)
}

struct DiskSettings: Codable {
    var showDiskUsage: Bool = true
}

struct IGlanceUserSettings: Codable {
    // global settings
    var autostartOnBoot: Bool = false
    var advancedLogging: Bool = DEBUG
    var updateInterval: Double = 2.0
    var tempUnit: TemperatureUnit = .celsius

    var cpu = CpuSettings()
    var memory = MemorySettings()
    var fan = FanSettings()
    var network = NetworkSettings()
    var battery = BatterySettings()
    var disk = DiskSettings()
}

// MARK: -
// MARK: User Settings Class

public class UserSettings {
    var settings: IGlanceUserSettings! {
        didSet {
            DDLogInfo("User settings changed")
            // when the values of the struct changed saved it to the user defaults object
            if !saveUserSettings(settings: self.settings) {
                DDLogError("Could not save the user settings")
            }
        }
    }

    private let userSettingsKey: String = "iGlanceUserSettings"

    init() {
        settings = loadUserSettings()
    }

    // MARK: -
    // MARK: Instance Functions

    /**
     * Opens a save dialog for exporting the current settings as a json file to the selected destination.
     */
    func exportUserSettings() {
        DDLogInfo("Exporting user settings")
        let savePanel = NSSavePanel()

        savePanel.showsTagField = false
        savePanel.title = "Export iGlance settings"
        savePanel.prompt = "Save"
        savePanel.nameFieldLabel = "Export path:"
        savePanel.nameFieldStringValue = "settings"
        savePanel.allowedFileTypes = ["json"]
        savePanel.isExtensionHidden = false
        savePanel.canSelectHiddenExtension = false
        savePanel.runModal()
        guard let saveURL = savePanel.url else {
            return
        }

        let jsonEncoder = JSONEncoder()
        var jsonData: Data

        do {
            jsonData = try jsonEncoder.encode(AppDelegate.userSettings.settings)
        } catch {
            return
        }

        let json = String(data: jsonData, encoding: String.Encoding.utf8)

        do {
            try json!.write(to: saveURL, atomically: true, encoding: .utf8)
        } catch {
            print(error)
            return
        }
    }

    /**
     * Opens a dialog in which the user can select a JSON-file which contains the settings that are going to be imported.
     */
    func importUserSettings() {
        let openPanel = NSOpenPanel()
        openPanel.showsTagField = true
        openPanel.title = "Import iGlance settings"
        openPanel.prompt = "Open"
        openPanel.nameFieldLabel = "Import path:"
        openPanel.nameFieldStringValue = "settings.json"
        openPanel.allowedFileTypes = ["json"]
        openPanel.isExtensionHidden = false
        openPanel.canSelectHiddenExtension = false
        openPanel.runModal()

        guard let importURL = openPanel.url else {
            DDLogError("Error importing user settings file through dialog")
            return
        }

        do {
            let fileContents = try String(contentsOf: importURL, encoding: String.Encoding.utf8)
            let jsonDecoder = JSONDecoder()
            let jsonData = fileContents.data(using: .utf8)!
            let newObject = try jsonDecoder.decode(IGlanceUserSettings.self, from: jsonData)
            self.settings = newObject

            // update the update loop timer
            if let appDelegate = AppDelegate.getInstance() {
                appDelegate.changeUpdateLoopTimeInterval(interval: AppDelegate.userSettings.settings.updateInterval)
            } else {
                DDLogError("Could not retrieve the App Delegate Instance")
            }

            // Clear image cache of bar graphs
            AppDelegate.menuBarItemManager.cpuUsage.barGraph.clearImageCache()
            AppDelegate.menuBarItemManager.memoryUsage.barGraph.clearImageCache()

            // Set correct visibility of menubaritems
            AppDelegate.menuBarItemManager.updateMenuBarItems()
        } catch {
            DDLogError("An error occured while importing settings")
            Dialog.showErrorModal(messageText: "Error", informativeText: "An error occured while importing settings")
        }
    }

    /**
     * Opens a dialog in which the user has to confirm that the settings should be reset. If the user confirms the dialog all settings are reset to default.
     */
    func resetUserSettings() {
        if !DEBUG && Dialog.showConfirmModal(messageText: "Reset Settings", informativeText: "Are you sure that you want to reset all settings?") == .alertSecondButtonReturn {
            // Cancel button clicked
            return
        }

        // Reset settings to default
        self.setDefaultSettings()

        // update the update loop timer
        if let appDelegate = AppDelegate.getInstance() {
            appDelegate.changeUpdateLoopTimeInterval(interval: AppDelegate.userSettings.settings.updateInterval)
        } else {
            DDLogError("Could not retrieve the App Delegate Instance")
        }

        // Clear image cache of bar graphs
        AppDelegate.menuBarItemManager.cpuUsage.barGraph.clearImageCache()
        AppDelegate.menuBarItemManager.memoryUsage.barGraph.clearImageCache()

        // Set correct visibility of menubaritems
        AppDelegate.menuBarItemManager.updateMenuBarItems()
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Loads the saved settings. If there are no saved settings it loads the default settings.
     */
    private func loadUserSettings() -> IGlanceUserSettings {
        DDLogInfo("Loading user settings")
        guard let loadedUserSettings = UserDefaults.standard.value(forKey: self.userSettingsKey) as? Data else {
            // if no settings could be loaded return the default settings
            DDLogError("User settings could not be loaded. Falling back to default settings")
            return IGlanceUserSettings()
        }

        do {
            // decode the loaded settings
            let decodedUserSettings: IGlanceUserSettings = try PropertyListDecoder().decode(IGlanceUserSettings.self, from: loadedUserSettings)
            DDLogInfo("Decoded the user settings")
            return decodedUserSettings
        } catch {
            // if an error occurred return the default settings
            DDLogError("Could not decode the saved user settings")
            return IGlanceUserSettings()
        }
    }

    /**
     * Saves the given settings in the default settings. Returns true when saving was successful and return false otherwise.
     */
    private func saveUserSettings(settings: IGlanceUserSettings) -> Bool {
        DDLogInfo("Saving the user settings")
        do {
            // encode the user settings
            let encodedSettings = try PropertyListEncoder().encode(settings)
            DDLogInfo("Encoded the user settings")
            // save the user settings
            UserDefaults.standard.set(encodedSettings, forKey: self.userSettingsKey)
            DDLogInfo("Saved the user settings")
            return true
        } catch {
            DDLogError("Could not encode the user settings")
        }

        return false
    }

    /*
     * Reset settings to default
     */
    private func setDefaultSettings() {
        self.settings = IGlanceUserSettings()
    }
}
