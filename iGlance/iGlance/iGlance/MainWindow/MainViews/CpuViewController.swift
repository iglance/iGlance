//
//  CpuViewController.swift
//  iGlance
//
//  Created by Dominik on 31.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

public enum GraphKind: Codable {
    case line
    case bar

    enum Key: CodingKey {
        case rawValue
    }

    enum CodingError: Error {
        case unknownValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .line
        case 1:
            self = .bar
        default:
            throw CodingError.unknownValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .line:
            try container.encode(0, forKey: .rawValue)
        case .bar:
            try container.encode(1, forKey: .rawValue)
        }
    }
}

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

    @IBOutlet private var usageColorWell: NSColorWell! {
        didSet {
            usageColorWell.color = AppDelegate.userSettings.settings.cpu.usageGraphColor.nsColor
        }
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
        AppDelegate.userSettings.settings.cpu.showTemperature = activated

        // show or hide the menu bar item
        if activated {
            AppDelegate.menuBarItemManager.cpuUsage.show()
        } else {
            AppDelegate.menuBarItemManager.cpuUsage.hide()
        }

        DDLogInfo("Did set cpu usage checkbox value to (\(activated))")
    }

    @IBAction private func graphSelectorChanged(_ sender: NSPopUpButton) {
        // set the user settings accordingly
        switch graphSelector.indexOfSelectedItem {
        case 1:
            // the first item is the line graph option
            AppDelegate.userSettings.settings.cpu.usageGraphKind = .line
        default:
            // default to the bar graph option
            AppDelegate.userSettings.settings.cpu.usageGraphKind = .bar
        }

        // update the menu bar items to make the change visible immediatley
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Selected cpu usage graph kind \(AppDelegate.userSettings.settings.cpu.usageGraphKind)")
    }

    @IBAction private func usageColorWellChanged(_ sender: NSColorWell) {
        // set the color of the usage bar
        AppDelegate.userSettings.settings.cpu.usageGraphColor = CodableColor(nsColor: sender.color)

        // update the menu bar items to make the change visible immediatley
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Changed usage bar color to (\(sender.color.toHex()))")
    }
}
