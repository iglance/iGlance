//
//  MemoryInfo.swift
//  iGlance
//
//  Created by Dominik on 12.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack
import SystemKit

class MemoryInfo {
    /**
     * Returns the usage of the RAM
     */
    func getMemoryUsage() -> (free: Double, active: Double, inactive: Double, wired: Double, compressed: Double) {
        let usage = SKSystem.memoryUsage()

        DDLogInfo("Read memory usage: \(usage)")

        return usage
    }

    /**
     * Returns the size of the RAM in GB.
     */
    func getTotalMemorySize() -> Int {
        let ramSize = Int(ProcessInfo.processInfo.physicalMemory / 1_073_741_824)
        DDLogInfo("Got the ram size: \(ramSize)")

        return ramSize
    }
}
