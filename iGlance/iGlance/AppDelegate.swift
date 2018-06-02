//
//  AppDelegate.swift
//  iGlance
//
//  Created by Cemal on 01.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

enum InterfaceStyle : String {
    case Dark, Light
    
    init() {
        let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        self = InterfaceStyle(rawValue: type)!
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let sItemFanSpeed = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var btnFanSpeed: NSStatusBarButton?
    
    let sItemBandwidth = NSStatusBar.system.statusItem(withLength: 60.0)
    var btnBandwidth: NSStatusBarButton?
    
    let sItemMemUsage = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var btnMemUsage: NSStatusBarButton?
    
    let sItemCPUUtil = NSStatusBar.system.statusItem(withLength: 45.0)
    var btnCPUUtil: NSStatusBarButton?
    
    let sItemCPUTemp = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var btnCPUTemp: NSStatusBarButton?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initCPUUtil()
        initCPUTemp()
        initMemUsage()
        initFanSpeed()
        initBandwidth()
    }

    func initCPUUtil()
    {
        btnCPUUtil = sItemCPUUtil.button
        let myCPUView = CPUUsageView()
        myCPUView.frame = (btnCPUUtil?.frame)!
        btnCPUUtil?.addSubview(myCPUView)
        
        let str = Bundle.main.executableURL!.absoluteString
        let components = str.split(separator: "/")
        let head = "/" + components.dropLast(1).dropFirst(1).map(String.init).joined(separator: "/") + "/cpu_mem_util"
        
        print(head)
    }
    
    func initMemUsage()
    {
        btnMemUsage = sItemMemUsage.button
        
        let img1 = NSImage(named:NSImage.Name("menubar-label-mem-white"))
        let img2 = NSImage(named:NSImage.Name("progressbar-white"))
        let img3 = NSImage(size: NSSize(width: 20, height: 18))
        img3.lockFocus()
        img1?.draw(at: NSPoint(x: 0, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        img2?.draw(at: NSPoint(x: 10, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        img3.unlockFocus()
        
        btnMemUsage?.image = img3
    }
    
    func initCPUTemp()
    {
        btnCPUTemp = sItemCPUTemp.button
        btnCPUTemp?.title = "53°"
    }
    
    func initFanSpeed()
    {
        btnFanSpeed = sItemFanSpeed.button
        btnFanSpeed?.title = "1330"
    }
    
    func initBandwidth()
    {
        btnBandwidth = sItemBandwidth.button
        //btnBandwidth?.image = NSImage(named:NSImage.Name("menubar-label-network"))
        let myBWView = BandwidthView()
        myBWView.frame = (btnBandwidth?.frame)!
        btnBandwidth?.addSubview(myBWView)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

