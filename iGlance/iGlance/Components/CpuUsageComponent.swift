//
//  CpuUtilComponent.swift
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

class CpuUsageComponent {
    
    // the status item of the cpu utilization
    static var sItemCpuUtil = NSStatusBar.system.statusItem(withLength: 27.0)
    // the custom menu view of the cpu utilization
    let myCpuMenuView = CPUMenuView(frame: NSRect(x: 0, y: 0, width: 170, height: 90))
    // the menu item for the custom view
    let menuItemCpu = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    // the buton of the cpu utilization icon
    var btnCpuUtil: NSStatusBarButton?
    // the menu for the button
    var menuCpuUtil: NSMenu?
    
    // the cpu menu bar icon for the text
    var cpuImg: String?
    // the cpu menu bar icon for the usage bar
    var pbImg: String?
    
    var menuBarGraph = MenuBarGraph()
    
    // system variable to get cpu stats
    var mySystem: System?
    
    init() {
        mySystem = System()
        btnCpuUtil = CpuUsageComponent.sItemCpuUtil.button
        btnCpuUtil?.image?.isTemplate = true
        
        // adjust the length of the status item according to the visualization type.
        CpuUsageComponent.sItemCpuUtil.length = AppDelegate.UserSettings.cpuUsageVisualization == AppDelegate.VisualizationType.Bar ? 27 : CGFloat(AppDelegate.UserSettings.cpuGraphWidth)
        menuBarGraph.width = Int(CpuUsageComponent.sItemCpuUtil.length)
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
        // calculate the percentages
        let cpuStats = mySystem!.usageCPU()
        let cpuUser = Double(round(100 * cpuStats.user) / 100)
        let cpuSystem = Double(round(100 * cpuStats.system) / 100)
        let cpuIdle = Double(round(100 * cpuStats.idle) / 100)
        let cpuUsageTotal = cpuUser + cpuSystem
        // assign the values to the labels in the menu
        myCpuMenuView.percentSystem.stringValue = String(Int(cpuSystem)) + "%"
        myCpuMenuView.percentUser.stringValue = String(Int(cpuUser)) + "%"
        myCpuMenuView.percentIdle.stringValue = String(Int(cpuIdle)) + "%"
        
        if InterfaceStyle() == InterfaceStyle.Dark {
            cpuImg = "menubar-label-cpu-white"
            pbImg = "progressbar-white"
        } else {
            cpuImg = "menubar-label-cpu-black"
            pbImg = "progressbar-black"
        }
        
        if AppDelegate.UserSettings.cpuUsageVisualization == AppDelegate.VisualizationType.Graph {
            // if the width has changed update the width of the graph
            if menuBarGraph.width != Int(CpuUsageComponent.sItemCpuUtil.length) {
                menuBarGraph.width = Int(CpuUsageComponent.sItemCpuUtil.length)
            }
            btnCpuUtil?.image = menuBarGraph.drawUsageGraph(value: cpuUsageTotal, drawBorder: AppDelegate.UserSettings.userWantsCPUBorder, givenImage: NSImage(named: NSImage.Name(cpuImg!))!, givenColor: AppDelegate.UserSettings.cpuColor)
        } else {
            drawUsageBar(totalCpuUsage: cpuUsageTotal)
        }
    }
    
    func drawUsageBar(totalCpuUsage: Double) {
        let imgFinal = NSImage(size: NSSize(width: 20, height: 18))
        imgFinal.lockFocus()
        let img1 = NSImage(named: NSImage.Name(cpuImg!))
        img1?.draw(at: NSPoint(x: 1, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        if AppDelegate.UserSettings.userWantsCPUBorder {
            let img2 = NSImage(named: NSImage.Name(pbImg!))
            img2?.draw(at: NSPoint(x: 11, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        }
        
        // define the width and height of the rectangle which is going to be drawn
        let rectWidth = 7 // 14*0.5
        let maxRectHeight = 16.0 // 32*0.5
        let pixelHeightCpu = Double((maxRectHeight / 100.0) * totalCpuUsage)
        // create the rectangle
        let pbFillRectCpu = NSRect(x: 12.0, y: 1.0, width: Double(rectWidth), height: pixelHeightCpu)
        // set the fill color according to the user settings and fill the rectangle
        AppDelegate.UserSettings.cpuColor.setFill()
        pbFillRectCpu.fill()
        // clear the fill color
        NSColor.clear.setFill()
        imgFinal.unlockFocus()
        
        btnCpuUtil?.image = imgFinal
    }
}
