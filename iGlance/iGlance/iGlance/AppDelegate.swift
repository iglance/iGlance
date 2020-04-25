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
import AppMover
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: -
    // MARK: Static Constants
    static let userSettings = UserSettings()

    static let menuBarItemManager = MenuBarItemManager()

    static let systemInfo = SystemInfo()

    // MARK: -
    // MARK: Instance Variables

    let logger = Logger()

    var mainWindow: MainWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MainWindowController") as! MainWindowController

    var currentUpdateLoopTimer: RepeatingTimer!

    // MARK: -
    // MARK: Lifecycle Functions

    func applicationWillFinishLaunching(_ notification: Notification) {
        // call the update loop once on startup to render the menu bar items
        self.updateLoop()

        // check if automatic updating is disabled
        guard let sharedUpdater = SUUpdater.shared() else {
            DDLogError("Could not retrieve the shared SUUpdater")
            return
        }
        if !sharedUpdater.automaticallyChecksForUpdates {
            UserDefaults.standard.set(true, forKey: "SUEnableAutomaticChecks")
            DDLogInfo("Set 'SUEnableAutomaticChecks' to \(sharedUpdater.automaticallyChecksForUpdates)")
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

        // create the timer object
        currentUpdateLoopTimer = createUpdateLoopTimer(interval: AppDelegate.userSettings.settings.updateInterval)

        // add the observer for sleep mode
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(self.onWakeUp(notification:)),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(self.onSleep(notification:)),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
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
    }

    /**
     * This function will be called when the machine is waking up from sleep
     */
    @objc
    private func onWakeUp(notification: NSNotification) {
        // resume the timer
        currentUpdateLoopTimer.resume()
        DDLogInfo("Create a new timer after waking up from sleep")
    }

    /**
     * This function will be called when the machine is going into sleep mode.
     */
    @objc
    private func onSleep(notification: NSNotification) {
        // suspend the current timer
        currentUpdateLoopTimer.suspend()
        DDLogInfo("Invalidated the current timer")
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
            DDLogInfo("iGlance Launcher is running")
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
     * Shows the main window, order it in front of any other window and activate the window.
     */
    @objc
    func showMainWindow() {
        mainWindow.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    /**
     * Shows the preference window by first showing the main window and then the preference window of the app.
     */
    func showPreferenceWindow() {
        // first show the main window. Basically it should never be the case that the main window is nil or not visible
        if let window = mainWindow.window, !window.isVisible {
            NSApp.activate(ignoringOtherApps: true)
        } else if mainWindow.window == nil {
            showMainWindow()
        }

        // then show the preference window
        // instantiate the storyboard (bundle = nil indicates the apps main bundle)
        let storyboard = NSStoryboard(name: "PreferenceWindow", bundle: nil)

        // instantiate the view controller
        guard let preferenceModalViewController = storyboard.instantiateController(withIdentifier: "PreferenceModalViewController") as? PreferenceModalViewController else {
            DDLogError("Could not instantiate 'PreferenceModalViewController'")
            return
        }

        // get the parent window
        guard let parentWindow = mainWindow.window else {
            DDLogError("Could not unwrap the parent window")
            return
        }

        preferenceModalViewController.showModal(parentWindow: parentWindow)
    }

    /**
     * Creates a timer and adds it to a the current run loop. The timer calls the update loop every given time interval.
     *
     * - Returns: The newly created timer.
     */
    func createUpdateLoopTimer(interval: Double) -> RepeatingTimer {
        let timer = RepeatingTimer(timeInterval: interval)
        timer.eventHandler = updateLoop
        timer.resume()

        return timer
    }

    /**
     * The main update loop for the whole app. This function is called every user defined time interval.
     */
    func updateLoop() {
        DispatchQueue.main.async {
            AppDelegate.menuBarItemManager.updateMenuBarItems()
        }
    }

    /**
     * Changes the update interval of the main loop to the given time interval.
     */
    func changeUpdateLoopTimeInterval(interval: Double) {
        // create a new timer instance
        let timer = RepeatingTimer(timeInterval: interval)
        timer.eventHandler = updateLoop
        timer.resume()

        self.currentUpdateLoopTimer = timer
    }

    // MARK: -
    // MARK: Static Functions

    /**
     * Returns the current instance of the app delegate class.
     */
    static func getInstance() -> AppDelegate? {
        NSApplication.shared.delegate as? AppDelegate
    }

    // MARK: -
    // MARK: Actions

    @IBAction private func saveMostRecentLogFile(sender: AnyObject) {
        self.logger.saveMostRecentLogFile()
    }

    @IBAction private func showPreferenceWindow(sender: AnyObject) {
        self.showPreferenceWindow()
    }
}
