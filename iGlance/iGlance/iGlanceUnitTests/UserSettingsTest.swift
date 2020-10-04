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

import XCTest

@testable import iGlance
import SMCKit

class UserSettingsTest: XCTestCase {
    func testResetUserSettings() throws {
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

    func testDecodeCpuSettings() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let defaultCpuTempSettings = CpuSettings()

        let compareToDefaultSettings = { (givenJsonDict: [String: String]) in
            let jsonData = try encoder.encode(givenJsonDict)
            let decodedSettings = try decoder.decode(CpuSettings.self, from: jsonData)
            XCTAssertEqual(defaultCpuTempSettings, decodedSettings)
        }

        let cpuSettingsDict: [String: String] = [
            "showTemperature": "true",
            "showUsage": "true",
            "usageGraphColor": "{ 'red': 0, 'alpha': 1, 'blue': 0, 'green': 1 }",
            "usageGraphKind": "{'rawValue':1}",
            "usageLineGraphWidth": "50",
            "showUsageGraphBorder": "true",
            "colorGradientSettings": "{'secondaryColor':{'red':1,'alpha':1,'blue':0,'green':0},'useGradient':false}"
        ]
        // check that all the needed keys are present
        let defaultSettingsMirror = Mirror(reflecting: defaultCpuTempSettings)
        for key in defaultSettingsMirror.children {
            XCTAssertNotNil(key.label)
            XCTAssertTrue(cpuSettingsDict.keys.contains(key.label!))
        }

        let createJsonDictWithoutKey = { (keyToOmit: String) -> [String: String] in
            var writableDictCopy = cpuSettingsDict
            writableDictCopy[keyToOmit] = nil
            XCTAssertEqual(writableDictCopy.count, cpuSettingsDict.count - 1)
            return writableDictCopy
        }

        for key in cpuSettingsDict.keys {
            let testJsonDict = createJsonDictWithoutKey(key)
            try compareToDefaultSettings(testJsonDict)
        }
    }
}
