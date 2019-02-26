//
//  Fan.swift
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

class FanComponent {
    /// the status item of the fan
    static let sItemFanSpeed = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    /// the button of the fan icon in the status bar
    var btnFanSpeed: NSStatusBarButton?
    /// the menu of the status item
    var menuFanSpeed: NSMenu?

    /**
     * FAN variables
     */
    var minMenuFan = NSMenuItem(title: "Min:\t\t NA", action: nil, keyEquivalent: "")
    var maxMenuFan = NSMenuItem(title: "Max:\t NA", action: nil, keyEquivalent: "")
    var currMenuFan = NSMenuItem(title: "Current:\t NA", action: nil, keyEquivalent: "")
    var fanCount: Int = 0

    init() {
        // initialize the menu of the status item
        menuFanSpeed = NSMenu()
        menuFanSpeed?.addItem(minMenuFan)
        menuFanSpeed?.addItem(maxMenuFan)
        menuFanSpeed?.addItem(currMenuFan)
        menuFanSpeed?.addItem(NSMenuItem.separator())
        menuFanSpeed?.addItem(NSMenuItem(title: "Settings", action: #selector(AppDelegate.settings_clicked), keyEquivalent: "s"))
        menuFanSpeed?.addItem(NSMenuItem.separator())
        menuFanSpeed?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        FanComponent.sItemFanSpeed.menu = menuFanSpeed
    }

    func initialize() {
        btnFanSpeed = FanComponent.sItemFanSpeed.button
        
        // get the fan count
        do { fanCount = try SMCKit.fanCount() } catch { NSLog("Error: ", error.localizedDescription) }
        
        do {
            minMenuFan.title = try "Min:\t\t " + String(getMinFanSpeed()) + " RPM"
            maxMenuFan.title = try "Max:\t " + String(getMaxFanSpeed()) + " RPM"
        } catch {
            NSLog("Error: ", error.localizedDescription)
        }
        
    }
    
    /**
     *  Returns the maximum minimal fan speed of all fans.
     */
    func getMinFanSpeed() throws -> Int {
        var minFanSpeed: Int = 0
        for i in 0...fanCount-1 {
            let minSpeed = try SMCKit.fanMinSpeed(i)
            if minSpeed > minFanSpeed {
                minFanSpeed = minSpeed
            }
        }
        return minFanSpeed
    }
    
    /**
     *  Returns the maximum fan speed of all fans.
     */
    func getMaxFanSpeed() throws -> Int {
        var maxFanSpeed: Int = 0
        for i in 0...fanCount-1 {
            let maxSpeed = try SMCKit.fanMaxSpeed(i)
            if maxSpeed > maxFanSpeed {
                maxFanSpeed = maxSpeed
            }
        }
        return maxFanSpeed
    }
    
    /**
     *  Returns the maximum current fan speed of all fans.
     */
    func getCurrentFanSpeed() throws -> Int {
        var currentFanSpeed: Int = 0
        for i in 0...fanCount-1 {
            let currentSpeed = try SMCKit.fanCurrentSpeed(i)
            if currentSpeed > currentFanSpeed {
                currentFanSpeed = currentSpeed
            }
        }
        return currentFanSpeed
    }

    /*
     *  Updates the menu bar button and its menu with the greatest current fan speed of all fans.
     */
    func updateFanSpeed() throws {
        // set the current fan speed in the menu
        currMenuFan.title = try "Current:\t " + String(getCurrentFanSpeed()) + " RPM"
        // set the current fan speed as button title
        btnFanSpeed?.title = try String(getCurrentFanSpeed()) + (AppDelegate.UserSettings.userWantsUnitFanSpeed ? " RPM" : "")
    }
}
