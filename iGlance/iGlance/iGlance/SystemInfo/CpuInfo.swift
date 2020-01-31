//
//  CpuInfo.swift
//  iGlance
//
//  Created by Dominik on 24.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack
import SMCKit

class CpuInfo {
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
}
