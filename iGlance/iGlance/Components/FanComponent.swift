//
//  Fan.swift
//  iGlance
//
//  Created by Dominik on 18.01.19.
//  Copyright © 2019 iGlance Corp. All rights reserved.
//

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
    
    func initButton() {
        btnFanSpeed = FanComponent.sItemFanSpeed.button
    }
    
    func updateFanSpeed() {
        let allFans: [Fan]
        do {
            allFans = try SMCKit.allFans()
        } catch {
            print(error)
            return
        }
        
        if allFans.count == 0
        {
            print("No fans found")
            return;
        }
        
        for fan in allFans {
            guard let currentSpeed = try? SMCKit.fanCurrentSpeed(fan.id) else {
                print("\tCurrent:  NA")
                return
            }
            minMenuFan.title = "Min:\t\t " + String(fan.minSpeed) + " RPM"
            maxMenuFan.title = "Max:\t " + String(fan.maxSpeed) + " RPM"
            let currentMinus50 = currentSpeed - fan.minSpeed - 50
            if (currentMinus50 < 0)
            {
                btnFanSpeed?.title = "0"
                currMenuFan.title = "Current:\t 0 RPM"
            }
            else if (currentSpeed >= fan.maxSpeed)
            {
                btnFanSpeed?.title = String(fan.maxSpeed - fan.minSpeed)
                currMenuFan.title = "Current:\t " + String(fan.maxSpeed - fan.minSpeed) + " RPM"
            }
            else
            {
                btnFanSpeed?.title = String(((currentMinus50+50) / 5)*5)
                currMenuFan.title = "Current:\t " + String(((currentMinus50+50) / 5)*5) + " RPM"
            }
            break;
            
        }
    }
}
