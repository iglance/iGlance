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

    /**
     * Initializer
     *
     * - Parameter width: width of the graph in pixel
     */
    init(width: Int) {
        super.init()

        self.imageSize.width = CGFloat(width)
    }

    func getImage(currentValue: Double, graphColor: NSColor) -> NSImage {
        // create a new image
        var image = NSImage(size: self.imageSize)

        // draw the border
        self.drawBorder(image: &image)

        return image
    }
}
