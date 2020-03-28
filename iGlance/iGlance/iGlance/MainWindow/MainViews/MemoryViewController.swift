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

class MemoryViewController: MainViewViewController {
    // MARK: -
    // MARK: Outlets

    @IBOutlet private var memoryUsageCheckbox: NSButton! {
        didSet {
            memoryUsageCheckbox.state = (AppDelegate.userSettings.settings.memory.showUsage ? NSButton.StateValue.on : NSButton.StateValue.off)
        }
    }

    @IBOutlet private var graphSelector: NSPopUpButton! {
        didSet {
            switch AppDelegate.userSettings.settings.memory.usageGraphKind {
            case .line:
                // line graph is the second option
                graphSelector.selectItem(at: 1)
            default:
                // bar graph is the first option
                graphSelector.selectItem(at: 0)
            }
        }
    }

    @IBOutlet private var graphWidthStackView: NSStackView! {
        didSet {
            switch AppDelegate.userSettings.settings.memory.usageGraphKind {
            case .line:
                // line graph is the second option
                graphWidthStackView.isHidden = false
            default:
                // bar graph is the first option
                graphWidthStackView.isHidden = true
            }

            // if the usage is not displayed hide it
            if !AppDelegate.userSettings.settings.memory.showUsage {
                graphWidthStackView.isHidden = true
            }
        }
    }

    @IBOutlet private var graphWidthLabel: NSTextField! {
        didSet {
            graphWidthLabel.stringValue = String(AppDelegate.userSettings.settings.memory.usageLineGraphWidth)
        }
    }

    @IBOutlet private var graphWidthSlider: NSSlider! {
        didSet {
            graphWidthSlider.intValue = Int32(AppDelegate.userSettings.settings.memory.usageLineGraphWidth)
        }
    }

    @IBOutlet private var usageColorWell: NSColorWell! {
        didSet {
            usageColorWell.color = AppDelegate.userSettings.settings.memory.usageGraphColor.nsColor
        }
    }

    @IBOutlet private var usageGraphBorderCheckbox: NSButton! {
        didSet {
            usageGraphBorderCheckbox.state = AppDelegate.userSettings.settings.memory.showUsageGraphBorder ? NSButton.StateValue.on : NSButton.StateValue.off

            // if the usage is not displayed hide it
            if !AppDelegate.userSettings.settings.memory.showUsage {
                usageGraphBorderCheckbox.isHidden = true
            }
        }
    }

    @IBOutlet private var colorGradientCheckbox: NSButton! {
        didSet {
            colorGradientCheckbox.state = AppDelegate.userSettings.settings.memory.colorGradientSettings.useGradient ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBOutlet private var secondaryColorWell: NSColorWell! {
        didSet {
            secondaryColorWell.color = AppDelegate.userSettings.settings.memory.colorGradientSettings.secondaryColor.nsColor
        }
    }

    @IBOutlet private var graphSelectorStackView: NSStackView! {
        didSet {
            // if the usage is not displayed hide it
            if !AppDelegate.userSettings.settings.memory.showUsage {
                graphSelectorStackView.isHidden = true
            }
        }
    }

    @IBOutlet private var graphColorStackView: NSStackView! {
        didSet {
            // if the usage is not displayed hide it
            if !AppDelegate.userSettings.settings.memory.showUsage {
                graphColorStackView.isHidden = true
            }
        }
    }

    @IBOutlet private var secondaryColorStackView: NSStackView! {
        didSet {
            // if the usage is not displayed hide it
            if !AppDelegate.userSettings.settings.memory.showUsage {
                secondaryColorStackView.isHidden = true
            }
        }
    }

    // MARK: -
    // MARK: Actions

    @IBAction private func memoryUsageCheckboxChanged(_ sender: NSButton) {
        // get the boolean to the current state of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user settings
        AppDelegate.userSettings.settings.memory.showUsage = activated

        // show or hide the menu bar item
        if activated {
            AppDelegate.menuBarItemManager.memoryUsage.show()
        } else {
            AppDelegate.menuBarItemManager.memoryUsage.hide()
        }

        // show or hide all the other settings for the memory usage
        graphSelectorStackView.isHidden = !activated
        graphWidthStackView.isHidden = !activated || (AppDelegate.userSettings.settings.memory.usageGraphKind == .bar)
        graphColorStackView.isHidden = !activated
        usageGraphBorderCheckbox.isHidden = !activated
        secondaryColorStackView.isHidden = !activated

        DDLogInfo("Did set memory usage checkbox value to (\(activated))")
    }

    @IBAction private func graphSelectorChanged(_ sender: NSPopUpButton) {
        // set the user settings accordingly
        switch graphSelector.indexOfSelectedItem {
        case 1:
            // the first item is the line graph option
            AppDelegate.userSettings.settings.memory.usageGraphKind = .line
            graphWidthStackView.isHidden = false
        default:
            // default to the bar graph option
            AppDelegate.userSettings.settings.memory.usageGraphKind = .bar
            graphWidthStackView.isHidden = true
        }

        // update the menu bar items to make the change visible immediately
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Selected memory usage graph kind \(AppDelegate.userSettings.settings.memory.usageGraphKind)")
    }

    @IBAction private func graphWidthSliderChanged(_ sender: NSSlider) {
        // update the width label
        graphWidthLabel.intValue = sender.intValue

        // update the user settings
        AppDelegate.userSettings.settings.memory.usageLineGraphWidth = Int(sender.intValue)

        // update the width of the menu bar item
        AppDelegate.menuBarItemManager.memoryUsage.lineGraph.setGraphWidth(width: Int(sender.intValue))
        // rerender the menu bar item
        AppDelegate.menuBarItemManager.memoryUsage.update()
    }

    @IBAction private func usageColorWellChanged(_ sender: NSColorWell) {
        // set the color of the usage bar
        AppDelegate.userSettings.settings.memory.usageGraphColor = CodableColor(nsColor: sender.color)

        // clear the cache of the bar graph
        AppDelegate.menuBarItemManager.memoryUsage.barGraph.clearImageCache()

        // update the menu bar items to make the change visible immediately
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Changed usage bar color to (\(sender.color.toHex()))")
    }

    @IBAction private func usageGraphBorderCheckboxChanged(_ sender: NSButton) {
        // get the boolean to the current state of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user settings
        AppDelegate.userSettings.settings.memory.showUsageGraphBorder = activated

        // clear the cache of the bar graph
        AppDelegate.menuBarItemManager.memoryUsage.barGraph.clearImageCache()

        // update the menu bar items to make the change visible immediately
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Did set graph border checkbox value to (\(activated))")
    }

    @IBAction private func colorGradientCheckboxChanged(_ sender: NSButton) {
        // get the boolean to the current state of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user setting
        AppDelegate.userSettings.settings.memory.colorGradientSettings.useGradient = activated

        // clear the cache of the bar graph
        AppDelegate.menuBarItemManager.memoryUsage.barGraph.clearImageCache()

        // update the menu bar items to make the change visible immediately
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Did set color gradient checkbox value to (\(activated))")
    }

    @IBAction private func secondaryColorWellChanged(_ sender: NSColorWell) {
        // set the secondary color
        AppDelegate.userSettings.settings.memory.colorGradientSettings.secondaryColor = CodableColor(nsColor: sender.color)

        // clear the cache of the bar graph
        AppDelegate.menuBarItemManager.memoryUsage.barGraph.clearImageCache()

        // update the menu bar items to visualize the change
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Changed usage gradient color to (\(sender.color.toHex()))")
    }
}
