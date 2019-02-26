//
//  CPUMenuView.swift
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
}
