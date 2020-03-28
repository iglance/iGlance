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
import SMCKit
import SystemKit

class CpuInfo {
    private var skSystem: SKSystem

    init(skSystem: SKSystem) {
        self.skSystem = skSystem
    }

    /**
     * Gets the name of the cpu.
     *
     * - Returns: The name of the cpu as a string (e.g. Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz)
     */
    func getCpuName() -> String {
        // get the length of the cpu name
        var stringSize = 0
        if sysctlbyname("machdep.cpu.brand_string", nil, &stringSize, nil, 0) != 0 {
            DDLogError("Could not get the length of the cpu name")
            return ""
        }

        var cpuName = [CChar](repeating: 0, count: Int(stringSize))
        if sysctlbyname("machdep.cpu.brand_string", &cpuName, &stringSize, nil, 0) != 0 {
            DDLogError("Could not get the name of the cpu")
            return ""
        }

        DDLogInfo("Raw cpu name value: \(cpuName)")

        let cpuNameString = String(cString: cpuName)
        DDLogInfo("Got the cpu name: \(cpuNameString)")

        return cpuNameString
    }

    /**
     * Returns the cpu temperature (cpu peci temperature) as a double. If an error occured the function returns -1.0
     *
     * - Parameter unit: The unit in which the temperature should be returned.
     */
    func getCpuTemp() -> Double {
        do {
            let cpuTemp = try SMCKit.temperature(TemperatureSensors.CPU_PECI.code, unit: AppDelegate.userSettings.settings.tempUnit)

            DDLogInfo("Read cpu temperature: \(cpuTemp)")

            return cpuTemp
        } catch SMCKit.SMCError.keyNotFound {
            DDLogError("The given SMC key was not found")
        } catch SMCKit.SMCError.notPrivileged {
            DDLogError("Not privileged to read the SMC")
        } catch {
            DDLogError("An unknown error occurred")
        }

        return -1.0
    }

    /**
     * Returns the cpu usage. Each value is rounded to the nearest integer value and represents the usage in percent.
     */
    func getCpuUsage() -> (system: Int, user: Int, idle: Int, nice: Int) {
        let usage = skSystem.usageCPU()

        DDLogInfo("Read cpu usage: \(usage)")

        return (Int(round(usage.0)), Int(round(usage.1)), Int(round(usage.2)), Int(round(usage.3)))
    }
}
