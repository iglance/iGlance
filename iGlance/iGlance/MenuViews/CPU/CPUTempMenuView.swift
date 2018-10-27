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
    @IBOutlet weak var temp0: NSTextField!
    @IBOutlet weak var temp1: NSTextField!
    @IBOutlet weak var temp2: NSTextField!
    @IBOutlet weak var temp3: NSTextField!
    @IBOutlet weak var temp4: NSTextField!
    @IBOutlet weak var temp5: NSTextField!
    @IBOutlet weak var temp6: NSTextField!
    @IBOutlet weak var temp7: NSTextField!
    @IBOutlet weak var temp8: NSTextField!
    @IBOutlet weak var temp9: NSTextField!
    @IBOutlet weak var temp10: NSTextField!
    @IBOutlet weak var temp11: NSTextField!
    @IBOutlet weak var temp12: NSTextField!
    @IBOutlet weak var temp13: NSTextField!
    @IBOutlet weak var temp14: NSTextField!
    @IBOutlet weak var temp15: NSTextField!
    @IBOutlet weak var temp16: NSTextField!
    @IBOutlet weak var temp17: NSTextField!
    @IBOutlet weak var temp18: NSTextField!
    @IBOutlet weak var temp19: NSTextField!
    @IBOutlet weak var temp20: NSTextField!
    @IBOutlet weak var temp21: NSTextField!
    @IBOutlet weak var temp22: NSTextField!
    @IBOutlet weak var temp23: NSTextField!
    @IBOutlet weak var temp24: NSTextField!
    @IBOutlet weak var temp25: NSTextField!
    @IBOutlet weak var temp26: NSTextField!
    @IBOutlet weak var temp27: NSTextField!
    @IBOutlet weak var temp28: NSTextField!
    
    //MARK: Properties
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: "CPUTempMenuView"), owner: self, topLevelObjects: nil)
        let contentFrame = NSMakeRect(0, 0, frame.size.width, frame.size.height)
        self.contentFrame.frame = contentFrame
        self.addSubview(self.contentFrame)
    }
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
}
