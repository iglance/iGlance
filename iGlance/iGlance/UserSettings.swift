//
//  UserSettings.swift
//  iGlance
//
//  Created by Dominik on 08.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import os.log

struct IGlanceUserSettings: Codable {
    var autostartOnBoot: Bool = false
}

class UserSettings {
    var settings: IGlanceUserSettings! {
        didSet {
            // when the values of the struct changed saved it to the user defaults object
            if !saveUserSettings(settings: self.settings) {
                os_log("Could not save the user settings", type: .error)
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
        guard let loadedUserSettings = UserDefaults.standard.value(forKey: self.userSettingsKey) as? Data else {
            // if no settings could be loaded return the default settings
            return IGlanceUserSettings()
        }

        do {
            // decode the loaded settings
            let decodedUserSettings: IGlanceUserSettings = try PropertyListDecoder().decode(IGlanceUserSettings.self, from: loadedUserSettings)
            return decodedUserSettings
        } catch {
            // if an error occurred return the default settings
            os_log("Could not decode the saved user settings", type: .error)
            return IGlanceUserSettings()
        }
    }

    /**
     * Saves the given settings in the default settings. Returns true when saving was successful and return false otherwise.
     */
    private func saveUserSettings(settings: IGlanceUserSettings) -> Bool {
        do {
            // encode the user settings
            let encodedSettings = try PropertyListEncoder().encode(settings)
            // save the user settings
            UserDefaults.standard.set(encodedSettings, forKey: self.userSettingsKey)

            return true
        } catch {
            os_log("Could not encode the user settings", type: .error)
        }

        return false
    }
}
