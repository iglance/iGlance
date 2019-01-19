//
//  CpuUtilComponent.swift
//  iGlance
//
//  Created by Dominik on 19.01.19.
//  Copyright © 2019 iGlance Corp. All rights reserved.
//

import Cocoa

class CpuUsageComponent {
    // the status item of the cpu utilization
    static let sItemCpuUtil = NSStatusBar.system.statusItem(withLength: 27.0)
    // the custom menu view of the cpu utilization
    let myCpuMenuView = CPUMenuView(frame: NSRect(x: 0, y: 0, width: 170, height: 90))
    // the menu item for the custom view
    let menuItemCpu = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    // the buton of the cpu utilization icon
    var btnCpuUtil: NSStatusBarButton?
    // the menu for the button
    var menuCpuUtil: NSMenu?

    /**
     * CPU Button Image variables
     */
    var pbFillRectCpu: NSRect?
    var pixelHeightCpu: Double?
    var cpuImg: String?
    /**
     * Shared variables
     */
    var pixelWidth: Double?
    var pbImg: String?
    var pbMax: Double?

    // system variable to get cpu stats
    var mySystem: System?

    init() {
        pbMax = 16.0 // 32*0.5
        pixelWidth = 7 // 14*0.5
        pixelHeightCpu = 0
        mySystem = System()
        btnCpuUtil = CpuUsageComponent.sItemCpuUtil.button
        btnCpuUtil?.image?.isTemplate = true
    }

    func initialize() {
        menuItemCpu.view = myCpuMenuView

        menuCpuUtil = NSMenu()
        menuCpuUtil?.addItem(menuItemCpu)
        menuCpuUtil?.addItem(NSMenuItem.separator())
        menuCpuUtil?.addItem(NSMenuItem(title: "Settings", action: #selector(AppDelegate.settings_clicked), keyEquivalent: "s"))
        menuCpuUtil?.addItem(NSMenuItem.separator())
        menuCpuUtil?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        CpuUsageComponent.sItemCpuUtil.menu = menuCpuUtil
    }

    func updateCPUUsage() {
        let cpuStats = mySystem!.usageCPU()
        let cpuUser = Double(round(100 * cpuStats.user) / 100)
        let cpuSystem = Double(round(100 * cpuStats.system) / 100)
        let cpuIdle = Double(round(100 * cpuStats.idle) / 100)
        let cpuUsageTotal = cpuUser + cpuSystem

        myCpuMenuView.percentSystem.stringValue = String(Int(cpuSystem)) + "%"
        myCpuMenuView.percentUser.stringValue = String(Int(cpuUser)) + "%"
        myCpuMenuView.percentIdle.stringValue = String(Int(cpuIdle)) + "%"

        pixelHeightCpu = Double((pbMax! / 100.0) * cpuUsageTotal)

        if InterfaceStyle() == InterfaceStyle.Dark {
            cpuImg = "menubar-label-cpu-white"
            pbImg = "progressbar-white"
        } else {
            cpuImg = "menubar-label-cpu-black"
            pbImg = "progressbar-black"
        }
        let imgFinal = NSImage(size: NSSize(width: 20, height: 18))
        imgFinal.lockFocus()
        let img1 = NSImage(named: NSImage.Name(cpuImg!))
        img1?.draw(at: NSPoint(x: 1, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        if AppDelegate.UserSettings.userWantsCPUBorder {
            let img2 = NSImage(named: NSImage.Name(pbImg!))
            img2?.draw(at: NSPoint(x: 11, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        }
        pbFillRectCpu = NSRect(x: 12.0, y: 1.0, width: pixelWidth!, height: pixelHeightCpu!)
        AppDelegate.UserSettings.cpuColor.setFill()
        pbFillRectCpu?.fill()
        NSColor.clear.setFill()
        imgFinal.unlockFocus()

        btnCpuUtil?.image = imgFinal
    }
}
