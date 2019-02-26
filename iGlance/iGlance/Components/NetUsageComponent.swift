//
//  BandwidthComponent.swift
//  iGlance
//
//  MIT License
//
//  Copyright (c) 2018 Cemal K <https://github.com/Moneypulation>, Dominik H <https://github.com/D0miH>
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

class NetUsageComponent {
    // the menu bar item
    static let sItemBandwidth = NSStatusBar.system.statusItem(withLength: 62.0)
    // the button of the menu bar icon
    var btnBandwidth: NSStatusBarButton?
    // the menu of the item
    var menuBandwidth: NSMenu?

    /**
     *  The variables to store the current and last down-/uploadspeed
     */
    var dSpeed: UInt64?
    var uSpeed: UInt64?
    var dSpeedLast: UInt64?
    var uSpeedLast: UInt64?

    /**
     * Image variables for the menu bar icon
     */
    var bandIMG: String?
    var bandColor: NSColor?
    var bandText: String?
    var finalDown: String?
    var finalUp: String?
    var pbFillRectBandwidth: NSRect?
    var dLength: Int?
    var uLength: Int?

    // create a menu item for the downloaded data in the last hour
    var bandwidthDUsageItem = NSMenuItem(title: "Download Last Hour:\t\t NA", action: nil, keyEquivalent: "")
    // create a menu item for the uploaded data during the last hour
    var bandwidthUUsageItem = NSMenuItem(title: "Upload Last Hour:\t\t NA", action: nil, keyEquivalent: "")

    // TODO: comment
    var bandwidthDUsageArray = Array(repeating: UInt64(0), count: 3600)
    var bandwidthDUsageArrayIndex = 0
    var bandwidthUUsageArray = Array(repeating: UInt64(0), count: 3600)
    var bandwidthUUsageArrayIndex = 0

    // the seperate process to monitor the bandwidth usage
    var bandwidthProcess: Process?

    var curr: Array<Substring>?

    func initialize() {
        // start the seperate process to monitor the bandwidth
        startMonitoringProcess()

        // create the menu
        createMenu()

        // create the button
        btnBandwidth = NetUsageComponent.sItemBandwidth.button
        dLength = 6
        uLength = 6
        bandText = ""
    }

    func createMenu() {
        menuBandwidth = NSMenu()
        menuBandwidth?.addItem(bandwidthDUsageItem)
        menuBandwidth?.addItem(bandwidthUUsageItem)
        menuBandwidth?.addItem(NSMenuItem.separator())
        menuBandwidth?.addItem(NSMenuItem(title: "Settings", action: #selector(AppDelegate.settings_clicked), keyEquivalent: "s"))
        menuBandwidth?.addItem(NSMenuItem.separator())
        menuBandwidth?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        NetUsageComponent.sItemBandwidth.menu = menuBandwidth
    }

    /**
     *  Creates a new process to monitor the network usage.
     */
    func startMonitoringProcess() {
        // Create a Task instance
        bandwidthProcess = Process()

        // Set the task parameters
        bandwidthProcess?.launchPath = "/usr/bin/env"
        bandwidthProcess?.arguments = ["netstat", "-w1", "-l", "en0"]

        // Create a Pipe and make the task
        // put all the output there
        let pipe = Pipe()
        bandwidthProcess?.standardOutput = pipe

        let outputHandle = pipe.fileHandleForReading

        // outputHandle.waitForDataInBackgroundAndNotify()
        outputHandle.waitForDataInBackgroundAndNotify(forModes: [RunLoop.Mode.common])

        // When new data is available execute the function of the observer
        var dataAvailable: NSObjectProtocol!
        dataAvailable = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputHandle, queue: nil) { _ -> Void in
            let data = pipe.fileHandleForReading.availableData
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    self.curr = [""]
                    self.curr = str.replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").split(separator: " ")
                    if self.curr == nil || (self.curr?.count)! < 6 {} else {
                        if Int64(self.curr![2]) == nil {} else {
                            self.dSpeed = UInt64(self.curr![2])
                            self.uSpeed = UInt64(self.curr![5])
                        }
                    }
                }
                outputHandle.waitForDataInBackgroundAndNotify()
            } else {
                NotificationCenter.default.removeObserver(dataAvailable)
            }
        }

        // When task has finished execute the function of the observer
        var dataReady: NSObjectProtocol!
        dataReady = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: pipe.fileHandleForReading, queue: nil) { _ -> Void in
            print("Task terminated!")
            NotificationCenter.default.removeObserver(dataReady)
        }

        // launch the process
        bandwidthProcess?.launch()
    }

    /**
     *  Returns the total amount of downloaded bytes.
     *  - returns:  The amount downloaded bytes as UInt64.
     */
    func getTotalDownloaded() -> UInt64 {
        var total = UInt64(0)
        for num in bandwidthDUsageArray {
            total += num
        }
        return total
    }

    /**
     *  Returns the total amount of uploaded bytes.
     *  - returns: The amount uploaded bytes as UInt64.
     */
    func getTotalUploaded() -> UInt64 {
        var total = UInt64(0)
        for num in bandwidthUUsageArray {
            total += num
        }
        return total
    }

    func updateNetUsage() {
        var needUpdate = false

        // checks if the download or upload speed changed
        if dSpeed != dSpeedLast {
            needUpdate = true
        }
        if uSpeed != uSpeedLast {
            needUpdate = true
        }

        // if an update is needed
        if needUpdate {
            updateMenuBarText(down: dSpeed!, up: uSpeed!)
            dSpeedLast = dSpeed
            uSpeedLast = uSpeed

            bandwidthDUsageArray[bandwidthDUsageArrayIndex] = dSpeedLast!
            bandwidthDUsageArrayIndex += 1

            if bandwidthDUsageArrayIndex == bandwidthDUsageArray.count - 1 {
                bandwidthDUsageArrayIndex = 0
            }

            bandwidthUUsageArray[bandwidthUUsageArrayIndex] = uSpeedLast!
            bandwidthUUsageArrayIndex += 1

            if bandwidthUUsageArrayIndex == bandwidthUUsageArray.count {
                bandwidthUUsageArrayIndex = 0
            }

            updateMenuText(down: getTotalDownloaded(), up: getTotalUploaded())
        }

        if InterfaceStyle() == InterfaceStyle.Dark {
            bandIMG = "bandwidth-white"
            bandColor = NSColor.white
        } else {
            bandIMG = "bandwidth-black"
            bandColor = NSColor.black
        }

        let imgFinal = NSImage(size: NSSize(width: 60, height: 18))
        imgFinal.lockFocus()
        let img1 = NSImage(named: NSImage.Name(bandIMG!))

        img1?.draw(at: NSPoint(x: 2, y: 3), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0.00000001

        dLength = finalDown?.count
        uLength = finalUp?.count

        let font = NSFont(name: "Apple SD Gothic Neo Bold", size: 11.0)
        let fontSmall = NSFont(name: "Apple SD Gothic Neo Bold", size: 8.0)
        let attrString = NSMutableAttributedString(string: finalDown ?? "0 KB/s")
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(.font, value: font as Any, range: NSMakeRange(0, attrString.length - 4))
        attrString.addAttribute(.font, value: fontSmall as Any, range: NSMakeRange(attrString.length - 4, 4))
        attrString.addAttribute(.foregroundColor, value: bandColor ?? NSColor.white, range: NSMakeRange(0, attrString.length))
        attrString.draw(at: NSPoint(x: 16, y: 6))

        let attrString2 = NSMutableAttributedString(string: finalUp ?? "0 KB/s")
        attrString2.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString2.length))
        attrString2.addAttribute(.font, value: font as Any, range: NSMakeRange(0, attrString2.length - 4))
        attrString2.addAttribute(.font, value: fontSmall as Any, range: NSMakeRange(attrString2.length - 4, 4))
        attrString2.addAttribute(.foregroundColor, value: bandColor ?? NSColor.white, range: NSMakeRange(0, attrString2.length))
        attrString2.draw(at: NSPoint(x: 16, y: -4))
        imgFinal.unlockFocus()
        btnBandwidth?.image = imgFinal
    }

    /**
     *  Updates the displayed download and upload speed with given values.
     *  - parameter down:   The download speed that should be displayed.
     *  - parameter up:     The upload speed that should be displayed.
     */
    func updateMenuBarText(down: UInt64, up: UInt64) {
        // display different units for different values
        if down < 1024 {
            // B
            finalDown = "0 KB/s"
        } else if down < 1_048_576 {
            // KB
            finalDown = String((Int(down / 1024) / 4) * 4) + " KB/s"
        } else {
            // MB
            finalDown = String(format: "%.1f", Double(down) / 1_048_576.0) + " MB/s"
        }
        if up < 1024 {
            // B
            finalUp = "0 KB/s"
        } else if up < 1_048_576 {
            // KB
            finalUp = String((Int(up / 1024) / 4) * 4) + " KB/s"
        } else {
            // MB
            finalUp = String(format: "%.1f", Double(up) / 1_048_576.0) + " MB/s"
        }

        // update the text
        bandText = finalDown! + "\n" + finalUp!
    }

    /**
     *  Updates the text of the menu entries.
     *  - parameter down:   The download
     */
    func updateMenuText(down: UInt64, up: UInt64) {
        var mFinalDown = ""
        var mFinalUp = ""
        if down < 1024 {
            // B
            mFinalDown = "0 KB"
        } else if down < 1_048_576 {
            // KB
            mFinalDown = String((Int(down / 1024) / 4) * 4) + " KB"
        } else if down < 1_073_741_824 {
            // MB
            mFinalDown = String(format: "%.1f", Double(down) / 1_048_576.0) + " MB"
        } else {
            // GB
            mFinalDown = String(format: "%.1f", Double(down) / 1_073_741_824.0) + " GB"
        }

        if up < 1024 {
            // B
            mFinalUp = "0 KB"
        } else if up < 1_048_576 {
            // KB
            mFinalUp = String((Int(up / 1024) / 4) * 4) + " KB"
        } else if up < 1_073_741_824 {
            // MB
            mFinalUp = String(format: "%.1f", Double(up) / 1_048_576.0) + " MB"
        } else {
            // GB
            mFinalUp = String(format: "%.1f", Double(up) / 1_073_741_824.0) + " GB"
        }

        bandwidthDUsageItem.title = "Download Last Hour:\t\t " + mFinalDown
        bandwidthUUsageItem.title = "Upload Last Hour:\t\t " + mFinalUp
    }
}
