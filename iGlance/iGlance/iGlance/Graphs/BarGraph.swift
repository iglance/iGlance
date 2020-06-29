//  Copyright (C) 2020  D0miH <https://github.com/D0miH> & Contributors <https://github.com/iglance/iGlance/graphs/contributors>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Cocoa
import CocoaLumberjack

struct Key: Hashable {
    let value: Double
    let isDarkTheme: Bool
}

class BarGraph: Graph {
    // MARK: -
    // MARK: Public Instance Variables
    /// The maximum value which corresponds to 100% of the bar graph
    let maxValue: Double

    // MARK: -
    // MARK: Private Instance Variables
    private var imageCache: [Key: NSImage] = [Key: NSImage]()

    /// The maximum height of the bar of the graph in pixel
    private var maxBarHeight: Double {
        Double(self.imageSize.height - self.borderWidth * 2)
    }

    /// The width of the bar of the graph in pixel
    private var barWidth: Double {
        Double(self.imageSize.width - self.borderWidth * 2)
    }

    // MARK: -
    // MARK: Public Instance Variables

    /**
     * Initializer of the BarGraph class.
     *
     * - Parameter maxValue: The maximum value that is reached when the bar is at 100%
     */
    init(maxValue: Double) {
        // set the maximum value for the bar
        self.maxValue = maxValue

        // call the super initializer
        super.init()

        // set the width of the bar graph
        self.imageSize.width = 9.0
    }

    /**
     * Returns the bar graph image for the menu bar.
     */
    func getImage(currentValue: Double, graphColor: NSColor, drawBorder: Bool, gradientColor: NSColor?) -> NSImage {
        // get the rounded bar height
        var barHeight = Double((maxBarHeight / self.maxValue) * currentValue)
        barHeight = Double(round(barHeight * 100) / 100)
        // check whether we need to redraw the graph
        let key = Key(value: barHeight, isDarkTheme: ThemeManager.isDarkTheme())

        if imageCache[key] != nil {
            DDLogInfo("Using image from cache")
            return imageCache[key]!
        }

        // create a new image with the same size as the border image
        var image = NSImage(size: self.imageSize)

        // first draw the bar to draw over the sharp corners of the bar
        self.drawBarGraph(image: &image, currentValue: currentValue, barColor: graphColor, gradientColor: gradientColor)

        // draw the border of the graph
        if drawBorder {
            self.drawBorder(image: &image)
        }

        // add the image and its color to the cache
        imageCache[key] = image

        DDLogInfo("Cached bar graph for value (\(currentValue)) and color (\(graphColor.toHex()))")

        return image
    }

    /**
     * Clears the image cache of the bar graph. This function should be called when the appearance of the graph did change.
     */
    func clearImageCache() {
        imageCache.removeAll()
    }

    // MARK: -
    // MARK: Private Instance Functions

    /**
     * Takes an image and draws the bar on the given image
     */
    private func drawBarGraph(image: inout NSImage, currentValue: Double, barColor: NSColor, gradientColor: NSColor?) {
        // if the current value is zero we don't have to draw anything and can return immediately
        if currentValue == 0 {
            return
        }

        // lock the focus on the image in order to draw on it
        image.lockFocus()

        // get the height of the bar
        var barHeight = Double((maxBarHeight / self.maxValue) * currentValue)
        // round the height to two decimal places
        barHeight = Double(round(barHeight * 100) / 100)

        // draw the gradient if necessary
        if gradientColor != nil {
            // get the gradient image
            let gradientImage = getGradientBar(barWidth: barWidth, maxBarHeight: maxBarHeight, barColor: barColor, gradientColor: gradientColor!)

            // draw the gradient image only has high as the current bar height
            gradientImage.draw(
                at: NSPoint(x: self.borderWidth, y: self.borderWidth),
                from: NSRect(x: 0, y: 0, width: barWidth, height: barHeight),
                operation: NSCompositingOperation.sourceOver,
                fraction: 1.0
            )

            image.unlockFocus()
            return
        }

        // set the bar color as a fill color
        barColor.set()

        // create the bar as a rectangle
        let bar = NSRect(x: self.borderWidth, y: self.borderWidth, width: CGFloat(barWidth), height: CGFloat(barHeight))
        bar.fill()

        // unlock the focus of the image
        image.unlockFocus()
    }
}
