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

class CpuViewController: MainViewViewController {
    // MARK: -
    // MARK: Outlets

    @IBOutlet private var cpuTempCheckbox: NSButton! {
        didSet {
            cpuTempCheckbox.state = AppDelegate.userSettings.settings.cpu.showTemperature ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    @IBOutlet private var cpuUsageCheckbox: NSButton! {
        didSet {
            cpuUsageCheckbox.state = AppDelegate.userSettings.settings.cpu.showUsage ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBOutlet private var graphSelector: NSPopUpButton! {
        didSet {
            switch AppDelegate.userSettings.settings.cpu.usageGraphKind {
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
            // depending on the current kind of graph display the slider
            switch AppDelegate.userSettings.settings.cpu.usageGraphKind {
            case .line:
                // line graph is the second option
                graphWidthStackView.isHidden = false
            default:
                // bar graph is the first option
                graphWidthStackView.isHidden = true
            }

            // if the cpu usage is not shown at all hide the slider
            if !AppDelegate.userSettings.settings.cpu.showUsage {
                graphWidthStackView.isHidden = true
            }
        }
    }

    @IBOutlet private var graphWidthLabel: NSTextField! {
        didSet {
            graphWidthLabel.stringValue = String(AppDelegate.userSettings.settings.cpu.usageLineGraphWidth)
        }
    }

    @IBOutlet private var graphWidthSlider: NSSlider! {
        didSet {
            graphWidthSlider.intValue = Int32(AppDelegate.userSettings.settings.cpu.usageLineGraphWidth)
        }
    }

    @IBOutlet private var usageColorWell: NSColorWell! {
        didSet {
            usageColorWell.color = AppDelegate.userSettings.settings.cpu.usageGraphColor.nsColor
        }
    }

    @IBOutlet private var usageGraphBorderCheckbox: NSButton! {
        didSet {
            usageGraphBorderCheckbox.state = AppDelegate.userSettings.settings.cpu.showUsageGraphBorder ? NSButton.StateValue.on : NSButton.StateValue.off

            // if the cpu usage is not displayed hide it
            if !AppDelegate.userSettings.settings.cpu.showUsage {
                usageGraphBorderCheckbox.isHidden = true
            }
        }
    }

    @IBOutlet private var colorGradientCheckbox: NSButton! {
        didSet {
            colorGradientCheckbox.state = AppDelegate.userSettings.settings.cpu.colorGradientSettings.useGradient ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBOutlet private var secondaryColorWell: NSColorWell! {
        didSet {
            secondaryColorWell.color = AppDelegate.userSettings.settings.cpu.colorGradientSettings.secondaryColor.nsColor
        }
    }

    @IBOutlet private var graphSelectionStackView: NSStackView! {
        didSet {
            // if the cpu usage is not displayed hide it
            if !AppDelegate.userSettings.settings.cpu.showUsage {
                graphSelectionStackView.isHidden = true
            }
        }
    }

    @IBOutlet private var graphColorStackView: NSStackView! {
        didSet {
            // if the cpu usage is not displayed hide it
            if !AppDelegate.userSettings.settings.cpu.showUsage {
                graphColorStackView.isHidden = true
            }
        }
    }

    @IBOutlet private var secondaryColorStackView: NSStackView! {
        didSet {
            // if the cpu usage is not displayed hide it
            if !AppDelegate.userSettings.settings.cpu.showUsage {
                secondaryColorStackView.isHidden = true
            }
        }
    }

    // MARK: -
    // MARK: Function Overrides
    override func updateGUIComponents() {
        // Call didSet methods of all GUI components
        self.cpuTempCheckbox = { self.cpuTempCheckbox }()
        self.cpuUsageCheckbox = { self.cpuUsageCheckbox }()
        self.graphSelector = { self.graphSelector }()
        self.graphWidthStackView = { self.graphWidthStackView }()
        self.graphWidthLabel = { self.graphWidthLabel }()
        self.graphWidthSlider = { self.graphWidthSlider }()
        self.usageColorWell = { self.usageColorWell }()
        self.usageGraphBorderCheckbox = { self.usageGraphBorderCheckbox }()
        self.colorGradientCheckbox = { self.colorGradientCheckbox }()
        self.secondaryColorWell = { self.secondaryColorWell }()
        self.graphSelectionStackView = { self.graphSelectionStackView }()
        self.graphColorStackView = { self.graphColorStackView }()
        self.secondaryColorStackView = { self.secondaryColorStackView }()
    }

    // MARK: -
    // MARK: Actions

    @IBAction private func cpuTempCheckboxChanged(_ sender: NSButton) {
        // get the boolean to the current state of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user settings
        AppDelegate.userSettings.settings.cpu.showTemperature = activated

        // show or hide the menu bar item
        if activated {
            AppDelegate.menuBarItemManager.cpuTemp.show()
        } else {
            AppDelegate.menuBarItemManager.cpuTemp.hide()
        }

        DDLogInfo("Did set cpu temp checkbox value to (\(activated))")
    }

    @IBAction private func cpuUsageCheckboxChanged(_ sender: NSButton) {
        // get the boolean to the current state of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user settings
        AppDelegate.userSettings.settings.cpu.showUsage = activated

        // show or hide the menu bar item
        if activated {
            AppDelegate.menuBarItemManager.cpuUsage.show()
        } else {
            AppDelegate.menuBarItemManager.cpuUsage.hide()
        }

        // show  or hide all the other settings for the cpu usage
        graphSelectionStackView.isHidden = !activated
        graphWidthStackView.isHidden = (AppDelegate.userSettings.settings.cpu.usageGraphKind == .bar) || !activated
        graphColorStackView.isHidden = !activated
        usageGraphBorderCheckbox.isHidden = !activated
        secondaryColorStackView.isHidden = !activated

        DDLogInfo("Did set cpu usage checkbox value to (\(activated))")
    }

    @IBAction private func graphSelectorChanged(_ sender: NSPopUpButton) {
        // set the user settings accordingly
        switch graphSelector.indexOfSelectedItem {
        case 1:
            // the first item is the line graph option
            AppDelegate.userSettings.settings.cpu.usageGraphKind = .line
            graphWidthStackView.isHidden = false
        default:
            // default to the bar graph option
            AppDelegate.userSettings.settings.cpu.usageGraphKind = .bar
            graphWidthStackView.isHidden = true
        }

        // update the menu bar items to make the change visible immediatley
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Selected cpu usage graph kind \(AppDelegate.userSettings.settings.cpu.usageGraphKind)")
    }

    @IBAction private func graphWidthSliderChanged(_ sender: NSSlider) {
        // update the width label
        graphWidthLabel.intValue = sender.intValue

        // update the user settings
        AppDelegate.userSettings.settings.cpu.usageLineGraphWidth = Int(sender.intValue)

        // update the width of the menu bar item
        AppDelegate.menuBarItemManager.cpuUsage.lineGraph.setGraphWidth(width: Int(sender.intValue))
        // rerender the menu bar item
        AppDelegate.menuBarItemManager.cpuUsage.update()
    }

    @IBAction private func usageColorWellChanged(_ sender: NSColorWell) {
        // set the color of the usage bar
        AppDelegate.userSettings.settings.cpu.usageGraphColor = CodableColor(nsColor: sender.color)

        // clear the cache of the bar graph
        AppDelegate.menuBarItemManager.cpuUsage.barGraph.clearImageCache()

        // update the menu bar items to make the change visible immediately
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Changed usage bar color to (\(sender.color.toHex()))")
    }

    @IBAction private func usageGraphBorderCheckboxChanged(_ sender: NSButton) {
        // get the boolean to the current state of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user settings
        AppDelegate.userSettings.settings.cpu.showUsageGraphBorder = activated

        // clear the cache of the bar graph
        AppDelegate.menuBarItemManager.cpuUsage.barGraph.clearImageCache()

        // update the menu bar items to make the change visible immediately
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Did set graph border checkbox value to (\(activated))")
    }

    @IBAction private func colorGradientCheckboxChanged(_ sender: NSButton) {
        // get the boolean to the current state of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user setting
        AppDelegate.userSettings.settings.cpu.colorGradientSettings.useGradient = activated

        // clear the cache of the bar graph
        AppDelegate.menuBarItemManager.cpuUsage.barGraph.clearImageCache()

        // update the menu bar items to make the change visible immediately
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Did set color gradient checkbox value to (\(activated))")
    }

    @IBAction private func secondaryColorWellChanged(_ sender: NSColorWell) {
        // set the secondary color
        AppDelegate.userSettings.settings.cpu.colorGradientSettings.secondaryColor = CodableColor(nsColor: sender.color)

        // clear the cache of the bar graph
        AppDelegate.menuBarItemManager.cpuUsage.barGraph.clearImageCache()

        // update the menu bar items to visualize the change
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Changed usage gradient color to (\(sender.color.toHex()))")
    }
}
