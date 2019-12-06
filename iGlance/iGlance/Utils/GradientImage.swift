//
//  GradientImage.swift
//  iGlance
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Cocoa

final class GradientImage {

    private struct Cache {
        let fromColor: NSColor
        let toColor: NSColor
        let img: NSImage
    }

    private let height: Double
    private let width: Double

    private var cache: Cache?

    init(height: Double, width: Double) {
        self.height = height
        self.width = width
    }

    func create(fromColor: NSColor, toColor: NSColor) -> NSImage {
        if cache?.fromColor == fromColor && cache?.toColor == toColor {
            // return cached image if from/to colors didn't change
            return cache!.img
        }
        let img = NSImage(size: NSSize(width: width, height: height))
        let rect = NSRect(x: 0, y: 0, width: width, height: height)
        img.lockFocus()
        let gradient = NSGradient(starting: fromColor, ending: toColor)
        gradient?.draw(in: rect, angle: CGFloat(90))
        img.unlockFocus()
        cache = Cache(fromColor: fromColor, toColor: toColor, img: img)
        return img
    }

}