//
//  Graph.swift
//  iGlance
//
//  Created by Dominik on 08.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa

protocol GraphProtocol {
    func getImage(currentValue: Double, graphColor: NSColor) -> NSImage

    func drawBorder(image: inout NSImage)
}

class GraphClass {
    var imageSize: NSSize

    init() {
        self.imageSize = NSSize(width: 9, height: 18)
    }

    /**
     * Draws a border with rounded cornsers around the image.
     */
    func drawBorder(image: inout NSImage) {
        // lock the focus on the image in order to draw on it
        image.lockFocus()

        // create the rounded rectangle
        let rect = NSRect(x: 0, y: 0, width: self.imageSize.width, height: self.imageSize.height)
        let roundedRect = NSBezierPath(roundedRect: rect, xRadius: 3.0, yRadius: 3.0)
        roundedRect.lineWidth = 1.0

        if ThemeManager.isDarkTheme() {
            NSColor.white.setStroke()
        } else {
            NSColor.black.setStroke()
        }

        // draw the border
        roundedRect.stroke()

        // unlock the focus of the image
        image.unlockFocus()
    }
}

typealias Graph = GraphClass & GraphProtocol
