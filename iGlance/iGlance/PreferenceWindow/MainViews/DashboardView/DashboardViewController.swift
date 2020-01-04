//
//  DashboardViewController.swift
//  iGlance
//
//  Created by Dominik on 19.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class DashboardViewController: MainViewViewController {

    @IBOutlet weak var daysUptimeLabel: NSTextField!
    @IBOutlet weak var hoursUptimeLabel: NSTextField!

    @IBOutlet weak var cpuNameLabel: NSTextField!
    @IBOutlet weak var gpuNameLabel: NSTextField!
    @IBOutlet weak var ramSizeLabel: NSTextField!
    @IBOutlet weak var diskSizeLabel: NSTextField!

    private static var didSetSystemInfo: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateUptimeInfo()

        // since those values will not change fetch them in the initializer
        self.setSystemInfo()
    }

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

}
