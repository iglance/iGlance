//
//  MenuBarGraph.swift
//  iGlance
//
//  Created by Dominik on 16.02.19.
//  Copyright © 2019 iGlance Corp. All rights reserved.
//

import Cocoa

class MenuBarGraph {
    
    // struct to store a value pixel pair for drawing the usage graph
    struct ValuePixelPair {
        var value: Double   // the usage value
        var horizontalPos: Int  // the horizontal position on the menu bar image in pixel
    }
    
    // array to store the last values for drawing the usage graph
    var graphValueArray: [ValuePixelPair] = []
    
    // the width of the whole image including the border around the graph
    var width: Int = 0 {
        didSet {
            // if the width changed change the max value count accordingly
            maxValueCount = width-3
        }
    }
    // the maximum value points of the graph
    var maxValueCount: Int = 0
    
    func drawUsageGraph(totalCpuUsage: Double) -> NSImage {
        updateHorizontalPos()
        // normalize the value to fit in the graph
        let normalizedValue: Double = round((totalCpuUsage/100) * 16)
        addValueToArray(valuePixelPair: ValuePixelPair(value: normalizedValue, horizontalPos: maxValueCount))
        
        // create and lock the image
        let finalImg = NSImage(size: NSSize(width: maxValueCount+3, height: 18))
        finalImg.lockFocus()
        
        if AppDelegate.UserSettings.userWantsCPUBorder {
            // draw the border around the graph area
            let borderRect = NSRect(x: 0, y: 0, width: maxValueCount+3, height: 18)
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
        
        return finalImg
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
