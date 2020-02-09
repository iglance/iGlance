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

    let borderWidth = CGFloat(0.5)

    init() {
        self.imageSize = NSSize(width: 9, height: 18)
    }

    /**
     * Draws a border with rounded cornsers around the image.
     */
    func drawBorder(image: inout NSImage) {
        // lock the focus on the image in order to draw on it
        image.lockFocus()

        // create the rounded rectangle. Keep in mind that the line is drawn centered on the rectangle border.
        let rect = NSRect(
            x: borderWidth / 2, // subtract half the border width to align the graph border to the image border
            y: borderWidth / 2,
            width: self.imageSize.width - borderWidth, // subtract the border width once since half the border of each side has to be subtracted
            height: self.imageSize.height - borderWidth
        )
        let roundedRect = NSBezierPath(roundedRect: rect, xRadius: 2, yRadius: 2)
        roundedRect.lineWidth = borderWidth

        if ThemeManager.isDarkTheme() {
            NSColor.white.set()
        } else {
            NSColor.black.set()
        }

        // draw the border
        roundedRect.stroke()

        // unlock the focus of the image
        image.unlockFocus()
    }
}

typealias Graph = GraphClass & GraphProtocol
