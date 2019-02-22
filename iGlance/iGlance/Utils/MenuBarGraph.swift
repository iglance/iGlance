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
            // subtract 8 to get some space for the label and the graph box
            maxValueCount = width-5
        }
    }
    // the maximum value points of the graph
    var maxValueCount: Int = 0
    
    func drawUsageGraph(value: Double, drawBorder: Bool, givenImage: NSImage, givenColor: NSColor) -> NSImage {
        updateHorizontalPos()
        // normalize the value to fit in the graph
        let normalizedValue: Double = round((value/100) * 16)
        addValueToArray(valuePixelPair: ValuePixelPair(value: normalizedValue, horizontalPos: maxValueCount))
        
        // create and lock the image
        let finalImg = NSImage(size: NSSize(width: width, height: 18))
        finalImg.lockFocus()
        
        // draw the given image
        givenImage.draw(at: NSPoint(x:0, y:0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        if drawBorder {
            // draw the border around the graph area
            let borderRect = NSRect(x: 6, y: 0, width: width-8, height: 18)
            if InterfaceStyle() == InterfaceStyle.Dark {
                NSColor.white.set()
            } else {
                NSColor.black.set()
            }
            borderRect.frame()
        }
        
        // set the draw color
        givenColor.setFill()
        for pair in graphValueArray {
            // if the data point of the graph would be outside of the box don't draw the point
            if pair.horizontalPos <= 6 || pair.horizontalPos >= width-3{
                continue
            }
            
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
