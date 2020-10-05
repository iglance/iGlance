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

public enum GraphKind: Codable {
    case line
    case bar

    enum Key: CodingKey {
        case rawValue
    }

    enum CodingError: Error {
        case unknownValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .line
        case 1:
            self = .bar
        default:
            throw CodingError.unknownValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .line:
            try container.encode(0, forKey: .rawValue)
        case .bar:
            try container.encode(1, forKey: .rawValue)
        }
    }
}

protocol GraphProtocol {
    /**
     * Returns the image with the graph and its border drawn on it.
     *
     * - Parameter currentValue: The current value (most recent value) in the graph.
     * - Parameter graphColor: The color of the graph
     * - Parameter gradientColor: This color is used to draw the gradient. If this value is nil, no gradient is drawn.
     */
    func getImage(currentValue: Double, graphColor: NSColor, drawBorder: Bool, gradientColor: NSColor?) -> NSImage

    func drawBorder(image: inout NSImage)
}

class GraphClass {
    // MARK: -
    // MARK: Instance Variables
    var imageSize: NSSize

    // MARK: -
    // MARK: Instance Constants
    let borderWidth = CGFloat(1.0)

    let contentMargin = CGFloat(1.0)

    init() {
        self.imageSize = NSSize(width: 9, height: 18)
    }

    /**
     * Draws a border with rounded cornsers around the image. If the user doesn't want the border to be drawn the function returns immediately.
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
        let roundedRect = NSBezierPath(roundedRect: rect, xRadius: 3.0, yRadius: 3.0)
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

    /**
     * Returns a gradient bar as an image. We will render this gradient bar only partly according to the current graph value.
     */
    internal func getGradientBar(barWidth: Double, maxBarHeight: Double, barColor: NSColor, gradientColor: NSColor) -> NSImage {
        // create an image for the gradient bar
        let gradientImage = NSImage(size: NSSize(width: barWidth, height: maxBarHeight))

        // create the whole rect for the gradient. We will only render this rect partly
        let gradientRect = NSRect(x: 0, y: 0, width: CGFloat(barWidth), height: CGFloat(maxBarHeight))
        let roundedRect = NSBezierPath(roundedRect: gradientRect, xRadius: 1.5, yRadius: 1.5)

        // lock the gradient image
        gradientImage.lockFocus()

        // create the gradient
        guard let gradient = NSGradient(starting: barColor, ending: gradientColor) else {
            DDLogError("Failed to create the gradient")

            // return a one colored bar
            barColor.setFill()
            roundedRect.fill()
            gradientImage.unlockFocus()

            return gradientImage
        }

        // draw the gradient into the rectangle
        gradient.draw(in: roundedRect, angle: 90)

        // unlock the focus of the image
        gradientImage.unlockFocus()

        return gradientImage
    }
}

typealias Graph = GraphClass & GraphProtocol
