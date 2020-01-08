//
//  AppDelegate.swift
//  iGlance
//
//  Created by Dominik on 15.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa
import ServiceManagement
import os.log

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    static let userSettings = UserSettings()

    // MARK: -
    // MARK: Lifecycle Functions

    func applicationDidFinishLaunching(_ notification: Notification) {
        // kill the launcher app
               killLauncherApplication()
    }

    // MARK: -
    // MARK: Private functions

    /**
     * Kills the iGlanceLauncher application.
     */
    private func killLauncherApplication() {
        // get all currently running apps
        let runningApps = NSWorkspace.shared.runningApplications
        // check if the launcher is already running
        // swiftlint:disable:next contains_over_filter_is_empty
        let launcherIsRunning = !runningApps.filter {
            $0.bundleIdentifier == LAUNCHER_BUNDLE_IDENTIFIER
        }.isEmpty

        if launcherIsRunning {
            guard let mainAppBundleIdentifier = Bundle.main.bundleIdentifier else {
                os_log("Could not retrieve the main bundle identifier", type: .error)
                return
            }

            // if the launcher application is running terminate it
            DistributedNotificationCenter.default().post(name: .killLauncher, object: mainAppBundleIdentifier)
        }
    }
}
