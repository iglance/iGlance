//
//  CustomLogFormatter.swift
//  iGlance
//
//  Created by Dominik on 11.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import CocoaLumberjack

class CustomLogFormatter: NSObject, DDLogFormatter {
    let dateFormatter: DateFormatter

    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.dateFormat = "yy-MM-dd HH:mm:ss:SSS"

        super.init()
    }

    func format(message logMessage: DDLogMessage) -> String? {
        let dateAndTime = dateFormatter.string(from: logMessage.timestamp)

        var logFlag: String = "Error"
        switch logMessage.flag {
        case DDLogFlag.warning:
            logFlag = "Warning"
        case DDLogFlag.info:
            logFlag = "Info"
        case DDLogFlag.debug:
            logFlag = "Debug"
        case DDLogFlag.verbose:
            logFlag = "Verbose"
        default:
            logFlag = "Error"
        }
        return "\(dateAndTime) \(logFlag): [\(logMessage.fileName):\(logMessage.line)]: \(logMessage.message)"
    }
}
