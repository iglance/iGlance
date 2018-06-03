//
//  MemUsageView.swift
//  iGlance
//
//  Created by Cemal on 03.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class MemUsageView: NSView {

    var pbFillRect: NSRect?
    var mouseIsDown: Bool?
    var pbMax: Double?
    var cMouseDown: NSColor?
    var pixelWidth: Double?
    var pixelHeight: Double?
    var memIMG: String?
    var pbIMG: String?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if (mouseIsDown == true)
        {
            cMouseDown?.setFill()
            self.frame.fill()
            NSColor.clear.setFill()
        }
        let cTheme = InterfaceStyle()
        if (cTheme == InterfaceStyle.Dark)
        {
            memIMG = "menubar-label-mem-white"
            pbIMG = "progressbar-white"
        }
        else
        {
            memIMG = "menubar-label-mem-black"
            pbIMG = "progressbar-black"
        }
        let img1 = NSImage(named:NSImage.Name(memIMG!))
        img1?.draw(at: NSPoint(x: 2, y: 3), from: self.frame, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        let img2 = NSImage(named:NSImage.Name(pbIMG!))
        img2?.draw(at: NSPoint(x: 12, y: 3), from: self.frame, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        pbFillRect = NSRect(x: 13.0, y: 4.0, width: pixelWidth!, height: pixelHeight!)
        NSColor.red.setFill()
        pbFillRect?.fill()
        NSColor.clear.setFill()
    }
    
    func setPercent(percent: Double)
    {
        pixelHeight = Double((pbMax! / 100.0) * percent)
        needsDisplay = true
    }
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        cMouseDown = NSColor(calibratedRed: 48.0/255.0, green: 91.0/255.0, blue: 178.0/255.0, alpha: 1.0)
        pbMax = 16.0 // 32*0.5
        pixelWidth = 7 // 14*0.5
        pixelHeight = 0
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
