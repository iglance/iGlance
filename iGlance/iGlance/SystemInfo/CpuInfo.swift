//
//  CpuInfo.swift
//  iGlance
//
//  Created by Dominik on 24.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Foundation
import os.log

class CpuInfo {
    /**
     * Gets the name of the cpu.
     *
     * - Returns: The name of the cpu as a string (e.g. Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz)
     */
    func getCpuName() -> String {
        // taken from https://stackoverflow.com/a/18099669/9717671

        // get the length of the cpu name
        var stringSize = 0
        if sysctlbyname("machdep.cpu.brand_string", nil, &stringSize, nil, 0) != 0 {
            os_log("Could not get the length of the cpu name", type: .error)
            return ""
        }

        var cpuName = [CChar](repeating: 0, count: Int(stringSize))
        if sysctlbyname("machdep.cpu.brand_string", &cpuName, &stringSize, nil, 0) != 0 {
            os_log("Could not get the name of the cpu", type: .error)
            return ""
        }

        return String(cString: cpuName)
    }
}
