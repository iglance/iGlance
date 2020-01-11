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
        return "\(dateAndTime) [\(logMessage.fileName):\(logMessage.line)]: \(logMessage.message)"
    }
}
