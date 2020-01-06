//
//  DashboardViewController.swift
//  iGlance
//
//  Created by Dominik on 19.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

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

    /** Variable that ensures that the system information in the dashboard is set only once on startup. */
    private static var didSetSystemInfo: Bool = false

    // MARK: -
    // MARK: Function Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // set the info for all the dashboard boxes
        self.updateUptimeInfo()
        self.setSystemInfo()
        self.setBatteryInfo()
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Sets the values in the uptime dashboard box.
     */
    private func updateUptimeInfo() {
        // get the system uptime in seconds
        let uptime = SystemInfo.getSystemUptime()

        daysUptimeLabel.stringValue = "\(uptime.days) days"
        hoursUptimeLabel.stringValue = "\(uptime.hours) hours"
    }

    /**
     * Sets the system information on the system dashboard box.
     */
    private func setSystemInfo() {
        // prevent future executions
        if DashboardViewController.self.didSetSystemInfo {
            return
        }

        // set the variable on the first call
        DashboardViewController.self.didSetSystemInfo = true

        // set the cpu name
        let cpuName = SystemInfo.cpu.getCpuName()
        // remove the intel core branding
        cpuNameLabel.stringValue = cpuName.replacingOccurrences(of: "Intel(R) Core(TM) ", with: "")

        // set the gpu name
        gpuNameLabel.stringValue = SystemInfo.gpu.getGpuName()

        // set the ram size
        ramSizeLabel.stringValue = "\(SystemInfo.getRamSize()) GB"

        let diskSize = SystemInfo.disk.getInternalDiskSize()
        diskSizeLabel.stringValue = "\(diskSize.0) \(diskSize.1)"
    }

    /**
     * Sets the battery information on the battery dashboard box.
     */
    private func setBatteryInfo() {
        // set the health of the battery
        batteryHealthLabel.stringValue = "\(Int(SystemInfo.battery.getBatteryHealth() * 100.0))%"

        // set the cycle count of the battery
        batteryCyclesLabel.stringValue = "\(SystemInfo.battery.getBatteryCycles())"
    }
}
