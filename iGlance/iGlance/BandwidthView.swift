//
//  BandwidthView.swift
//  iGlance
//
//  Created by Cemal on 01.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class BandwidthView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let img1 = NSImage(named:NSImage.Name("bandwidth-white"))
        
        img1?.draw(at: NSPoint(x: 2, y: 5), from: self.frame, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0.00000001
        
        let font = NSFont(name: "Apple SD Gothic Neo Bold", size: 8.0)
        let attrString = NSMutableAttributedString(string: "2048 KB/s\n1024 KB/s")
        let color = NSColor.white
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        attrString.addAttribute(.font, value: font as Any, range:NSMakeRange(0, attrString.length))
        attrString.addAttribute(.foregroundColor, value: color, range:NSMakeRange(0, attrString.length))
        attrString.draw(at: NSPoint(x:18, y:-1))
    }
    
}
