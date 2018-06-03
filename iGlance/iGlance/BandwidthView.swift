//
//  BandwidthView.swift
//  iGlance
//
//  Created by Cemal on 01.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class BandwidthView: NSView {
    
    var bandIMG: String?
    var bandColor: NSColor?
    var bandText: String?
    var finalDown: String?
    var finalUp: String?
    var pbFillRect: NSRect?
    var mouseIsDown: Bool?
    var cMouseDown: NSColor?
    var len1: Int?
    var len2: Int?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if (InterfaceStyle() == InterfaceStyle.Dark)
        {
            bandIMG = "bandwidth-white"
            bandColor = NSColor.white
        }
        else
        {
            bandIMG = "bandwidth-black"
            bandColor = NSColor.black
        }
        
        if (mouseIsDown == true)
        {
            cMouseDown?.setFill()
            self.frame.fill()
            NSColor.clear.setFill()
        }
        
        let img1 = NSImage(named:NSImage.Name(bandIMG!))
        
        img1?.draw(at: NSPoint(x: 2, y: 5), from: self.frame, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0.00000001
        
        len1 = finalDown?.count
        len2 = finalUp?.count
        
        
        
        let font = NSFont(name: "Apple SD Gothic Neo Bold", size: 11.0)
        let fontSmall = NSFont(name: "Apple SD Gothic Neo Bold", size: 8.0)
        let attrString = NSMutableAttributedString(string: finalDown ?? "0 KB/s")
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        attrString.addAttribute(.font, value: font as Any, range:NSMakeRange(0, attrString.length - 4))
        attrString.addAttribute(.font, value: fontSmall as Any, range:NSMakeRange(attrString.length - 4, 4))
        attrString.addAttribute(.foregroundColor, value: bandColor ?? NSColor.white, range:NSMakeRange(0, attrString.length))
        attrString.draw(at: NSPoint(x:18, y:9))
        
        let attrString2 = NSMutableAttributedString(string: finalUp ?? "0 KB/s")
        attrString2.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString2.length))
        attrString2.addAttribute(.font, value: font as Any, range:NSMakeRange(0, attrString2.length - 4))
        attrString2.addAttribute(.font, value: fontSmall as Any, range:NSMakeRange(attrString2.length - 4, 4))
        attrString2.addAttribute(.foregroundColor, value: bandColor ?? NSColor.white, range:NSMakeRange(0, attrString2.length))
        attrString2.draw(at: NSPoint(x:18, y:-2))
        
    }
    
    func updateBandwidth(down: Int64, up: Int64)
    {
        if (down < 1000)
        {
            // B
            finalDown = "0 KB/s"
        }
        else if (down < 1000000)
        {
            // KB
            finalDown = String((Int(down / 1000) / 4) * 4) + " KB/s"
        }
        else
        {
            finalDown = String(format: "%.1f", Double(down) / 1000000.0) + " MB/s"
        }
        
        if (up < 1000)
        {
            // B
            finalUp = "0 KB/s"
        }
        else if (up < 1000000)
        {
            // KB
            finalUp = String((Int(up / 1000) / 4) * 4) + " KB/s"
        }
        else
        {
            finalUp = String(format: "%.1f", Double(down) / 1000000.0) + " MB/s"
        }
        bandText = finalDown! + "\n" + finalUp!
        needsDisplay = true
    }
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        cMouseDown = NSColor(calibratedRed: 48.0/255.0, green: 91.0/255.0, blue: 178.0/255.0, alpha: 1.0)
        len1 = 6
        len2 = 6
        bandText = ""
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
