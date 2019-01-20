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

    @IBOutlet var lActive: NSTextField! {
        didSet {
            lActive.textColor = NSColor.orange
        }
    }

    @IBOutlet var lCompressed: NSTextField! {
        didSet {
            lCompressed.textColor = NSColor.orange
        }
    }

    @IBOutlet var lFree: NSTextField! {
        didSet {
            lFree.textColor = NSColor(calibratedRed: 0.0, green: 190.0 / 255.0, blue: 0.0, alpha: 1.0)
        }
    }

    @IBOutlet var lWired: NSTextField! {
        didSet {
            lWired.textColor = NSColor.orange
        }
    }

    @IBOutlet var lInactive: NSTextField! {
        didSet {
            lInactive.textColor = NSColor(calibratedRed: 0.0, green: 190.0 / 255.0, blue: 0.0, alpha: 1.0)
        }
    }

    @IBOutlet var percentActive: NSTextField! {
        didSet {
            percentActive.textColor = NSColor.orange
        }
    }

    @IBOutlet var percentCompressed: NSTextField! {
        didSet {
            percentCompressed.textColor = NSColor.orange
        }
    }

    @IBOutlet var percentFree: NSTextField! {
        didSet {
            percentFree.textColor = NSColor(calibratedRed: 0.0, green: 190.0 / 255.0, blue: 0.0, alpha: 1.0)
        }
    }

    @IBOutlet var percentWired: NSTextField! {
        didSet {
            percentWired.textColor = NSColor.orange
        }
    }

    @IBOutlet var percentInactive: NSTextField! {
        didSet {
            percentInactive.textColor = NSColor(calibratedRed: 0.0, green: 190.0 / 255.0, blue: 0.0, alpha: 1.0)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        Bundle.main.loadNibNamed("MemMenuView", owner: self, topLevelObjects: nil)
        let contentFrame = NSMakeRect(0, 0, frame.size.width, frame.size.height)
        contentView.frame = contentFrame
        addSubview(contentView)
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        // fatalError("init(coder:) has not been implemented")
        // commonInit()
    }
}
