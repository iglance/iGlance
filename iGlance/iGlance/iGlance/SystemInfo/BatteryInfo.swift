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

enum PowerSourceState {
    /// power source is drawing internal power
    case sourceIsDrawingPower
    /// power source is connected to external power source
    case connectedToPowerSource
    /// power source is no longer connected (offline)
    case offline
}

enum PowerSourceHealth {
    case good
    case fair
    case poor
}

/**
 * How the power source conveys power source data to the machine
 */
enum PowerSourceTransportType {
    case usbType
    case networkType
    case serialType
    case internalType
}

/**
 * The type of power source.
 */
enum PowerSourceType {
    case ups
    case internalBattery
}

/**
 * All the information about a power source
 * - Tag: PowerSourceInfo
 */
struct PowerSourceInfo {
    /// The health of the battery. Possible values are `kIOPSGoodValue`, `kIOPSFairValue` or `kIOPSPoorValue`
    var health: PowerSourceHealth?
    /// The current of the battery in mA
    var current: Int?
    /// The current capacity of the battery in percent or mAh
    var currentCapacity: Int?
    /// The number of cycles the battery was designed for
    var charging: Bool?
    /// Whether the battery is fully charged
    var isCharged: Bool?
    /// Whether the battery is currently present
    var present: Bool?
    /// The maximum capacity of the battery in percentage (usually 100%)
    var maxCapacity: Int?
    /// The name of the battery
    var name: String?
    /// The state of the battery
    var state: PowerSourceState?
    /// The remaining time in minutes until the batter is empty. A value of -1 indicates that the time is still calculated.
    var timeToEmpty: Int?
    /// The remaining time in minutes until the battery is fully charged. A value of -1 indicates that the time is still calculated
    var timeToFullCharge: Int?
    /// The transport type of the battery
    var transportType: PowerSourceTransportType?
    /// The type of the battery
    var type: PowerSourceType?
}

/// - Tag: InternalBatteryState
enum InternalBatteryState {
    /// The remaining time until empty or fully charged is calculated
    case calculatingRemainingTime
    /// The battery is plugged in but is not charging
    case notCharging
    /// The battery is plugged in and is fully charged
    case fullyCharged
    /// The battery is discharging and can provide a time estimate
    case discharging
    /// The battery is not fully charged, is plugged in and can provide an estimate for when it will be fully charged.
    case charging
    /// The  battery has an unknown state
    case unknown
}

class BatteryInfo {
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
     * Returns the estimated time in minutes until the internal battery is empty. A value of -1 indicates that the time is still calculated.
     */
    func timeToEmpty() -> Int {
        // get the battery info
        let batInfo = getInternalBatteryInfo()

        if let timeToEmpty = batInfo?.timeToEmpty {
            DDLogInfo("Time until battery is empty: \(timeToEmpty)")
            return timeToEmpty
        }

        DDLogError("Time to empty is nil and therefore not available")
        return 0
    }

    /**
     * Returns the estimated time in minutes until the internal battery is empty. A value of -1 indicates that the time is still calculated.
     */
    func timeToFullCharge() -> Int {
        let batInfo = getInternalBatteryInfo()

        if let timeToFullCharge = batInfo?.timeToFullCharge {
            DDLogInfo("Battery time to full charge: \(timeToFullCharge)")
            return timeToFullCharge
        }

        DDLogError("Time to full charge is nil and therefore not available")
        return 0
    }

    /**
     * Returns true if the computer is connected to AC, returns false otherwise.
     */
    func isOnAC() -> Bool {
        let onAC = skBattery.isACPowered()

        DDLogInfo("Battery isOnAC value: \(onAC)")
        return onAC
    }

    /**
     * Returns true if the battery is currently charging, returns false otherwise.
     */
    func isCharging() -> Bool {
        let isCharging = skBattery.isCharging()

        DDLogInfo("Battery isCharging value: \(isCharging)")
        return isCharging
    }

    /**
     * Returns true if the battery is fully charged, returns false otherwise.
     */
    func isFullyCharged() -> Bool {
        let batInfo = getInternalBatteryInfo()

        if let isCharged = batInfo?.isCharged {
            DDLogInfo("Battery isFullyCharged value: \(isCharged)")
            return isCharged
        }

        DDLogError("Failed to calculate whether the battery is fully charged")
        return false
    }

    /**
     * Returns the current charge of the battery in percentage (value between 0 and 100).
     */
    func getCharge() -> Int {
        let batInfo = getInternalBatteryInfo()

        if let currentCapacity = batInfo?.currentCapacity {
            DDLogInfo("Battery current capacity value: \(currentCapacity)")
            return currentCapacity
        }

        DDLogError("Failed to read the current capacity of the battery")
        return 0
    }

    /**
     * Returns the state of the battery and returns a value of [InternalBatteryState](x-source-tag://InternalBatteryState).
     */
    func getInternalBatteryState() -> InternalBatteryState {
        let timeToEmptyMinutes = timeToEmpty()
        let timeToFullMinutes = timeToFullCharge()
        let onAC = isOnAC()
        let charging = isCharging()
        let fullyCharged = isFullyCharged()

        if !onAC && timeToEmptyMinutes == -1 || onAC && timeToFullMinutes == -1 {
            // if the machine is not charging and no time is available, the time is calculated
            return .calculatingRemainingTime
        } else if onAC &&  !charging {
            // if the machine is on ac but the battery is not charging
            return .notCharging
        } else if onAC && fullyCharged {
            // if the machine is charging and the battery is fully charged
            return .fullyCharged
        } else if onAC && timeToFullMinutes != -1 {
            return .charging
        } else if !onAC && timeToEmptyMinutes != -1 {
            return .discharging
        }

        return .unknown
    }

    /**
     * Returns the [PowerSourceInfo](x-source-tag://PowerSourceInfo) of the internal battery.
     */
    func getInternalBatteryInfo() -> PowerSourceInfo? {
        let batteryInfo = getPowerSourceInfo().first { $0.name == "InternalBattery-0" }

        DDLogInfo("The power source info object of the internal battery: \(String(describing: batteryInfo))")
        return batteryInfo
    }

    /**
     * Returns the info about all the connected power sources.
     */
    func getPowerSourceInfo() -> [PowerSourceInfo] {
        // get the power source handles
        let psInfo = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let psHandles = IOPSCopyPowerSourcesList(psInfo).takeRetainedValue() as [CFTypeRef]

        var batteryInfoArray: [PowerSourceInfo] = []

        for psHandle in psHandles {
            // get the power source info
            if let psInfo = IOPSGetPowerSourceDescription(psInfo, psHandle).takeUnretainedValue() as? [String: AnyObject] {
                // create a new battery information struct
                var batInfo = PowerSourceInfo()

                if let health = psInfo[kIOPSBatteryHealthKey] as? String {
                    switch health {
                    case kIOPSGoodValue:
                        batInfo.health = .good
                    case kIOPSFairValue:
                        batInfo.health = .fair
                    default:
                        batInfo.health = .poor
                    }
                }

                batInfo.current = psInfo[kIOPSCurrentKey] as? Int

                batInfo.currentCapacity = psInfo[kIOPSCurrentCapacityKey] as? Int

                batInfo.charging = psInfo[kIOPSIsChargedKey] as? Bool

                // if the key is not present the battery is not charged
                batInfo.isCharged = psInfo[kIOPSIsChargedKey] as? Bool ?? false

                batInfo.present = psInfo[kIOPSIsPresentKey] as? Bool

                batInfo.maxCapacity = psInfo[kIOPSMaxCapacityKey] as? Int

                batInfo.name = psInfo[kIOPSNameKey] as? String

                if let state = psInfo[kIOPSPowerSourceStateKey] as? String {
                    switch state {
                    case kIOPSBatteryPowerValue:
                        batInfo.state = .sourceIsDrawingPower
                    case kIOPSACPowerValue:
                        batInfo.state = .connectedToPowerSource
                    default:
                        batInfo.state = .offline
                    }
                }

                batInfo.timeToEmpty = psInfo[kIOPSTimeToEmptyKey] as? Int

                batInfo.timeToFullCharge = psInfo[kIOPSTimeToFullChargeKey] as? Int

                if let transportType = psInfo[kIOPSTransportTypeKey] as? String {
                    switch transportType {
                    case kIOPSUSBTransportType:
                        batInfo.transportType = .usbType
                    case kIOPSSerialTransportType:
                        batInfo.transportType = .serialType
                    case kIOPSNetworkTransportType:
                        batInfo.transportType = .networkType
                    default:
                        batInfo.transportType = .internalType
                    }
                }

                if let psType = psInfo[kIOPSTypeKey] as? String {
                    switch psType {
                    case kIOPSUPSType:
                        batInfo.type = .ups
                    default:
                        batInfo.type = .internalBattery
                    }
                }

                batteryInfoArray.append(batInfo)
            }
        }

        return batteryInfoArray
    }
}
