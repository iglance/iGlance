//
//  CpuInfo.swift
//  iGlance
//
//  Created by Dominik on 24.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Foundation

class CpuInfo {

    /**
     * Returns the brand name of the cpu.
     */
    func getCpuName() -> String {
        // taken from https://stackoverflow.com/a/18099669/9717671

        // get the length of the cpu name
        var stringSize = 0
        if sysctlbyname("machdep.cpu.brand_string", nil, &stringSize, nil, 0) != 0 {
            fatalError("Could not get the length of the cpu name")
        }

        var cpuName = [CChar](repeating: 0, count: Int(stringSize))
        if sysctlbyname("machdep.cpu.brand_string", &cpuName, &stringSize, nil, 0) != 0 {
            fatalError("Could not get the name of the cpu")
        }

        return String(cString: cpuName)
    }
}
