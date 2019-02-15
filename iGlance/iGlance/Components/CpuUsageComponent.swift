//
//  CpuUtilComponent.swift
//  iGlance
//
//  Created by Dominik on 19.01.19.
//  Copyright © 2019 iGlance Corp. All rights reserved.
//

import Cocoa

class CpuUsageComponent {
    
    public enum VisualizationType {
        case Graph
        case Bar
    }
    
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
    
    // the cpu menu bar icon for the text
    var cpuImg: String?
    // the cpu menu bar icon for the usage bar
    var pbImg: String?
    
    // struct to store a value pixel pair for drawing the usage graph
    struct ValuePixelPair {
        var value: Double   // the usage value
        var horizontalPos: Int  // the horizontal position on the menu bar image in pixel
    }
    // array to store the last values for drawing the usage graph
    var graphValueArray: [ValuePixelPair] = []
    let maxValueCount: Int = Int(50)
    
    // system variable to get cpu stats
    var mySystem: System?
    
    init() {
        mySystem = System()
        btnCpuUtil = CpuUsageComponent.sItemCpuUtil.button
        btnCpuUtil?.image?.isTemplate = true
        
        // adjust the length of the status item according to the visualization type
        CpuUsageComponent.sItemCpuUtil.length = AppDelegate.UserSettings.cpuUsageVisualization == VisualizationType.Bar ? 27 : 53
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
        
        if AppDelegate.UserSettings.cpuUsageVisualization == VisualizationType.Graph {
            drawUsageGraph(totalCpuUsage: cpuUsageTotal)
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
    
    func drawUsageGraph(totalCpuUsage: Double) {
        updateHorizontalPos()
        // normalize the value to fit in the graph
        let normalizedValue: Double = round((totalCpuUsage/100) * 16)
        addValueToArray(valuePixelPair: ValuePixelPair(value: normalizedValue, horizontalPos: maxValueCount))
        
        // create and lock the image
        let finalImg = NSImage(size: NSSize(width: 53, height: 18))
        finalImg.lockFocus()
        
        if AppDelegate.UserSettings.userWantsCPUBorder {
            // draw the border around the graph area
            let borderRect = NSRect(x: 0, y: 0, width: 53, height: 18)
            if InterfaceStyle() == InterfaceStyle.Dark {
                NSColor.white.set()
            } else {
                NSColor.black.set()
            }
            borderRect.frame()
        }
        
        // set the draw color
        AppDelegate.UserSettings.cpuColor.setFill()
        for pair in graphValueArray {
            let rect = NSRect(x: pair.horizontalPos, y: 1, width: 2, height: Int(pair.value))
            rect.fill()
        }
        
        // reset the draw color
        NSColor.clear.setFill()
        finalImg.unlockFocus()
        
        btnCpuUtil?.image = finalImg
    }
    
    /**
     *  Adds a value value pixel pair to the cpu usage history in order to draw the cpu usage graph.
     */
    private func addValueToArray(valuePixelPair: ValuePixelPair) {
        // if the array is full, remove the first item
        if(graphValueArray.count == maxValueCount) {
            graphValueArray.remove(at: 0)
        }
        
        // append the new item
        graphValueArray.append(valuePixelPair)
    }
    
    /**
     *  Updates the horizontal position of the cpu graph. Each cpu usage value is shifted to the left by one.
     */
    private func updateHorizontalPos() {
        if graphValueArray.count == 0 {
            return
        }
        
        for i in 0...graphValueArray.count-1 {
            graphValueArray[i].horizontalPos -= 1
        }
    }
}
