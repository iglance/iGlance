//
//  AppDelegate.swift
//  iGlanceLauncher
//
//  Created by Cemal on 06.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainAppIdentifier = "noorganization.iGlance"
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
        }
        else {
            // Main application is already running
            NSApp.terminate(nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func justTerminate()
    {
        NSApp.terminate(nil)
    }

}


class NCConstants { // Notify constant
    static let KILLME = Notification.Name("killme")
    
}
