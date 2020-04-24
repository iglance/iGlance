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

class FanViewController: MainViewViewController {
    // MARK: -
    // MARK: Outlets

    @IBOutlet private var fanSpeedCheckbox: NSButton! {
        didSet {
            fanSpeedCheckbox.state = AppDelegate.userSettings.settings.fan.showFanSpeed ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBOutlet private var fanSpeedUnitCheckbox: NSButton! {
        didSet {
            fanSpeedUnitCheckbox.state = AppDelegate.userSettings.settings.fan.showFanSpeedUnit ? NSButton.StateValue.on : NSButton.StateValue.off
            fanSpeedUnitCheckbox.isHidden = (fanSpeedCheckbox.state == .off)
        }
    }

    // MARK: -
    // MARK: Function Overrides
    override func updateGUIComponents() {
        // Call didSet methods of all GUI components
        self.fanSpeedCheckbox = { self.fanSpeedCheckbox }()
        self.fanSpeedUnitCheckbox = { self.fanSpeedUnitCheckbox }()
    }

    // MARK: -
    // MARK: Actions

    @IBAction private func fanSpeedCheckboxChanged(_ sender: NSButton) {
        // get the boolean value of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // depending on the state of the checkbox hide or show the unit checkbox
        fanSpeedUnitCheckbox.isHidden = !activated

        // set the user setting
        AppDelegate.userSettings.settings.fan.showFanSpeed = activated

        if activated {
            AppDelegate.menuBarItemManager.fan.show()
        } else {
            AppDelegate.menuBarItemManager.fan.hide()
        }

        DDLogInfo("Did set fan speed checkbox value to (\(activated))")
    }

    @IBAction private func fanSpeedUnitCheckboxChanged(_ sender: NSButton) {
        // get the boolean value of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user setting
        AppDelegate.userSettings.settings.fan.showFanSpeedUnit = activated

        // update the menu bar items to visualize the change
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Did set fan speed unit checkbox value to (\(activated))")
    }
}
