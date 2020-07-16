//
//  UserSettingsTest.swift
//  iGlanceUnitTests
//
//  Created by Dominik on 01.07.20.
//  Copyright © 2020 iGlance. All rights reserved.
//

import XCTest

@testable import iGlance
import SMCKit

class UserSettingsTest: XCTestCase {
    func resetUserSettings() throws {
        // create the user settings class
        let defaultSettings = UserSettings()
        // reset the settings
        defaultSettings.resetUserSettings()

        // assert that the general settings are reset
        XCTAssertFalse(defaultSettings.settings.autostartOnBoot)
        XCTAssertEqual(defaultSettings.settings.updateInterval, 2)
        XCTAssertEqual(defaultSettings.settings.tempUnit, TemperatureUnit.celsius)

        // assert that the cpu settings are reset
        let cpuSettings = defaultSettings.settings.cpu
        XCTAssertTrue(cpuSettings.showTemperature)
        XCTAssertTrue(cpuSettings.showUsage)
        XCTAssertEqual(cpuSettings.usageGraphColor, CodableColor(nsColor: .green))
        XCTAssertEqual(cpuSettings.usageGraphKind, GraphKind.bar)
        XCTAssertEqual(cpuSettings.usageLineGraphWidth, 50)
        XCTAssertTrue(cpuSettings.showUsageGraphBorder)
        XCTAssertFalse(cpuSettings.colorGradientSettings.useGradient)
        XCTAssertEqual(cpuSettings.colorGradientSettings.secondaryColor, CodableColor(nsColor: .red))

        // assert that the memory settings are reset
        let memSettings = defaultSettings.settings.memory
        XCTAssertTrue(memSettings.showUsage)
        XCTAssertEqual(memSettings.usageGraphColor, CodableColor(nsColor: .blue))
        XCTAssertEqual(memSettings.usageGraphKind, GraphKind.bar)
        XCTAssertEqual(memSettings.usageLineGraphWidth, 50)
        XCTAssertTrue(memSettings.showUsageGraphBorder)
        XCTAssertFalse(memSettings.colorGradientSettings.useGradient)
        XCTAssertEqual(memSettings.colorGradientSettings.secondaryColor, CodableColor(nsColor: .red))

        // assert that the fan settings are reset
        let fanSettings = defaultSettings.settings.fan
        XCTAssertTrue(fanSettings.showFanSpeed)
        XCTAssertTrue(fanSettings.showFanSpeedUnit)

        // asset that the network settings are reset
        XCTAssertTrue(defaultSettings.settings.network.showBandwidth)

        // assert that the disk settings are reset
        XCTAssertTrue(defaultSettings.settings.disk.showDiskUsage)
    }
}
