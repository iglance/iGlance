//
//  UserSettings.swift
//  iGlance
//
//  Created by Dominik on 08.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack
import SMCKit

struct CpuSettings: Codable {
    var showTemperature: Bool = true
    var showUsage: Bool = true
    var usageBarColor = CodableColor(nsColor: NSColor.purple)
}

struct IGlanceUserSettings: Codable {
    // global settings
    var autostartOnBoot: Bool = false
    var updateInterval: Double = 2.0
    var tempUnit: TemperatureUnit = .celsius

    var cpu = CpuSettings()
}

class UserSettings {
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
}
