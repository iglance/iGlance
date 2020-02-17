//
//  FanInfo.swift
//  iGlance
//
//  Created by Dominik on 17.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import SMCKit
import CocoaLumberjack

class FanInfo {
    /**
     * Returns the number of fans of the machine. If an error occurred the function returns 0.
     */
    func getNumberOfFans() -> Int {
        do {
            let numFans = try SMCKit.fanCount()

            DDLogInfo("Read fan count: \(numFans)")

            return numFans
        } catch SMCKit.SMCError.keyNotFound {
            DDLogError("The given SMC key was not found")
        } catch SMCKit.SMCError.notPrivileged {
            DDLogError("Not privileged to read the SMC")
        } catch {
            DDLogError("An unknown error occurred while reading the SMC")
        }

        return 0
    }
}
