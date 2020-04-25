//
//  Autostart.swift
//  iGlance
//
//  Created by Cemal on 24.04.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import ServiceManagement
import CocoaLumberjack

class Autostart: NSObject {
    /**
     * Activates or deactivates autostart on boot accordingly to the current user settings.
     */
    static func updateAutostartOnBoot() {
        // enable the login item if the setting is true
        if AppDelegate.userSettings.settings.autostartOnBoot {
            if !SMLoginItemSetEnabled(LAUNCHER_BUNDLE_IDENTIFIER as CFString, true) {
                DDLogError("Could not enable the iGlanceLauncher as login item")
            }
            DDLogInfo("Successfully enabled iGlance Launcher as a login item")
            return
        }

        // disable the login item if the setting is false
        if !SMLoginItemSetEnabled(LAUNCHER_BUNDLE_IDENTIFIER as CFString, false) {
            DDLogError("Could not deactive the iGlanceLauncher as login item")
        }
        DDLogInfo("Successfully disabled the iGlance Launcher as a login item")
    }
}
