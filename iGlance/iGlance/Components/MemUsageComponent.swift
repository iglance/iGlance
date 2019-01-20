//
//  MemUsageComponent.swift
//  iGlance
//
//  Created by Dominik on 19.01.19.
//  Copyright © 2019 iGlance Corp. All rights reserved.
//

import Cocoa

class MemUsageComponent {
    // the status item of the memory usage
    static let sItemMemUsage = NSStatusBar.system.statusItem(withLength: 27.0)
    // the custom view of the memory usage
    let myMemMenuView = MemMenuView(frame: NSRect(x: 0, y: 0, width: 170, height: 110))
    // the menu item for the custom menu view
    let menuItemMem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    // the button of the menu bar icon
    var btnMemUsage: NSStatusBarButton?
    // the menu of the icon
    var menuMemUsage: NSMenu?

    /**
     * MEM Button Image variables
     */
    var pbFillRectMEM: NSRect?
    var pbMaxMEM: Double?
    var pixelHeightMEM: Double?
    var memIMG: String?

    /**
     * Shared variables
     */
    var pixelWidth: Double?
    var pbIMG: String?
    var pbMax: Double?

    func initialize() {
        menuItemMem.view = myMemMenuView

        menuMemUsage = NSMenu()
        menuMemUsage?.addItem(menuItemMem)
        menuMemUsage?.addItem(NSMenuItem.separator())
        menuMemUsage?.addItem(NSMenuItem(title: "Settings", action: #selector(AppDelegate.settings_clicked), keyEquivalent: "s"))
        menuMemUsage?.addItem(NSMenuItem.separator())
        menuMemUsage?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        MemUsageComponent.sItemMemUsage.menu = menuMemUsage

        pbMax = 16.0
        pixelWidth = 7
        btnMemUsage = MemUsageComponent.sItemMemUsage.button
        pixelHeightMEM = 0
    }

    func updateMemUsage() {
        let memStats = System.memoryUsage()
        let memActive = Double(round(100 * memStats.active) / 100)
        let memCompressed = Double(round(100 * memStats.compressed) / 100)
        let memFree = Double(round(100 * memStats.free) / 100)
        let memInactive = Double(round(100 * memStats.inactive) / 100)
        let memWired = Double(round(100 * memStats.wired) / 100)

        myMemMenuView.percentActive.stringValue = String(memActive) + " GB"
        myMemMenuView.percentCompressed.stringValue = String(memCompressed) + " GB"
        myMemMenuView.percentFree.stringValue = String(memFree) + " GB"
        myMemMenuView.percentInactive.stringValue = String(memInactive) + " GB"
        myMemMenuView.percentWired.stringValue = String(memWired) + " GB"

        let memTaken = memActive + memCompressed + memWired
        let memUtil = Double(memTaken / System.physicalMemory()) * 100

        pixelHeightMEM = Double((pbMax! / 100.0) * memUtil)

        if InterfaceStyle() == InterfaceStyle.Dark {
            memIMG = "menubar-label-mem-white"
            pbIMG = "progressbar-white"
        } else {
            memIMG = "menubar-label-mem-black"
            pbIMG = "progressbar-black"
        }
        let imgFinal = NSImage(size: NSSize(width: 20, height: 18))
        imgFinal.lockFocus()
        let img1 = NSImage(named: NSImage.Name(memIMG!))
        img1?.draw(at: NSPoint(x: 1, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        if AppDelegate.UserSettings.userWantsMemBorder {
            let img2 = NSImage(named: NSImage.Name(pbIMG!))
            img2?.draw(at: NSPoint(x: 11, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        }
        pbFillRectMEM = NSRect(x: 12.0, y: 1.0, width: pixelWidth!, height: pixelHeightMEM!)
        AppDelegate.UserSettings.memColor.setFill()
        pbFillRectMEM?.fill()
        NSColor.clear.setFill()
        imgFinal.unlockFocus()

        btnMemUsage?.image = imgFinal
    }
}
