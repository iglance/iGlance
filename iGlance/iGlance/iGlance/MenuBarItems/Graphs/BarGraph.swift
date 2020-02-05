//
//  BarGraph.swift
//  iGlance
//
//  Created by Dominik on 04.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

struct Key: Hashable {
    let value: Double
    let isDarkTheme: Bool
}

class BarGraph {
    var barBorder: NSImage!

    var borderImageSize: NSSize!

    let maxValue: Double

    private var imageCache: [Key: (image: NSImage, color: NSColor)] = [Key: (image: NSImage, color: NSColor)]()

    /**
     * Initializer of the BarGraph class.
     *
     * - Parameter maxValue: The maximum value that is reached when the bar is at 100%
     */
    init(maxValue: Double) {
        // set the maximum value for the bar
        self.maxValue = maxValue

        // get the image (getting it every time we draw the image ensures that it adapts to the current osx theme)
        self.barBorder = NSImage(named: "BarGraphBorder")
        // update the size variable of the image
        self.borderImageSize = self.barBorder.size
    }

    /**
     * Returns the bar graph image for the menu bar.
     */
    func getImage(currentValue: Double, barColor: NSColor) -> NSImage {
        // check whether we need to redraw the graph
        let key = Key(value: currentValue, isDarkTheme: ThemeManager.isDarkTheme())
        if imageCache[key] != nil && imageCache[key]!.color == barColor {
            return imageCache[key]!.image
        }

        // create a new image with the same size as the border image
        var image = NSImage(size: self.borderImageSize)
        // lock the focus on the image in order to draw on it
        image.lockFocus()

        // tint the image for dark/light mode
        let tintedBarBorder = self.barBorder.tint(color: key.isDarkTheme ? NSColor.white : NSColor.black)
        // draw the usage bar border
        tintedBarBorder.draw(at: NSPoint.zero, from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

        // draw the usage bar
        self.drawUsageBar(image: &image, currentValue: currentValue, barColor: barColor)

        // unlock the focus of the image
        image.unlockFocus()

        // add the image and its color to the cache
        imageCache[key] = (image, barColor)

        return image
    }

    /**
     * Takes an image and draws the usage bar on the given image
     */
    private func drawUsageBar( image: inout NSImage, currentValue: Double, barColor: NSColor) {
        // get the maximum height of the bar.
        // Keep in mind that the border of the graph is 1 pixel wide. However the 2x picture is used which is why we subtract 2 / 2 = 1 pixel
        let maxBarHeight = Double(self.barBorder.size.height - 1)

        // get the width of the bar
        let barWidth = Double(self.barBorder.size.width - 1)
        // get the height of the bar
        let barHeight = Double((maxBarHeight / self.maxValue) * currentValue)

        // set the bar color as a fill color
        barColor.setFill()

        // create the usage bar as a rectangle
        // 1 / 2 = 0.5 pixel offset since the 2x image is used and the border is 1 pixel wide
        let usageBar = NSRect(x: 0.5, y: 0.5, width: barWidth, height: barHeight)
        usageBar.fill()

        // set the current fill color to clear
        NSColor.clear.setFill()
    }
}
