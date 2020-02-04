//
//  Battery.swift
//  iGlance
//
//  Created by Dominik on 05.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import SystemKit
import CocoaLumberjack

class BatteryInfo {
    private var skBattery = SKBattery()

    init() {
        if skBattery.open() != kIOReturnSuccess {
            DDLogError("Opening a connection to the battery failed")
        }
    }

    deinit {
        if skBattery.close() != kIOReturnSuccess {
            DDLogError("Closing the connection to the battery failed")
        }
    }

    /**
     * Returns the health of the battery in percent (in the range [0,1]).
     */
    func getBatteryHealth() -> Float {
        if !skBattery.connectionIsOpen() {
            DDLogError("Can't get battery health because there is no open connection to the battery")
            return 0
        }

        return Float(self.skBattery.maxCapactiy()) / Float(self.skBattery.designCapacity())
    }

    /**
     * Returns the cycle count of the battery.
     */
    func getBatteryCycles() -> Int {
        if !skBattery.connectionIsOpen() {
            DDLogError("Can't get battery cycles because there is no open connection to the battery")
            return 0
        }

        return self.skBattery.cycleCount()
    }
}
