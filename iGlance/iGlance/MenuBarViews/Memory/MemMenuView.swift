//
//  MemMenuView.swift
//  iGlance
//
//  MIT License
//
//  Copyright (c) 2018 Cemal K <https://github.com/Moneypulation>, Dominik H <https://github.com/D0miH>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
