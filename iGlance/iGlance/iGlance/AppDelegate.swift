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
import CocoaLumberjack
import AppMover
import SMCKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: -
    // MARK: Static Constants
    static let userSettings = UserSettings()

    // MARK: -
    // MARK: Instance Variables

    var mainWindow: MainWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MainWindowController") as! MainWindowController

    let menuBarItemManager = MenuBarItemManager()

    var currentUpdateLoopTimer: Timer!

    // MARK: -
    // MARK: Lifecycle Functions

    func applicationWillFinishLaunching(_ notification: Notification) {
        // set the custom log formatter
        DDOSLogger.sharedInstance.logFormatter = CustomLogFormatter()
        // add the loggers to the loggin framework
        DDLog.add(DDOSLogger.sharedInstance)

        // register the logger
        // logs are saved under /Library/Logs/iGlance/
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
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // kill the launcher app
        killLauncherApplication()

        DDLogInfo("iGlance did launch")

        // check whether the app has to be moved into the applications folder
        if !DEBUG {
            AppMover.moveIfNecessary()
        }

        // open the connection to the SMC
        do {
            try SMCKit.open()
        } catch SMCKit.SMCError.driverNotFound {
            DDLogError("Could not find the SMC driver.")
        } catch {
            DDLogError("Failed to open a connection to the SMC")
        }

        // create the timer object
        currentUpdateLoopTimer = createUpdateLoopTimer(interval: AppDelegate.userSettings.settings.updateInterval)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // show the main window
        showMainWindow()

        // return false to prevent a relaunch of the app
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        // kill the launcher app if it is still running
        killLauncherApplication()

        // close the connection to the SMC
        if !SMCKit.close() {
            DDLogError("Failed to close the connection to the SMC")
        }
    }

    // MARK: -
    // MARK: Actions

    /**
     * This function is called when the 'About iGlance' button in the app menu is clicked
     */
    @IBAction private func about(_ sender: NSMenuItem) {
        // instantiate the storyboard (bundle = nil indicates the apps main bundle)
        let storyboard = NSStoryboard(name: "AboutWindow", bundle: nil)

        // instantiate the view controller for the about window
        guard let aboutModalViewController = storyboard.instantiateController(withIdentifier: "AboutModalViewController") as? AboutModalViewController else {
            DDLogError("Could not instantiate 'AboutModalViewController'")
            return
        }

        // get the view controller from the main window
        guard let mainWindowController = NSApplication.shared.windows.first(where: { $0.windowController is MainWindowController }) else {
            DDLogError("Could not retrieve main window controller")
            return
        }
        // get the window of the main window view controller
        guard let mainWindow = mainWindowController.contentViewController?.view.window else {
            DDLogError("Could not retrieve the window of the main window view controller")
            return
        }

        aboutModalViewController.showModal(parentWindow: mainWindow)

        DDLogInfo("Displaying the 'About' modal")
    }

    // MARK: -
    // MARK: Private Functions

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
            DDLogInfo("iGlance Launcher is already running")
            guard let mainAppBundleIdentifier = Bundle.main.bundleIdentifier else {
                DDLogError("Could not retrieve the main bundle identifier")
                return
            }

            // if the launcher application is running terminate it
            DistributedNotificationCenter.default().post(name: .killLauncher, object: mainAppBundleIdentifier)
            DDLogInfo("Sent notification to kill the launcher")
        }
    }

    // MARK: -
    // MARK: Instance Functions

    /**
     * Shows the main window, order it in front of any other window and activate the window..
     */
    @objc
    func showMainWindow() {
        mainWindow.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    /**
     * Creates a timer and adds it to a the current run loop. The timer calls the update loop every given time interval.
     *
     * - Returns: The newly created timer.
     */
    func createUpdateLoopTimer(interval: Double) -> Timer {
        let timer = Timer(timeInterval: interval, target: self, selector: #selector(updateLoop), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)

        return timer
    }

    /**
     * The main update loop for the whole app. This function is called every user defined time interval.
     */
    @objc
    func updateLoop() {
        menuBarItemManager.updateMenuBarItems()
    }

    /**
     * Changes the update interval of the main loop to the given time interval. Returns the new timer object.
     */
    func changeUpdateLoopTimeInterval(interval: Double) -> Timer {
        // invalidate the currently used timer to stop it
        currentUpdateLoopTimer.invalidate()

        // create a new timer object
        let timer = createUpdateLoopTimer(interval: interval)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)

        return timer
    }
}
