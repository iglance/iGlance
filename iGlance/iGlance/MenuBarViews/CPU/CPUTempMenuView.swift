//
//  CPUTempMenuView.swift
//  iGlance
//
//  Created by Cemal on 14.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class CPUTempMenuView: NSView {
    @IBOutlet var contentFrame: NSView!
    @IBOutlet var temp0: NSTextField!
    @IBOutlet var temp1: NSTextField!
    @IBOutlet var temp2: NSTextField!
    @IBOutlet var temp3: NSTextField!
    @IBOutlet var temp4: NSTextField!
    @IBOutlet var temp5: NSTextField!
    @IBOutlet var temp6: NSTextField!
    @IBOutlet var temp7: NSTextField!
    @IBOutlet var temp8: NSTextField!
    @IBOutlet var temp9: NSTextField!
    @IBOutlet var temp10: NSTextField!
    @IBOutlet var temp11: NSTextField!
    @IBOutlet var temp12: NSTextField!
    @IBOutlet var temp13: NSTextField!
    @IBOutlet var temp14: NSTextField!
    @IBOutlet var temp15: NSTextField!
    @IBOutlet var temp16: NSTextField!
    @IBOutlet var temp17: NSTextField!
    @IBOutlet var temp18: NSTextField!
    @IBOutlet var temp19: NSTextField!
    @IBOutlet var temp20: NSTextField!
    @IBOutlet var temp21: NSTextField!
    @IBOutlet var temp22: NSTextField!
    @IBOutlet var temp23: NSTextField!
    @IBOutlet var temp24: NSTextField!
    @IBOutlet var temp25: NSTextField!
    @IBOutlet var temp26: NSTextField!
    @IBOutlet var temp27: NSTextField!
    @IBOutlet var temp28: NSTextField!

    // MARK: Properties

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        Bundle.main.loadNibNamed("CPUTempMenuView", owner: self, topLevelObjects: nil)
        let contentFrame = NSMakeRect(0, 0, frame.size.width, frame.size.height)
        self.contentFrame.frame = contentFrame
        addSubview(self.contentFrame)
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
}
