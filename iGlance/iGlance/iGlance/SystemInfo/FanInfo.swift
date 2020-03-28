//  Copyright (C) 2020  D0miH <https://github.com/D0miH> & Contributors <https://github.com/iglance/iGlance/graphs/contributors>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

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

    /**
     * Returns the minimum fan speed of the fan with the given id. If an error occured the function returns 0
     */
    func getMinFanSpeed(id: Int) -> Int {
        do {
            let minFanSpeed = try SMCKit.fanMinSpeed(id)

            DDLogInfo("Read min fan speed: \(minFanSpeed)")

            return minFanSpeed
        } catch SMCKit.SMCError.keyNotFound {
            DDLogError("SMCKey to read the minimum fan speed was not found")
        } catch SMCKit.SMCError.notPrivileged {
            DDLogError("Not privileged to read the minimum fan speed")
        } catch {
            DDLogError("Unknown error occured while reading the minimum fan speed")
        }

        return 0
    }

    /**
     * Returns the maximum fan speed of the fan with the given id. If an error occured the function returns 0
     */
    func getMaxFanSpeed(id: Int) -> Int {
        do {
            let maxFanSpeed = try SMCKit.fanMaxSpeed(id)

            DDLogInfo("Read max fan speed: \(maxFanSpeed)")

            return maxFanSpeed
        } catch SMCKit.SMCError.keyNotFound {
            DDLogError("SMCKey to read the maximum fan speed was not found")
        } catch SMCKit.SMCError.notPrivileged {
            DDLogError("Not privileged to read the maximum fan speed")
        } catch {
            DDLogError("Unknown error occured while reading the maximum fan speed")
        }

        return 0
    }

    /**
     * Returns the current fan speed of the fan with the given id. If an error occurred the function returns 0.
     */
    func getCurrentFanSpeed(id: Int) -> Int {
        do {
            let curFanSpeed = try SMCKit.fanCurrentSpeed(id)

            DDLogInfo("Read current fan speed: \(curFanSpeed)")

            return curFanSpeed
        } catch SMCKit.SMCError.keyNotFound {
            DDLogError("SMCKey to read the current fan speed was not found")
        } catch SMCKit.SMCError.notPrivileged {
            DDLogError("Not privileged to read the current fan speed")
        } catch {
            DDLogError("Unknown error occured while reading the current fan speed")
        }

        return 0
    }
}
