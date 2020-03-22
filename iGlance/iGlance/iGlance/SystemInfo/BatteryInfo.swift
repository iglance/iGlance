//
//  Battery.swift
//  iGlance
//
//  Created by Dominik on 05.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import IOKit.ps
import SystemKit
import CocoaLumberjack

class BatteryInfo {
    // MARK: -
    // MARK: Structure Definitions

    /**
     * Structure that contains the remaining time of the battery.
     */
    struct RemainingBatteryTime {
        /// The remaining minutes of the battery
        var minutes: Int
        /// The remaining hours of the battery
        var hours: Int
        /// The error code of the function reading the battery time. Is either `kIOPSTimeRemainingUnknown`, `kIOPSTimeRemainingUnlimited` or `0` if the remaining battery time could be estimated.
        var errorCode: Double
    }

    // MARK: -
    // MARK: Private Variables
    private var skBattery = SKBattery()

    // MARK: -
    // MARK: Initializer & Deinitializer
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

    // MARK: -
    // MARK: Instance Methods

    /**
     * Returns the health of the battery in percent (in the range [0,1]).
     */
    func getBatteryHealth() -> Float {
        if !skBattery.connectionIsOpen() {
            DDLogError("Can't get battery health because there is no open connection to the battery")
            return 0
        }

        let maxCap = self.skBattery.maxCapactiy()
        let designCap = self.skBattery.designCapacity()

        DDLogInfo("Read maximum capacity \(maxCap) and design capacity \(designCap) of battery")

        return Float(maxCap) / Float(designCap)
    }

    /**
     * Returns the cycle count of the battery.
     */
    func getBatteryCycles() -> Int {
        if !skBattery.connectionIsOpen() {
            DDLogError("Can't get battery cycles because there is no open connection to the battery")
            return 0
        }

        let cycleCount = self.skBattery.cycleCount()
        DDLogInfo("Read the cycle count of the battery \(cycleCount)")
        return cycleCount
    }

    /**
     * Returns the estimated time until all power sources are empty
     */
    func getRemainingBatteryTime() -> RemainingBatteryTime {
        // get the remaining time in seconds
        let remaining: CFTimeInterval = IOPSGetTimeRemainingEstimate()

        switch remaining {
        case kIOPSTimeRemainingUnknown:
            DDLogInfo("The remaining battery time is unknown")
            // return zero as time
            return RemainingBatteryTime(minutes: 0, hours: 0, errorCode: kIOPSTimeRemainingUnknown)
        case kIOPSTimeRemainingUnlimited:
            DDLogInfo("The system has access to an unlimited power source (AC)")
            return RemainingBatteryTime(minutes: 0, hours: 0, errorCode: kIOPSTimeRemainingUnlimited)
        default:
            DDLogInfo("Remaining battery time is \(remaining) seconds")

            // calculate the remaining minutes and hours
            let remainingMinutes = Int(floor(remaining / 60))
            let hours = remainingMinutes / 60
            let minutes = remainingMinutes % 60

            return RemainingBatteryTime(minutes: minutes, hours: hours, errorCode: 0)
        }
    }

    /**
     * Returns the remaining battery charge in percentage (between 0 and 100). The function returns nil if an error occurred.
     */
    func getRemainingCharge() -> Int? {
        // get the power source handles
        let psSnapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let psHandles = IOPSCopyPowerSourcesList(psSnapshot).takeRetainedValue() as Array

        for psHandle in psHandles {
            // get the power source info
            if let psInfo = IOPSGetPowerSourceDescription(psSnapshot, psHandle).takeRetainedValue() as? [String: AnyObject] {
                guard let name = psInfo[kIOPSNameKey] as? String else {
                    DDLogError("Could not read the name of the power source")
                    return nil
                }

                guard let currentCapacity = psInfo[kIOPSCurrentCapacityKey] as? Int else {
                    DDLogInfo("Failed to read the current capacity of the power source with the name \(name)")
                    return nil
                }

                if name == "InternalBattery-0" {
                    return currentCapacity
                }
            }
        }

        // if we got to this point in the function something went wrong
        DDLogError("Could not read the power source info")
        return nil
    }
}
