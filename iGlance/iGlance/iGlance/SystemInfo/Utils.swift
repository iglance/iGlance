//
//  Utils.swift
//  iGlance
//
//  Created by Dominik on 19.04.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack

/**
 * Executes the program that is located at the given launch path with the given arguments.
 *
 * - Returns: The output of the command as a string.
 */
func executeCommand(launchPath: String, arguments: [String]) -> String? {
    let task = Process()
    let outputPipe = Pipe()

    // execute the command
    task.launchPath = launchPath
    task.arguments = arguments
    task.standardOutput = outputPipe
    task.launch()
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: outputData, encoding: String.Encoding.utf8) else {
        DDLogError("An error occurred while casting the command output to a string")
        return nil
    }

    return output
}
