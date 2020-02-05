//
//  CodableColor.swift
//  iGlance
//
//  Created by Dominik on 05.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa

struct CodableColor: Codable {
    var red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 0.0

    var nsColor: NSColor {
        NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(nsColor: NSColor) {
        red = nsColor.redComponent
        green = nsColor.greenComponent
        blue = nsColor.blueComponent
        alpha = nsColor.alphaComponent
    }
}
