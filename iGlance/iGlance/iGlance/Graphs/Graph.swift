//
//  Graph.swift
//  iGlance
//
//  Created by Dominik on 08.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa

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
     */
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
     * Draws a border with rounded cornsers around the image. If the user doesn't want the border to be drawn the function returns immediately.
     */
    func drawBorder(image: inout NSImage) {
        if !AppDelegate.userSettings.settings.cpu.showUsageGraphBorder {
            return
        }

        // lock the focus on the image in order to draw on it
        image.lockFocus()

        // create the rounded rectangle. Keep in mind that the line is drawn centered on the rectangle border.
        let rect = NSRect(
            x: borderWidth / 2, // subtract half the border width to align the graph border to the image border
            y: borderWidth / 2,
            width: self.imageSize.width - borderWidth, // subtract the border width once since half the border of each side has to be subtracted
            height: self.imageSize.height - borderWidth
        )
        let roundedRect = NSBezierPath(roundedRect: rect, xRadius: 1.5, yRadius: 1.5)
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
