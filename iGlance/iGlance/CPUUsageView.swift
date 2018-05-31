//
//  CPUUsageView.swift
//  iGlance
//
//  Created by Cemal on 01.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class CPUUsageView: NSView {

    var pbFillRect: NSRect?
    var myrect2: NSRect?
    var mouseIsDown: Bool?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if (mouseIsDown == true)
        {
            let c1  = NSColor(calibratedRed: 48.0/255.0, green: 91.0/255.0, blue: 178.0/255.0, alpha: 1.0)
            c1.setFill()
            self.frame.fill()
            NSColor.clear.setFill()
            
            let img1 = NSImage(named:NSImage.Name("menubar-label-cpu-white"))
            img1?.draw(at: NSPoint(x: 2, y: 3), from: self.frame, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            let img2 = NSImage(named:NSImage.Name("progressbar-white"))
            img2?.draw(at: NSPoint(x: 12, y: 3), from: self.frame, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            pbFillRect = NSRect(x: 13, y: 4, width: 7, height: 16)
            NSColor.red.setFill()
            pbFillRect?.fill()
            NSColor.clear.setFill()
        }
        else
        {
            let img1 = NSImage(named:NSImage.Name("menubar-label-cpu-white"))
            img1?.draw(at: NSPoint(x: 2, y: 3), from: self.frame, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            let img2 = NSImage(named:NSImage.Name("progressbar-white"))
            img2?.draw(at: NSPoint(x: 12, y: 3), from: self.frame, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            pbFillRect = NSRect(x: 13, y: 4, width: 7, height: 16)
            NSColor.red.setFill()
            pbFillRect?.fill()
            NSColor.clear.setFill()
        }
    }
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        mouseIsDown = true
        needsDisplay = true
    }
    
    override func mouseUp(with theEvent: NSEvent)
    {
        mouseIsDown = false
        needsDisplay = true
    }
    
}
