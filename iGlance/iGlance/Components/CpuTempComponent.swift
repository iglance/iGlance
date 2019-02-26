//
//  CPU.swift
//  iGlance
//
//  MIT License
//
//  Copyright (c) 2018 Cemal K <https://github.com/Moneypulation>, Dominik H <https://github.com/D0miH>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Cocoa

class CpuTempComponent {
    public enum TempUnit {
        case Celcius
        case Fahrenheit
    }

    /// the status item of the cpu temperatur
    static let sItemCPUTemp = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    /// the button of the cpu temperatur in the menu bar
    var btnCPUTemp: NSStatusBarButton?
    /// the menu of the status item
    var menuCPUTemp: NSMenu?

    init() {
        // initialize the menu for the menu bar button
        menuCPUTemp = NSMenu()
        let myTempMenu = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        let myCPUTempView = CPUTempMenuView(frame: NSRect(x: 0, y: 0, width: 355, height: 195))

        myCPUTempView.temp0.stringValue = "144°F"
        myTempMenu.view = myCPUTempView
        menuCPUTemp?.addItem(NSMenuItem.separator())
        menuCPUTemp?.addItem(NSMenuItem(title: "Settings", action: #selector(AppDelegate.settings_clicked), keyEquivalent: "s"))
        menuCPUTemp?.addItem(NSMenuItem.separator())
        menuCPUTemp?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        CpuTempComponent.sItemCPUTemp.menu = menuCPUTemp
    }

    func initialize() {
        // initialize the button for the menu bar
        btnCPUTemp = CpuTempComponent.sItemCPUTemp.button
    }

    func updateCPUTemp() {
        // get the temperatur sensor of the cpu
        let core0 = TemperatureSensor(name: "CPU_0_DIE", code: FourCharCode(fromStaticString: "TC0F"))

        // try to get the temperature of the sensor
        guard let temperature = try? SMCKit.temperature(core0.code) else {
            btnCPUTemp?.title = "NA"
            return
        }

        // calculate fahrenheit to display the correct temperatur
        if AppDelegate.UserSettings.tempUnit == TempUnit.Fahrenheit {
            let temperatureF = (temperature * 1.8) + 32
            btnCPUTemp?.title = String(Int(temperatureF)) + "°F"
        } else {
            btnCPUTemp?.title = String(Int(temperature)) + "°C"
        }
    }
}
