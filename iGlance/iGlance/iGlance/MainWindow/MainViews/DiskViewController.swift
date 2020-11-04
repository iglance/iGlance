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

class DiskViewController: MainViewViewController {
    // MARK: -
    // MARK: Outlets
    @IBOutlet private var diskUsageCheckbox: NSButton! {
        didSet {
            diskUsageCheckbox.state = AppDelegate.userSettings.settings.disk.showDiskUsage ? .on : .off
        }
    }

    @IBOutlet private var hideUsedSpaceCheckbox: NSButton! {
        didSet {
            diskUsageCheckbox.state = AppDelegate.userSettings.settings.disk.hideUsedSpace ? .on : .off
        }
    }

    // MARK: -
    // MARK: Function Overrides
    override func updateGUIComponents() {
        // Call didSet methods of all GUI components
        self.diskUsageCheckbox = { self.diskUsageCheckbox }()
        self.hideUsedSpaceCheckbox = { self.hideUsedSpaceCheckbox }()
    }

    // MARK: -
    // MARK: Actions

    @IBAction private func diskUsageCheckboxChanged(_ sender: NSButton) {
        // get the boolean value of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user setting
        AppDelegate.userSettings.settings.disk.showDiskUsage = activated

        if activated {
            AppDelegate.menuBarItemManager.diskUsage.show()
        } else {
            AppDelegate.menuBarItemManager.diskUsage.hide()
        }

        DDLogInfo("Did set disk checkbox value to (\(activated))")
    }

    @IBAction private func hideUsedSpaceChanged(_ sender: NSButton) {
        // get the boolean value of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user setting
        AppDelegate.userSettings.settings.disk.hideUsedSpace = activated

        // update the menu bar items to visualize the change
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Did set hide used space checkbox value to (\(activated))")
    }
}
