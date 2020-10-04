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

struct ColorGradientSettings: Codable, Equatable {
    var useGradient: Bool
    var secondaryColor: CodableColor

    static func == (lhs: ColorGradientSettings, rhs: ColorGradientSettings) -> Bool {
        lhs.useGradient == rhs.useGradient && lhs.secondaryColor == rhs.secondaryColor
    }
}

struct CpuSettings: Codable, Equatable {
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

    init() { }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let decodedShowTemperature = try? container.decodeIfPresent(Bool.self, forKey: .showTemperature) {
            self.showTemperature = decodedShowTemperature
        }
        if let decodedShowUsage = try? container.decodeIfPresent(Bool.self, forKey: .showUsage) {
            self.showUsage = decodedShowUsage
        }
        if let decodedUsageGraphColor = try? container.decodeIfPresent(CodableColor.self, forKey: .usageGraphColor) {
            self.usageGraphColor = decodedUsageGraphColor
        }
        if let decodedUsageGraphKind = try? container.decodeIfPresent(GraphKind.self, forKey: .usageGraphKind) {
            self.usageGraphKind = decodedUsageGraphKind
        }
        if let decodedUsageLineGraphWidth = try? container.decodeIfPresent(Int.self, forKey: .usageLineGraphWidth) {
            self.usageLineGraphWidth = decodedUsageLineGraphWidth
        }
        if let decodedShowUsageGraphBorder = try? container.decodeIfPresent(Bool.self, forKey: .showUsageGraphBorder) {
            self.showUsageGraphBorder = decodedShowUsageGraphBorder
        }
        if let decodedColorGradientSettings = try? container.decodeIfPresent(ColorGradientSettings.self, forKey: .colorGradientSettings) {
            self.colorGradientSettings = decodedColorGradientSettings
        }
    }

    static func == (lhs: CpuSettings, rhs: CpuSettings) -> Bool {
        lhs.showTemperature == rhs.showTemperature
            && lhs.showUsage == rhs.showUsage
            && lhs.usageGraphColor == rhs.usageGraphColor
            && lhs.usageGraphKind == rhs.usageGraphKind
            && lhs.usageLineGraphWidth == rhs.usageLineGraphWidth
            && lhs.showUsageGraphBorder == rhs.showUsageGraphBorder
            && lhs.colorGradientSettings == rhs.colorGradientSettings
    }
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

    init() { }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let decodedShowUsage = try? container.decodeIfPresent(Bool.self, forKey: .showUsage) {
            self.showUsage = decodedShowUsage
        }
        if let decodedUsageGraphColor = try? container.decodeIfPresent(CodableColor.self, forKey: .usageGraphColor) {
            self.usageGraphColor = decodedUsageGraphColor
        }
        if let decodedUsageGraphKind = try? container.decodeIfPresent(GraphKind.self, forKey: .usageGraphKind) {
            self.usageGraphKind = decodedUsageGraphKind
        }
        if let decodedUsageLineGraphWidth = try? container.decodeIfPresent(Int.self, forKey: .usageLineGraphWidth) {
            self.usageLineGraphWidth = decodedUsageLineGraphWidth
        }
        if let decodedShowUsageGraphBorder = try? container.decodeIfPresent(Bool.self, forKey: .showUsageGraphBorder) {
            self.showUsageGraphBorder = decodedShowUsageGraphBorder
        }
        if let decodedColorGradientSettings = try? container.decodeIfPresent(ColorGradientSettings.self, forKey: .colorGradientSettings) {
            self.colorGradientSettings = decodedColorGradientSettings
        }
    }
}

struct FanSettings: Codable {
    var showFanSpeed: Bool = true
    var showFanSpeedUnit: Bool = true

    init() { }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let decodedShowFanSpeed = try? container.decodeIfPresent(Bool.self, forKey: .showFanSpeed) {
            self.showFanSpeed = decodedShowFanSpeed
        }
        if let decodedShowFanSpeedUnit = try? container.decodeIfPresent(Bool.self, forKey: .showFanSpeedUnit) {
            self.showFanSpeedUnit = decodedShowFanSpeedUnit
        }
    }
}

struct NetworkSettings: Codable {
    var showBandwidth: Bool = true

    init() { }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let decodedShowBandwidth = try? container.decodeIfPresent(Bool.self, forKey: .showBandwidth) {
            self.showBandwidth = decodedShowBandwidth
        }
    }
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

    init() { }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let decodedShowBatteryMenuBarItem = try? container.decodeIfPresent(Bool.self, forKey: .showBatteryMenuBarItem) {
            self.showBatteryMenuBarItem = decodedShowBatteryMenuBarItem
        }

        if let decodedShowPercentage = try? container.decodeIfPresent(Bool.self, forKey: .showBatteryMenuBarItem) {
            self.showPercentage = decodedShowPercentage
        }

        if let decodedLowBatteryNotification = try? container.decodeIfPresent(BatteryNotificationSettings.self, forKey: .highBatteryNotification) {
            self.lowBatteryNotification = decodedLowBatteryNotification
        }

        if let decodedHighBatteryNotification = try? container.decodeIfPresent(BatteryNotificationSettings.self, forKey: .highBatteryNotification) {
            self.highBatteryNotification = decodedHighBatteryNotification
        }
    }
}

struct DiskSettings: Codable {
    var showDiskUsage: Bool = true

    init() { }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let decodedShowDiskUsage = try? container.decodeIfPresent(Bool.self, forKey: .showDiskUsage) {
            self.showDiskUsage = decodedShowDiskUsage
        }
    }
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

    init() { }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // decode the keys, if they are not present use the default values
        if let decodedAutostartOnBoot = try? container.decodeIfPresent(String.self, forKey: .autostartOnBoot) {
            self.autostartOnBoot = decodedAutostartOnBoot.lowercased() == "true"
        }
        if let decodedAdvancedLogging = try? container.decodeIfPresent(Bool.self, forKey: .advancedLogging) {
            self.advancedLogging = decodedAdvancedLogging
        }
        if let decodedUpdateInterval = try? container.decodeIfPresent(Double.self, forKey: .updateInterval) {
            self.updateInterval = decodedUpdateInterval
        }
        if let decodedTempUnit = try? container.decodeIfPresent(TemperatureUnit.self, forKey: .tempUnit) {
            self.tempUnit = decodedTempUnit
        }

        // decode the settings for each module
        if let decodedCpu = try? container.decodeIfPresent(CpuSettings.self, forKey: .cpu) {
            self.cpu = decodedCpu
        }
        if let decodedMemory = try? container.decodeIfPresent(MemorySettings.self, forKey: .memory) {
            self.memory = decodedMemory
        }
        if let decodedFan = try? container.decodeIfPresent(FanSettings.self, forKey: .fan) {
            self.fan = decodedFan
        }
        if let decodedNetwork = try? container.decodeIfPresent(NetworkSettings.self, forKey: .network) {
            self.network = decodedNetwork
        }
        if let decodedBattery = try? container.decodeIfPresent(BatterySettings.self, forKey: .battery) {
            self.battery = decodedBattery
        }
        if let decodedDisk = try? container.decodeIfPresent(DiskSettings.self, forKey: .disk) {
            self.disk = decodedDisk
        }
    }
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
            try loadUserSettingsFromPath(importUrl: importURL)
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

    func loadUserSettingsFromPath(importUrl: URL) throws {
        let fileContents = try String(contentsOf: importUrl, encoding: String.Encoding.utf8)
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
