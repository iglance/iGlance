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

class MemoryInfo {
    /**
     * Returns the usage of the RAM in GB.
     */
    func getMemoryUsage() -> (free: Double, active: Double, inactive: Double, wired: Double, compressed: Double, appMemory: Double) {
        let usage = SKSystem.memoryUsage()

        DDLogInfo("Read memory usage: \(usage)")

        let totalMemory = Double(getTotalMemorySize())
        let usedMemory = Double(usage.appMemory + usage.compressed + usage.wired)
        let freeMemory = Double(totalMemory - usedMemory)
        return (freeMemory, usage.active, usage.inactive, usage.wired, usage.compressed, usage.appMemory)
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
