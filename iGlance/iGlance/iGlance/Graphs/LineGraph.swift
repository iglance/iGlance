//
//  LineGraph.swift
//  iGlance
//
//  Created by Dominik on 08.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa

class LineGraph: Graph {
    // MARK: -
    // MARK: Private Instance Variables
    private var graphImage: NSImage?

    /// the history containing all the graph values
    private var valueHistory: Queue = Queue<Double>()
    /// the number of values in the graph
    private var valueCount: Int {
        Int(self.imageSize.width - self.borderWidth * 2)
    }
    /// the maximum height in pixel of the graph bars
    private var maxbarHeight: Double {
        Double(self.imageSize.height - self.borderWidth * 2)
    }
    /// the maximum value of the graph (equals 100%)
    private let maxValue: Double

    // MARK: -
    // MARK: Public Instance Functions

    /**
     * Initializer
     *
     * - Parameter imageWidth: width of the graph in pixel
     */
    init(maxValue: Double, imageWidth: Int) {
        // set the maximum value for the graph
        self.maxValue = maxValue

        super.init()

        self.imageSize.width = CGFloat(imageWidth)
    }

    func getImage(currentValue: Double, graphColor: NSColor, drawBorder: Bool, gradientColor: NSColor?) -> NSImage {
        // create a new image
        var image = NSImage(size: self.imageSize)

        // first draw the graph
        self.drawLineGraph(image: &image, currentValue: currentValue, graphColor: graphColor, gradientColor: gradientColor)

        // draw the border over the graph
        if drawBorder {
            self.drawBorder(image: &image)
        }

        return image
    }

    func drawLineGraph(image: inout NSImage, currentValue: Double, graphColor: NSColor, gradientColor: NSColor?) {
        // add the current value to the history
        self.addValueToHistory(currentValue: currentValue)

        // set the width of the bar to 1
        let barWidth = 1.0

        // lock the image to draw the graph
        image.lockFocus()

        var gradientImage: NSImage?
        if gradientColor != nil {
            gradientImage = getGradientBar(barWidth: barWidth, maxBarHeight: self.maxbarHeight, barColor: graphColor, gradientColor: gradientColor!)
        }

        // iterate the values and draw a bar for each value on the correct position
        var nextValuePosition = self.imageSize.width - self.borderWidth - 1
        for value in valueHistory.makeIterator().reversed() {
            // calculate the height of the bar
            let barHeight = Double((maxValue / self.maxValue) * value)

            // draw the gradient if necessary
            if gradientImage != nil {
                gradientImage!.draw(
                    at: NSPoint(x: nextValuePosition, y: self.borderWidth),
                    from: NSRect(x: 0, y: 0, width: barWidth, height: barHeight),
                    operation: NSCompositingOperation.sourceOver,
                    fraction: 1.0
                )
            } else {
                // create the rect and draw it
                let valueBar = NSRect(x: nextValuePosition, y: self.borderWidth, width: CGFloat(barWidth), height: CGFloat(barHeight))
                graphColor.setFill()
                valueBar.fill()
            }

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
     * Sets the width of the graph.
     */
    func setGraphWidth(width: Int) {
        self.imageSize.width = CGFloat(width)
    }

    // MARK: -
    // MARK: Private Functions

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
