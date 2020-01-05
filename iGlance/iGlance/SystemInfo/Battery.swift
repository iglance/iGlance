//
//  Battery.swift
//  iGlance
//
//  Created by Dominik on 05.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import SystemKit
import os.log

class Battery {
    private var skBattery = SKBattery()

    init() {
        if skBattery.open() != kIOReturnSuccess {
            os_log("Opening a connection to the battery failed", type: .error)
        }
    }

    deinit {
        if skBattery.close() != kIOReturnSuccess {
            os_log("Closing the connection to the battery failed", type: .error)
        }
    }

    /**
     * Returns the health of the battery in percent (in the range [0,1]).
     */
    func getBatteryHealth() -> Float {
        if !skBattery.connectionIsOpen() {
            os_log("Can't get battery health because there is no open connection to the battery", type: .error)
            return 0
        }

        return Float(self.skBattery.maxCapactiy()) / Float(self.skBattery.designCapacity())
    }

    /**
     * Returns the cycle count of the battery.
     */
    func getBatteryCycles() -> Int {
        if !skBattery.connectionIsOpen() {
            os_log("Can't get battery cycles because there is no open connection to the battery", type: .error)
            return 0
        }

        return self.skBattery.cycleCount()
    }
}
