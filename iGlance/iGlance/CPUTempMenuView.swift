//
//  CPUTempMenuView.swift
//  iGlance
//
//  Created by Cemal on 14.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class CPUTempMenuView: NSView {

    
    @IBOutlet weak var tf1: NSTextField!
    @IBOutlet var contentFrame: NSView!
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
