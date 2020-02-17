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
    func getMemoryUsage() -> (free: Double, active: Double, inactive: Double, wired: Double, compressed: Double) {
        let usage = SKSystem.memoryUsage()

        DDLogInfo("Read memory usage: \(usage)")

        return usage
    }
}
