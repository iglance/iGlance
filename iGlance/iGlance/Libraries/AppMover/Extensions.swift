//
//  Extensions.swift
//  AppMover
//
//  Created by Oskar Groth on 2019-12-22.
//  Copyright © 2019 Oskar Groth. All rights reserved.
//

import AppKit

extension URL {
    var representsBundle: Bool {
        pathExtension == "app"
    }

    var isValid: Bool {
        !path.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var numberOfFilesInDirectory: Int {
        (try? FileManager.default.contentsOfDirectory(atPath: path))?.count ?? 0
    }
}

extension Bundle {
    /**
     * Returns the localized name of the application
     */
    var localizedName: String {
        NSRunningApplication.current.localizedName ?? "iGlance"
    }

    /**
     * Checks if the currently running app is already in the 'Applications' folder.
     */
    var isInstalled: Bool {
        NSSearchPathForDirectoriesInDomains(.applicationDirectory, .allDomainsMask, true).contains {
            $0.hasPrefix(bundlePath)
        } || bundlePath.split(separator: "/").contains("Applications")
    }

    /**
     * Copies the bundle of the app to the given url.
     */
    func copy(to url: URL) throws {
        try FileManager.default.copyItem(at: bundleURL, to: url)
    }
}

extension Process {
    /**
     * Runs the given terminal command and executes the completion callback afterwards.
     */
    static func runTask(command: String, arguments: [String] = [], completion: ((Int32) -> Void)? = nil) {
        let task = Process()
        task.launchPath = command
        task.arguments = arguments
        task.terminationHandler = { task in
            completion?(task.terminationStatus)
        }
        task.launch()
    }
}
