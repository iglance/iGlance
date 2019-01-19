//
//  CPUMenuView.swift
//  iGlance
//
//  Created by Cemal on 07.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class CPUMenuView: NSView {
    @IBOutlet var contentView: NSView!
    @IBOutlet var percentUser: NSTextField! {
        didSet {
            percentUser.textColor = NSColor.orange
        }
    }

    @IBOutlet var percentSystem: NSTextField! {
        didSet {
            percentSystem.textColor = NSColor.red
        }
    }

    @IBOutlet var percentIdle: NSTextField! {
        didSet {
            percentIdle.textColor = NSColor(calibratedRed: 0.0, green: 190.0 / 255.0, blue: 0.0, alpha: 1.0)
        }
    }

    @IBOutlet var percentNice: NSTextField!
    @IBOutlet var lUser: NSTextField! {
        didSet {
            lUser.textColor = NSColor.orange
        }
    }

    @IBOutlet var lSystem: NSTextField! {
        didSet {
            lSystem.textColor = NSColor.red
        }
    }

    @IBOutlet var lIdle: NSTextField! {
        didSet {
            lIdle.textColor = NSColor(calibratedRed: 0.0, green: 190.0 / 255.0, blue: 0.0, alpha: 1.0)
        }
    }

    @IBOutlet var lNice: NSTextField!
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        Bundle.main.loadNibNamed("CPUMenuView", owner: self, topLevelObjects: nil)
        let contentFrame = NSMakeRect(0, 0, frame.size.width, frame.size.height)
        contentView.frame = contentFrame
        addSubview(contentView)
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        // fatalError("init(coder:) has not been implemented")
        // commonInit()
    }

    /*
     private func commonInit()
     {
     Bundle.main.loadNibNamed(NSNib.Name(rawValue: "CPUMenuView"), owner: self, topLevelObjects: nil)
     addSubview(contentView)
     contentView.frame = self.bounds
     contentView.autoresizingMask = [.maxXMargin, .maxYMargin]

     }
     */
}
