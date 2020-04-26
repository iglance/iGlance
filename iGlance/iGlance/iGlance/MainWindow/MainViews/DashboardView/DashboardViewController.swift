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

class DashboardViewController: MainViewViewController {
    // MARK: -
    // MARK: Outlets
    @IBOutlet private var daysUptimeLabel: NSTextField!
    @IBOutlet private var hoursUptimeLabel: NSTextField!

    @IBOutlet private var cpuNameLabel: NSTextField!
    @IBOutlet private var gpuNameLabel: NSTextField!
    @IBOutlet private var ramSizeLabel: NSTextField!
    @IBOutlet private var diskSizeLabel: NSTextField!

    @IBOutlet private var batteryHealthLabel: NSTextField!
    @IBOutlet private var batteryCyclesLabel: NSTextField!

    // MARK: -
    // MARK: Private Variables

    // the variables for the system info on the dashboard
    // these are static such that when the user selects another main view the values are preserved
    private static var cpuName: String?
    private static var gpuName: String?
    private static var ramSize: String?
    private static var diskSize: String?

    // MARK: -
    // MARK: Function Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // set the info for all the dashboard boxes
        self.updateUptimeInfo()
        self.setSystemInfo()
        self.setBatteryInfo()

        DDLogInfo("Dashboard view did load")
    }

    override func updateGUIComponents() {
        // do nothing, since we don't need to update the GUI here
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Sets the values in the uptime dashboard box.
     */
    private func updateUptimeInfo() {
        // get the system uptime in seconds
        let uptime = AppDelegate.systemInfo.getSystemUptime()

        daysUptimeLabel.stringValue = "\(uptime.days) days"
        hoursUptimeLabel.stringValue = "\(uptime.hours) hours"

        DDLogInfo("Updated uptime info")
    }

    /**
     * Sets the system information on the system dashboard box.
     */
    private func setSystemInfo() {
        if DashboardViewController.cpuName == nil {
            // set the cpu name
            let cpuName = AppDelegate.systemInfo.cpu.getCpuName()
            // remove the intel core branding
            DashboardViewController.cpuName = cpuName.replacingOccurrences(of: "Intel(R) Core(TM) ", with: "")
        }
        cpuNameLabel.stringValue = DashboardViewController.cpuName!

        if DashboardViewController.gpuName == nil {
            // set the gpu name
            DashboardViewController.gpuName = AppDelegate.systemInfo.gpu.getGpuName()
        }
        gpuNameLabel.stringValue = DashboardViewController.gpuName!

        if DashboardViewController.ramSize == nil {
            // set the ram size
            DashboardViewController.ramSize = "\(AppDelegate.systemInfo.memory.getTotalMemorySize()) GB"
        }
        ramSizeLabel.stringValue = DashboardViewController.ramSize!

        if DashboardViewController.diskSize == nil {
            let (usedSpace, freeSpace) = DiskInfo.getFreeDiskUsageInfo()
            let diskSize = convertToCorrectUnit(bytes: (usedSpace + freeSpace))
            let sizeString = diskSize.unit <= .Gigabyte ? String(Int(diskSize.value)) : String(format: "%.2f", diskSize.value)
            DashboardViewController.diskSize = "\(sizeString) \(diskSize.unit.rawValue)"
        }
        diskSizeLabel.stringValue = DashboardViewController.diskSize!

        DDLogInfo("Updated system info")
    }

    /**
     * Sets the battery information on the battery dashboard box.
     */
    private func setBatteryInfo() {
        // set the health of the battery
        batteryHealthLabel.stringValue = "\(Int(AppDelegate.systemInfo.battery.getBatteryHealth() * 100.0))%"

        // set the cycle count of the battery
        batteryCyclesLabel.stringValue = "\(AppDelegate.systemInfo.battery.getBatteryCycles())"

        DDLogInfo("Updated battery info")
    }
}
