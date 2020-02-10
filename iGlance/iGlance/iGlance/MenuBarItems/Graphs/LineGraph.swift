//
//  LineGraph.swift
//  iGlance
//
//  Created by Dominik on 08.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa

class LineGraph: Graph {
    private var graphImage: NSImage?

    private var valueHistory: Queue = Queue<Double>()
    private var valueCount: Int {
        Int(self.imageSize.width - self.borderWidth * 2)
    }

    /**
     * Initializer
     *
     * - Parameter imageWidth: width of the graph in pixel
     */
    init(maxValue: Double, imageWidth: Int) {
        super.init()

        self.imageSize.width = CGFloat(imageWidth)
    }

    func getImage(currentValue: Double, graphColor: NSColor) -> NSImage {
        // create a new image
        var image = NSImage(size: self.imageSize)

        // first draw the graph
        self.drawLineGraph(image: &image, currentValue: currentValue, graphColor: graphColor)

        // draw the border over the graph
        self.drawBorder(image: &image)

        return image
    }

    func drawLineGraph(image: inout NSImage, currentValue: Double, graphColor: NSColor) {
        // add the current value to the history
        self.addValueToHistory(currentValue: currentValue)

        // lock the image to draw the graph
        image.lockFocus()

        // set the fill color
        graphColor.set()

        // iterate the values and draw a bar for each value on the correct position
        var nextValuePosition = self.imageSize.width - self.borderWidth - 1
        for value in valueHistory.makeIterator().reversed() {
            let valueBar = NSRect(x: nextValuePosition, y: self.borderWidth, width: 1, height: CGFloat(value))
            valueBar.fill()

            // set the position for the next value
            nextValuePosition -= 1
        }

        // unlock the focus of the image
        image.unlockFocus()
    }

    /**
     * Removes all values from the graph.
     */
    func flushValues() {
        let count = 0...valueHistory.count
        for _ in count {
            _ = valueHistory.dequeue()
        }
    }

    /**
     * Adds the given value to the history of the line graph.
     */
    func addValue(value: Double) {
        self.addValueToHistory(currentValue: value)
    }

    private func addValueToHistory(currentValue: Double) {
        valueHistory.enqueue(currentValue)

        if valueHistory.count > valueCount {
            _ = valueHistory.dequeue()
        }
    }
}
