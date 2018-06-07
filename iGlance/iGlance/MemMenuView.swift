//
//  MemMenuView.swift
//  iGlance
//
//  Created by Cemal on 07.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class MemMenuView: NSView {

    @IBOutlet var contentView: NSView!
    
    
    @IBOutlet weak var lActive: NSTextField! {
        didSet {
            lActive.textColor = NSColor.yellow
        }
    }
    @IBOutlet weak var lCompressed: NSTextField! {
        didSet {
            lCompressed.textColor = NSColor.yellow
        }
    }
    @IBOutlet weak var lFree: NSTextField! {
        didSet {
            lFree.textColor = NSColor.green
        }
    }
    @IBOutlet weak var lWired: NSTextField! {
        didSet {
            lWired.textColor = NSColor.yellow
        }
    }
    @IBOutlet weak var lInactive: NSTextField! {
        didSet {
            lInactive.textColor = NSColor.green
        }
    }
    @IBOutlet weak var percentActive: NSTextField! {
        didSet {
            percentActive.textColor = NSColor.yellow
        }
    }
    @IBOutlet weak var percentCompressed: NSTextField! {
        didSet {
            percentCompressed.textColor = NSColor.yellow
        }
    }
    @IBOutlet weak var percentFree: NSTextField! {
        didSet {
            percentFree.textColor = NSColor.green
        }
    }
    @IBOutlet weak var percentWired: NSTextField! {
        didSet {
            percentWired.textColor = NSColor.yellow
        }
    }
    @IBOutlet weak var percentInactive: NSTextField! {
        didSet {
            percentInactive.textColor = NSColor.green
        }
    }
    
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: "MemMenuView"), owner: self, topLevelObjects: nil)
        let contentFrame = NSMakeRect(0, 0, frame.size.width, frame.size.height)
        self.contentView.frame = contentFrame
        self.addSubview(self.contentView)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        //fatalError("init(coder:) has not been implemented")
        //commonInit()
    }
}
