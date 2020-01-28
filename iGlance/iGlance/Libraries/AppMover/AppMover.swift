//
//  AppMover.swift
//  AppMover
//
//  Created by Oskar Groth on 2019-12-20.
//  Copyright © 2019 Oskar Groth. All rights reserved.
//

import AppKit
import Security
import CocoaLumberjack

public enum AppMover {
    public static func moveIfNecessary() {
        let fm = FileManager.default
        guard !Bundle.main.isInstalled, let applications = preferredInstallDirectory() else {
            DDLogInfo("App is already in the 'Applications' folder")
            return
        }

        // compound the path to the destination in the 'Applications' folder
        let bundleUrl = Bundle.main.bundleURL
        let bundleName = bundleUrl.lastPathComponent
        let destinationUrl = applications.appendingPathComponent(bundleName)

        // check whether the app can be written to the destination or it needs authentication of the user
        let needDestAuth = fm.fileExists(atPath: destinationUrl.path) && !fm.isWritableFile(atPath: destinationUrl.path)
        let needAuth = needDestAuth || !fm.isWritableFile(atPath: applications.path)

        // Activate app -- work-around for focus issues related to "scary file from
        // internet" OS dialog.
        if !NSApp.isActive {
            NSApp.activate(ignoringOtherApps: true)
        }

        // create the dialog to move the app
        let alert = NSAlert()
        alert.messageText = "Move to Applications folder"
        alert.informativeText = "\(Bundle.main.localizedName) needs to move to your Applications folder in order to work properly."
        if needAuth {
            alert.informativeText.append(" You need to authenticate with your administrator password to complete this step.")
        }
        alert.addButton(withTitle: "Move to Applications Folder")
        alert.addButton(withTitle: "Do Not Move")

        // run the modal; if the user click cancel just return
        guard alert.runModal() == .alertFirstButtonReturn else {
            DDLogInfo("App was not moved into the 'Applications' folder")
            return
        }

        // if authentication is required get the
        if needAuth {
            // move the app with admin privileges
            let result = authorizedInstall(from: bundleUrl, to: destinationUrl)
            // if the command was cancelled start all over again
            guard !result.cancelled else {
                DDLogError("The command to move the app into the 'Applications' folder was cancelled")
                moveIfNecessary()
                return
            }
            // if we had success terminate the app
            guard result.success else {
                DDLogInfo("Application was successfully moved into the 'Aplications' folder")
                NSApplication.shared.terminate(self)
                return
            }
        } else {
            if fm.fileExists(atPath: destinationUrl.path) {
                if AppMover.isApplicationAtUrlRunning(destinationUrl) {
                    NSWorkspace.shared.open(destinationUrl)
                    return
                } else {
                    guard (try? fm.trashItem(at: destinationUrl, resultingItemURL: nil)) != nil else {
                        return
                    }
                }
            }
            guard (try? fm.copyItem(at: bundleUrl, to: destinationUrl)) != nil else {
                return
            }
        }

        // Trash the original app
        _ = try? fm.removeItem(at: bundleUrl)

        relaunch(at: destinationUrl.path) {
            DispatchQueue.main.async {
                exit(0)
            }
        }
    }

    /**
     * Copies the app from the source url to the given destination url. The file at the source url is **NOT** deleted.
     */
    static func authorizedInstall(from sourceURL: URL, to destinationURL: URL) -> (cancelled: Bool, success: Bool) {
        // check the variables for nil
        guard destinationURL.representsBundle, destinationURL.isValid, sourceURL.isValid else {
            return (false, false)
        }

        return sourceURL.withUnsafeFileSystemRepresentation { sourcePath -> (cancelled: Bool, success: Bool) in
                destinationURL.withUnsafeFileSystemRepresentation { destinationPath -> (cancelled: Bool, success: Bool) in
                    // check the source path and the destination path for nil
                    guard let sourcePath = sourcePath, let destinationPath = destinationPath else {
                        return (false, false)
                    }

                    // delete everything on the destination path
                    let deleteCommand = "rm -rf '\(String(cString: destinationPath))'"
                    // copy the app from the source path to the destination path
                    let copyCommand = "cp -pR '\(String(cString: sourcePath))' '\(String(cString: destinationPath))'"
                    // execute the commands with admin privileges
                    guard let script = NSAppleScript(source: "do shell script \"\(deleteCommand) && \(copyCommand)\" with administrator privileges") else {
                        return (false, false)
                    }
                    var error: NSDictionary?
                    script.executeAndReturnError(&error)
                    return ((error?[NSAppleScript.errorNumber] as? Int16) == -128, error == nil)
                }
        }
    }

    static func preferredInstallDirectory() -> URL? {
        let fm = FileManager.default
        let dirs = fm.urls(for: .applicationDirectory, in: .allDomainsMask)
        // Find Applications dir with the most apps that isn't system protected
        // swiftlint:disable:next sorted_first_last
        return dirs.map { $0.resolvingSymlinksInPath() }
                    .filter { url in
                        var isDir: ObjCBool = false
                        fm.fileExists(atPath: url.path, isDirectory: &isDir)
                        return isDir.boolValue && url.path != "/System/Applications"
                    }
                    .sorted { left, right in
                        left.numberOfFilesInDirectory < right.numberOfFilesInDirectory
                    }.last
    }

    static func isApplicationAtUrlRunning(_ url: URL) -> Bool {
        let url = url.standardized
        return NSWorkspace.shared.runningApplications.contains {
            $0.bundleURL?.standardized == url
        }
    }

    /**
     * Removes the quarantine attribute and relaunches the application.
     */
    public static func relaunch(at path: String, completionCallback: @escaping () -> Void) {
        let pid = ProcessInfo.processInfo.processIdentifier
        Process.runTask(command: "/usr/bin/xattr", arguments: ["-d", "-r", "com.apple.quarantine", path]) { _ in
            let waitForExitScript = "(while /bin/kill -0 \(pid) >&/dev/null; do /bin/sleep 0.1; done; /usr/bin/open \(path)) &"
            Process.runTask(command: "/bin/sh", arguments: ["-c", waitForExitScript])
            completionCallback()
        }
    }
}
