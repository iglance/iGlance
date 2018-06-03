//
// main.swift
// SystemKit
//
// The MIT License
//
// Copyright (C) 2014, 2015  beltex <https://github.com/beltex>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SystemKit

println("// MACHINE STATUS")

println("\n-- CPU --")
println("\tPHYSICAL CORES:  \(System.physicalCores())")
println("\tLOGICAL CORES:   \(System.logicalCores())")

var sys = System()
let cpuUsage = sys.usageCPU()
println("\tSYSTEM:          \(Int(cpuUsage.system))%")
println("\tUSER:            \(Int(cpuUsage.user))%")
println("\tIDLE:            \(Int(cpuUsage.idle))%")
println("\tNICE:            \(Int(cpuUsage.nice))%")


println("\n-- MEMORY --")
println("\tPHYSICAL SIZE:   \(System.physicalMemory())GB")

let memoryUsage = System.memoryUsage()
func memoryUnit(value: Double) -> String {
    if value < 1.0 { return String(Int(value * 1000.0))    + "MB" }
    else           { return NSString(format:"%.2f", value) as String + "GB" }
}

println("\tFREE:            \(memoryUnit(memoryUsage.free))")
println("\tWIRED:           \(memoryUnit(memoryUsage.wired))")
println("\tACTIVE:          \(memoryUnit(memoryUsage.active))")
println("\tINACTIVE:        \(memoryUnit(memoryUsage.inactive))")
println("\tCOMPRESSED:      \(memoryUnit(memoryUsage.compressed))")


println("\n-- SYSTEM --")
println("\tMODEL:           \(System.modelName())")

let names = System.uname()
println("\tSYSNAME:         \(names.sysname)")
println("\tNODENAME:        \(names.nodename)")
println("\tRELEASE:         \(names.release)")
println("\tVERSION:         \(names.version)")
println("\tMACHINE:         \(names.machine)")

let uptime = System.uptime()
println("\tUPTIME:          \(uptime.days)d \(uptime.hrs)h \(uptime.mins)m " +
                            "\(uptime.secs)s")

let counts = System.processCounts()
println("\tPROCESSES:       \(counts.processCount)")
println("\tTHREADS:         \(counts.threadCount)")

let loadAverage = System.loadAverage().map { NSString(format:"%.2f", $0) }
println("\tLOAD AVERAGE:    \(loadAverage)")
println("\tMACH FACTOR:     \(System.machFactor())")


println("\n-- POWER --")
let cpuThermalStatus = System.CPUPowerLimit()

println("\tCPU SPEED LIMIT: \(cpuThermalStatus.processorSpeed)%")
println("\tCPUs AVAILABLE:  \(cpuThermalStatus.processorCount)")
println("\tSCHEDULER LIMIT: \(cpuThermalStatus.schedulerTime)%")

println("\tTHERMAL LEVEL:   \(System.thermalLevel().rawValue)")

var battery = Battery()
if battery.open() != kIOReturnSuccess { exit(0) }

println("\n-- BATTERY --")
println("\tAC POWERED:      \(battery.isACPowered())")
println("\tCHARGED:         \(battery.isCharged())")
println("\tCHARGING:        \(battery.isCharging())")
println("\tCHARGE:          \(battery.charge())%")
println("\tCAPACITY:        \(battery.currentCapacity()) mAh")
println("\tMAX CAPACITY:    \(battery.maxCapactiy()) mAh")
println("\tDESGIN CAPACITY: \(battery.designCapacity()) mAh")
println("\tCYCLES:          \(battery.cycleCount())")
println("\tMAX CYCLES:      \(battery.designCycleCount())")
println("\tTEMPERATURE:     \(battery.temperature())°C")
println("\tTIME REMAINING:  \(battery.timeRemainingFormatted())")

battery.close()
