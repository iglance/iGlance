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

    var currentUpdateLoopTimer: Timer!

    // MARK: -
    // MARK: Lifecycle Functions

    func applicationWillFinishLaunching(_ notification: Notification) {
        // call the update loop once on startup to render the menu bar items
        self.updateLoop()
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
        AppDelegate.menuBarItemManager.updateMenuBarItems()
    }

    /**
     * Changes the update interval of the main loop to the given time interval.
     */
    func changeUpdateLoopTimeInterval(interval: Double) {
        // invalidate the currently used timer to stop it
        currentUpdateLoopTimer.invalidate()

        // create a new timer object
        let timer = createUpdateLoopTimer(interval: interval)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)

        currentUpdateLoopTimer = timer
    }

    private func updateGUIofCurrentMainView() {
        guard let mainWindowVC = mainWindow.contentViewController as? MainWindowViewController else {
            DDLogError("Could not call the 'contentViewController' of the main window to 'MainWindowViewController'")
            return
        }
        guard let contentManagerVC = mainWindowVC.contentManagerViewController else {
            DDLogError("'contentManagerViewController' of main window is nil")
            return
        }
        guard let mainViewVC = contentManagerVC.currentViewController as? MainViewViewController else {
            DDLogError("Could not cast the 'currentViewController' of the 'ContentManagerViewController' to 'MainViewViewController'")
            return
        }
        mainViewVC.updateGUIComponents()
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

    @IBAction private func exportSettings(sender: AnyObject) {
        AppDelegate.userSettings.exportUserSettings()
    }

    @IBAction private func importSettings(sender: AnyObject) {
        AppDelegate.userSettings.importUserSettings()
        self.updateGUIofCurrentMainView()
        logger.updateLogSettings()
        Autostart.updateAutostartOnBoot()
    }

    @IBAction private func resetSettings(sender: AnyObject) {
        AppDelegate.userSettings.resetUserSettings()
        self.updateGUIofCurrentMainView()
        logger.updateLogSettings()
        Autostart.updateAutostartOnBoot()
    }
}
