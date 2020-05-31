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
