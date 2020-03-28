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

import Foundation
import CocoaLumberjack
import SystemKit
import SMCKit

class SystemInfo {
    // MARK: -
    // MARK: Structure Definitions
    struct TimeDuration {
        let days: Int
        let hours: Int
        let minutes: Int
        let seconds: Int
    }

    // MARK: -
    // MARK: Instance Variables
    let skSystem: SKSystem

    // MARK: -
    // MARK: Static Variables
    let cpu: CpuInfo
    let gpu: GpuInfo
    let disk: DiskInfo
    let battery: BatteryInfo
    let memory: MemoryInfo
    let fan: FanInfo
    let network: NetworkInfo

    init() {
        self.skSystem = SKSystem()

        self.cpu = CpuInfo(skSystem: self.skSystem)
        self.gpu = GpuInfo()
        self.disk = DiskInfo()
        self.battery = BatteryInfo()
        self.memory = MemoryInfo()
        self.fan = FanInfo()
        self.network = NetworkInfo()

        // open the connection to the SMC
        do {
            try SMCKit.open()
        } catch SMCKit.SMCError.driverNotFound {
            DDLogError("Could not find the SMC driver.")
        } catch {
            DDLogError("Failed to open a connection to the SMC")
        }
    }

    deinit {
        // close the connection to the SMC
        if !SMCKit.close() {
            DDLogError("Failed to close the connection to the SMC")
        }
    }

    // MARK: -
    // MARK: Static Functions
    /**
     * Returns uptime of the system since the last boot.
     */
    func getSystemUptime() -> TimeDuration {
        // taken from https://stackoverflow.com/a/45068046/9717671

        var uptime = timespec()

        if clock_gettime(CLOCK_MONOTONIC_RAW, &uptime) != 0 {
            DDLogError("Could not retrieve system uptime")
            return TimeDuration(days: 0, hours: 0, minutes: 0, seconds: 0)
        }

        DDLogInfo("Raw uptime value: \(uptime)")

        let seconds = uptime.tv_sec % 60
        let minutes = (uptime.tv_sec / 60) % 60
        let hours = (uptime.tv_sec / 3600) % 24
        let days = uptime.tv_sec / (60 * 60 * 24)

        let uptimeDuration = TimeDuration(days: days, hours: hours, minutes: minutes, seconds: seconds)
        DDLogInfo("Got the system uptime: \(uptimeDuration)")

        return uptimeDuration
    }
}
