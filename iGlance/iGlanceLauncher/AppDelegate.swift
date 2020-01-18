//
//  AppDelegate.swift
//  iGlanceLauncher
//
//  Created by Dominik on 07.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

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
        let fileLogger = DDFileLogger()
        fileLogger.logFormatter = CustomLogFormatter()
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)

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
