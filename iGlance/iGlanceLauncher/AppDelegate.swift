//
//  AppDelegate.swift
//  iGlanceLauncher
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

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        let mainAppIdentifier = "io.iglance.iGlance"
        let running = NSWorkspace.shared.runningApplications
        var alreadyRunning = false

        // loop through running apps - check if the Main application is running
        for app in running {
            if app.bundleIdentifier == mainAppIdentifier {
                alreadyRunning = true
                break
            }
        }

        if !alreadyRunning {
            // Register for the notification killme
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(justTerminate), name: NCConstants.KILLME, object: mainAppIdentifier)

            // Get the path of the current app and navigate through them to find the Main Application
            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            components.removeLast(3)
            components.append("MacOS")
            components.append("iGlance")

            let newPath = NSString.path(withComponents: components)

            // Launch the Main application
            print(newPath)
            NSWorkspace.shared.launchApplication(newPath)
        } else {
            // Main application is already running
            sleep(15)
            NSApp.terminate(nil)
        }
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }

    @objc func justTerminate() {
        sleep(15)
        NSApp.terminate(nil)
    }
}

class NCConstants { // Notify constant
    static let KILLME = Notification.Name("killme")
}
