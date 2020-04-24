//
//  Logger.swift
//  iGlance
//
//  Created by Dominik on 29.03.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack

class Logger {
    let fileLogger: DDFileLogger

    init() {
        // set the custom log formatter
        DDOSLogger.sharedInstance.logFormatter = CustomLogFormatter()
        // add the loggers to the loggin framework
        DDLog.add(DDOSLogger.sharedInstance)

        // register the logger
        // logs are saved under /Library/Logs/iGlance/
        fileLogger = DDFileLogger()
        fileLogger.logFormatter = CustomLogFormatter()
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)

        // set the default log level to error
        dynamicLogLevel = .error

        if AppDelegate.userSettings.settings.advancedLogging {
            // log all messages
            dynamicLogLevel = .all
        }
    }

    func saveMostRecentLogFile() {
        // get the log file paths
        let logfilePaths = self.fileLogger.logFileManager.sortedLogFilePaths

        // check if there are any log files
        if logfilePaths.isEmpty {
            Dialog.showErrorModal(messageText: "Error", informativeText: "No logfiles were found")

            DDLogError("No log files were found")
            return
        }
        let mostRecentLogFileUrl = URL(fileURLWithPath: logfilePaths.first!)

        // create the save panel
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = mostRecentLogFileUrl.lastPathComponent

        savePanel.begin { result in
            if result == .OK {
                var success = false
                if let destUrl = savePanel.url {
                    success = self.saveLogFile(logFileUrl: mostRecentLogFileUrl, destinationUrl: destUrl)
                }

                if !success {
                    Dialog.showErrorModal(messageText: "Error", informativeText: "Something went wrong while saving the log file")
                    DDLogError("Somethings went wrong while saving the log file")
                    return
                }

                DDLogInfo("The log file \(mostRecentLogFileUrl.lastPathComponent) was successfully saved")
            } else if result == .cancel {
                DDLogInfo("The save logfile dialog was cancelled")
            }
        }
    }

    /**
     * Saves the log file which is located at the given path to the given destination path.
     *
     *  - Parameter logFileUrl: The url of the log file that is going to be saved.
     *  - Parameter destinationUrl: The url of the destination where the log file is going to be saved.
     */
    func saveLogFile(logFileUrl: URL, destinationUrl: URL) -> Bool {
        // get the default file manager of the process
        let fileManager = FileManager.default

        // copy the log file to the destination
        do {
            try fileManager.copyItem(at: logFileUrl, to: destinationUrl)
            return true
        } catch {
            DDLogError("Failed to copy the log file to the destination")
            return false
        }
    }

    func updateLogSettings() {
        if AppDelegate.userSettings.settings.advancedLogging {
            // log all messages
            dynamicLogLevel = .all
        } else {
            dynamicLogLevel = .error
        }
    }
}
