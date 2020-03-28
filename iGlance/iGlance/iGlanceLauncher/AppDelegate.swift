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
import CocoaLumberjack

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // set the custom log formatter
        DDOSLogger.sharedInstance.logFormatter = CustomLogFormatter()
        // add the loggers to the loggin framework
        DDLog.add(DDOSLogger.sharedInstance)

        // register the logger
        // logs are saved under /Library/Containers/io.github.iglance.iGlanceLauncher/Data/Library/Logs/iGlanceLauncher/
        let fileLogger = DDFileLogger()
        fileLogger.logFormatter = CustomLogFormatter()
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)

        // set the default log level to error
        dynamicLogLevel = .error
        if DEBUG {
            dynamicLogLevel = .all
        }

        if self.isMainAppRunning() {
            // if the main application is already running terminate the launcher
            self.killLauncher()
            DDLogInfo("Killed the launcher application")
        }

        // launch the main app
        if !launchMainApp() {
            DDLogError("Could not launch the main application")
            return
        }

        DDLogInfo("iGlance Launcher did finish launching")
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Launches the main application.
     *
     * - Returns: Boolean which indicates whether launching the application was successful.
     */
    private func launchMainApp() -> Bool {
        // add a listener to kill this app when the launcher started correctly
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(self.killLauncher),
            name: .killLauncher,
            object: MAIN_APP_BUNDLE_IDENTIFIER
        )

        // get the path to the main app
        let mainAppPath = self.getMainAppPath()

        return NSWorkspace.shared.launchApplication(mainAppPath)
    }

    /**
     * Kills the launcher application.
     */
    @objc
    private func killLauncher() {
        NSApp.terminate(nil)
    }

    /**
     * Returns true if the main application of the launcher is currently running. Returns false otherwise.
     */
    private func isMainAppRunning() -> Bool {
        // get all the running apps and check whether the main app is already running
        let runningApps = NSWorkspace.shared.runningApplications
        // swiftlint:disable:next contains_over_filter_is_empty
        return !runningApps.filter { $0.bundleIdentifier == MAIN_APP_BUNDLE_IDENTIFIER }.isEmpty
    }

    /**
     * Returns the path within the bundle to the main application.
     */
    private func getMainAppPath() -> String {
        // get the bundle path of this application
        let bundlePath = Bundle.main.bundlePath as NSString

        // split the components of the path
        var pathComponents = bundlePath.pathComponents

        // remove the last three components of the path which are 'Contents/Library/LoginItems'
        pathComponents.removeLast(3)

        // append the path to the main app
        pathComponents.append("MacOS")
        pathComponents.append("iGlance")

        // create a path object from the array and return the string
        return NSString.path(withComponents: pathComponents)
    }
}
