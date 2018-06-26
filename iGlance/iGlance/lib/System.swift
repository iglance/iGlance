//
// System.swift
// SystemKit
//
// The MIT License
//
// Copyright (C) 2014-2017  beltex <https://github.com/beltex>
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

import Darwin
import IOKit.pwr_mgt
import Foundation

//------------------------------------------------------------------------------
// MARK: PRIVATE PROPERTIES
//------------------------------------------------------------------------------


// As defined in <mach/tash_info.h>

private let HOST_BASIC_INFO_COUNT         : mach_msg_type_number_t =
                      UInt32(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_LOAD_INFO_COUNT          : mach_msg_type_number_t =
                       UInt32(MemoryLayout<host_load_info_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_CPU_LOAD_INFO_COUNT      : mach_msg_type_number_t =
                   UInt32(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_VM_INFO64_COUNT          : mach_msg_type_number_t =
                      UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_SCHED_INFO_COUNT         : mach_msg_type_number_t =
                      UInt32(MemoryLayout<host_sched_info_data_t>.size / MemoryLayout<integer_t>.size)
private let PROCESSOR_SET_LOAD_INFO_COUNT : mach_msg_type_number_t =
              UInt32(MemoryLayout<processor_set_load_info_data_t>.size / MemoryLayout<natural_t>.size)


public struct System {
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC PROPERTIES
    //--------------------------------------------------------------------------
    
    
    /**
    System page size.
    
    - Can check this via pagesize shell command as well
    - C lib function getpagesize()
    - host_page_size()
    
    TODO: This should be static right?
    */
    public static let PAGE_SIZE = vm_kernel_page_size
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC ENUMS
    //--------------------------------------------------------------------------
    
    
    /**
    Unit options for method data returns.
    
    TODO: Pages?
    */
    public enum Unit : Double {
        // For going from byte to -
        case byte     = 1
        case kilobyte = 1024
        case megabyte = 1048576
        case gigabyte = 1073741824
    }
    
    
    /// Options for loadAverage()
    public enum LOAD_AVG {
        /// 5, 30, 60 second samples
        case short
        
        /// 1, 5, 15 minute samples
        case long
    }
    
    
    /// For thermalLevel()
    public enum ThermalLevel: String {
        // Comments via <IOKit/pwr_mgt/IOPM.h>

        /// Under normal operating conditions
        case Normal = "Normal"
        /// Thermal pressure may cause system slowdown
        case Danger = "Danger"
        /// Thermal conditions may cause imminent shutdown
        case Crisis = "Crisis"
        /// Thermal warning level has not been published
        case NotPublished = "Not Published"
        /// The platform may define additional thermal levels if necessary
        case Unknown = "Unknown"
    }


    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    

    fileprivate static let machHost = mach_host_self()
    fileprivate var loadPrevious = host_cpu_load_info()
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC INITIALIZERS
    //--------------------------------------------------------------------------
    
    
    public init() { }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    
    /**
    Get CPU usage (system, user, idle, nice). Determined by the delta between
    the current and last call. Thus, first call will always be inaccurate.
    */
    public mutating func usageCPU() -> (system : Double,
                                        user   : Double,
                                        idle   : Double,
                                        nice   : Double) {
        let load = System.hostCPULoadInfo()
        
        let userDiff = Double(load.cpu_ticks.0 - loadPrevious.cpu_ticks.0)
        let sysDiff  = Double(load.cpu_ticks.1 - loadPrevious.cpu_ticks.1)
        let idleDiff = Double(load.cpu_ticks.2 - loadPrevious.cpu_ticks.2)
        let niceDiff = Double(load.cpu_ticks.3 - loadPrevious.cpu_ticks.3)
        
        let totalTicks = sysDiff + userDiff + niceDiff + idleDiff
        
        let sys  = sysDiff  / totalTicks * 100.0
        let user = userDiff / totalTicks * 100.0
        let idle = idleDiff / totalTicks * 100.0
        let nice = niceDiff / totalTicks * 100.0
        
        loadPrevious = load
        
        // TODO: 2 decimal places
        // TODO: Check that total is 100%
        return (sys, user, idle, nice)
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC STATIC METHODS
    //--------------------------------------------------------------------------
    
    
    /// Get the model name of this machine. Same as "sysctl hw.model"
    public static func modelName() -> String {
        let name: String
        var mib  = [CTL_HW, HW_MODEL]

        // Max model name size not defined by sysctl. Instead we use io_name_t
        // via I/O Kit which can also get the model name
        var size = MemoryLayout<io_name_t>.size

        let ptr    = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1)
        let result = sysctl(&mib, u_int(mib.count), ptr, &size, nil, 0)


        if result == 0 { name = String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self)) }
        else           { name = String() }


        ptr.deallocate()

        #if DEBUG
            if result != 0 {
                print("ERROR - \(#file):\(#function) - errno = "
                        + "\(result)")
            }
        #endif

        return name
    }


    /**
    sysname       Name of the operating system implementation.
    nodename      Network name of this machine.
    release       Release level of the operating system.
    version       Version level of the operating system.
    machine       Machine hardware platform.

    Via uname(3) manual page.
    */
    // FIXME: Two compiler bugs here. One has a workaround, the other requires
    //        a C wrapper function. See issue #18
//    public static func uname() -> (sysname: String, nodename: String,
//                                                     release: String,
//                                                     version: String,
//                                                     machine: String) {
//        // Takes a generic pointer type because the type were dealing with
//        // (from the utsname struct) is a huge tuple of Int8s (once bridged to
//        // Swift), so it would be really messy to go that route (would have to
//        // type it all out explicitly)
//        func toString<T>(ptr: UnsafePointer<T>) -> String {
//            return String.fromCString(UnsafePointer<CChar>(ptr))!
//        }
//
//        let tuple: (String, String, String, String, String)
//        var names  = utsname()
//        let result = Foundation.uname(&names)
//
//        #if DEBUG
//            if result != 0 {
//                print("ERROR - \(__FILE__):\(__FUNCTION__) - errno = "
//                        + "\(result)")
//            }
//        #endif
//
//        if result == 0 {
//            let sysname  = withUnsafePointer(&names.sysname,  toString)
//            let nodename = withUnsafePointer(&names.nodename, toString)
//            let release  = withUnsafePointer(&names.release,  toString)
//            let version  = withUnsafePointer(&names.version,  toString)
//            let machine  = withUnsafePointer(&names.machine,  toString)
//
//            tuple = (sysname, nodename, release, version, machine)
//        }
//        else {
//            tuple = ("", "", "", "", "")
//        }
//
//        return tuple
//    }


    /// Number of physical cores on this machine.
    public static func physicalCores() -> Int {
        return Int(System.hostBasicInfo().physical_cpu)
    }
    
    
    /**
    Number of logical cores on this machine. Will be equal to physicalCores()
    unless it has hyper-threading, in which case it will be double.
    
    https://en.wikipedia.org/wiki/Hyper-threading
    */
    public static func logicalCores() -> Int {
        return Int(System.hostBasicInfo().logical_cpu)
    }
    
    
    /**
    System load average at 3 intervals.
    
    "Measures the average number of threads in the run queue."
    
    - via hostinfo manual page
    
    https://en.wikipedia.org/wiki/Load_(computing)
    */
    public static func loadAverage(_ type: LOAD_AVG = .long) -> [Double] {
        var avg = [Double](repeating: 0, count: 3)
        
        switch type {
            case .short:
                let result = System.hostLoadInfo().avenrun
                avg = [Double(result.0) / Double(LOAD_SCALE),
                       Double(result.1) / Double(LOAD_SCALE),
                       Double(result.2) / Double(LOAD_SCALE)]
            case .long:
                getloadavg(&avg, 3)
        }
        
        return avg
    }
    
    
    /**
    System mach factor at 3 intervals.
    
    "A variant of the load average which measures the processing resources
    available to a new thread. Mach factor is based on the number of CPUs
    divided by (1 + the number of runnablethreads) or the number of CPUs minus
    the number of runnable threads when the number of runnable threads is less
    than the number of CPUs. The closer the Mach factor value is to zero, the
    higher the load. On an idle system with a fixed number of active processors,
    the mach factor will be equal to the number of CPUs."
    
    - via hostinfo manual page
    */
    public static func machFactor() -> [Double] {
        let result = System.hostLoadInfo().mach_factor
        
        return [Double(result.0) / Double(LOAD_SCALE),
                Double(result.1) / Double(LOAD_SCALE),
                Double(result.2) / Double(LOAD_SCALE)]
    }
    

    /// Total number of processes & threads
    public static func processCounts() -> (processCount: Int, threadCount: Int) {
        let data = System.processorLoadInfo()
        return (Int(data.task_count), Int(data.thread_count))
    }
    
    
    /// Size of physical memory on this machine
    public static func physicalMemory(_ unit: Unit = .gigabyte) -> Double {
        return Double(System.hostBasicInfo().max_mem) / unit.rawValue
    }
    
    
    /**
    System memory usage (free, active, inactive, wired, compressed).
    */
    public static func memoryUsage() -> (free       : Double,
                                         active     : Double,
                                         inactive   : Double,
                                         wired      : Double,
                                         compressed : Double) {
        let stats = System.VMStatistics64()
        
        let free     = Double(stats.free_count) * Double(PAGE_SIZE)
                                                        / Unit.gigabyte.rawValue
        let active   = Double(stats.active_count) * Double(PAGE_SIZE)
                                                        / Unit.gigabyte.rawValue
        let inactive = Double(stats.inactive_count) * Double(PAGE_SIZE)
                                                        / Unit.gigabyte.rawValue
        let wired    = Double(stats.wire_count) * Double(PAGE_SIZE)
                                                        / Unit.gigabyte.rawValue
        
        // Result of the compression. This is what you see in Activity Monitor
        let compressed = Double(stats.compressor_page_count) * Double(PAGE_SIZE)
                                                        / Unit.gigabyte.rawValue
        
        return (free, active, inactive, wired, compressed)
    }
    

    /// How long has the system been up?
    public static func uptime() -> (days: Int, hrs: Int, mins: Int, secs: Int) {
        var currentTime = time_t()
        var bootTime    = timeval()
        var mib         = [CTL_KERN, KERN_BOOTTIME]

        // NOTE: Use strideof(), NOT sizeof() to account for data structure
        // alignment (padding)
        // http://stackoverflow.com/a/27640066
        // https://devforums.apple.com/message/1086617#1086617
        var size = MemoryLayout<timeval>.stride

        let result = sysctl(&mib, u_int(mib.count), &bootTime, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = "
                        + "\(result)")
            #endif

            return (0, 0, 0, 0)
        }


        // Since we don't need anything more than second level accuracy, we use
        // time() rather than say gettimeofday(), or something else. uptime
        // command does the same
        time(&currentTime)

        var uptime = currentTime - bootTime.tv_sec

        let days = uptime / 86400   // Number of seconds in a day
        uptime %= 86400

        let hrs = uptime / 3600     // Number of seconds in a hour
        uptime %= 3600

        let mins = uptime / 60
        let secs = uptime % 60

        return (days, hrs, mins, secs)
    }


    //--------------------------------------------------------------------------
    // MARK: POWER
    //--------------------------------------------------------------------------


    /**
    As seen via 'pmset -g therm' command.

    Via <IOKit/pwr_mgt/IOPMLib.h>:

        processorSpeed: Defines the speed & voltage limits placed on the CPU.
                        Represented as a percentage (0-100) of maximum CPU
                        speed.

        processorCount: Reflects how many, if any, CPUs have been taken offline.
                        Represented as an integer number of CPUs (0 - Max CPUs).

                        NOTE: This doesn't sound quite correct, as pmset treats
                              it as the number of CPUs available, NOT taken
                              offline. The return value suggests the same.

        schedulerTime:  Represents the percentage (0-100) of CPU time available.
                        100% at normal operation. The OS may limit this time for
                        a percentage less than 100%.
    */
    public static func CPUPowerLimit() -> (processorSpeed: Double,
                                           processorCount: Int,
                                           schedulerTime : Double) {
        var processorSpeed = -1.0
        var processorCount = -1
        var schedulerTime  = -1.0

        let status = UnsafeMutablePointer<Unmanaged<CFDictionary>?>.allocate(capacity: 1)

        let result = IOPMCopyCPUPowerStatus(status)

        #if DEBUG
            // TODO: kIOReturnNotFound case as seen in pmset
            if result != kIOReturnSuccess {
                print("ERROR - \(#file):\(#function) - kern_result_t = "
                        + "\(result)")
            }
        #endif


        if result == kIOReturnSuccess,
           let data = status.move()?.takeUnretainedValue() {
                let dataMap = data as NSDictionary

                // TODO: Force unwrapping here should be safe, as
                //       IOPMCopyCPUPowerStatus() defines the keys, but the
                //       the cast (from AnyObject) could be problematic
                processorSpeed = dataMap[kIOPMCPUPowerLimitProcessorSpeedKey]!
                                                                      as! Double
                processorCount = dataMap[kIOPMCPUPowerLimitProcessorCountKey]!
                                                                      as! Int
                schedulerTime  = dataMap[kIOPMCPUPowerLimitSchedulerTimeKey]!
                                                                      as! Double
        }

        status.deallocate()

        return (processorSpeed, processorCount, schedulerTime)
    }


    /// Get the thermal level of the system. As seen via 'pmset -g therm'
    public static func thermalLevel() -> System.ThermalLevel {
        var thermalLevel: UInt32 = 0

        let result = IOPMGetThermalWarningLevel(&thermalLevel)

        if result == kIOReturnNotFound {
            return System.ThermalLevel.NotPublished
        }


        #if DEBUG
            if result != kIOReturnSuccess {
                print("ERROR - \(#file):\(#function) - kern_result_t = "
                        + "\(result)")
            }
        #endif


        // TODO: Thermal warning level values no longer available through
        //       IOKit.pwr_mgt module as of Xcode 6.3 Beta 3. Not sure if thats
        //       intended behaviour or a bug, will investigate. For now
        //       hardcoding values, will move all power related calls to a
        //       separate struct.
        switch thermalLevel {
            case 0:
                // kIOPMThermalWarningLevelNormal
                return System.ThermalLevel.Normal
            case 5:
                // kIOPMThermalWarningLevelDanger
                return System.ThermalLevel.Danger
            case 10:
                // kIOPMThermalWarningLevelCrisis
                return System.ThermalLevel.Crisis
            default:
                return System.ThermalLevel.Unknown
        }
    }


    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS
    //--------------------------------------------------------------------------
    
    
    fileprivate static func hostBasicInfo() -> host_basic_info {
        // TODO: Why is host_basic_info.max_mem val different from sysctl?
        
        var size     = HOST_BASIC_INFO_COUNT
        let hostInfo = host_basic_info_t.allocate(capacity: 1)
        
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_info(machHost, HOST_BASIC_INFO, $0, &size)
        }
  
        let data = hostInfo.move()
        hostInfo.deallocate()
        
        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = "
                        + "\(result)")
            }
        #endif
        
        return data
    }

    
    fileprivate static func hostLoadInfo() -> host_load_info {
        var size     = HOST_LOAD_INFO_COUNT
        let hostInfo = host_load_info_t.allocate(capacity: 1)
        
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics(machHost, HOST_LOAD_INFO,
                                      $0,
                                      &size)
        }
        
        let data = hostInfo.move()
        hostInfo.deallocate()
        
        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = "
                        + "\(result)")
            }
        #endif
        
        return data
    }
    
    
    fileprivate static func hostCPULoadInfo() -> host_cpu_load_info {
        var size     = HOST_CPU_LOAD_INFO_COUNT
        let hostInfo = host_cpu_load_info_t.allocate(capacity: 1)
        
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics(machHost, HOST_CPU_LOAD_INFO,
                                      $0,
                                      &size)
        }
        
        let data = hostInfo.move()
        hostInfo.deallocate()
        
        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = "
                        + "\(result)")
            }
        #endif

        return data
    }
    
    
    fileprivate static func processorLoadInfo() -> processor_set_load_info {
        // NOTE: Duplicate load average and mach factor here
        
        var pset   = processor_set_name_t()
        var result = processor_set_default(machHost, &pset)
        
        if result != KERN_SUCCESS {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - kern_result_t = "
                        + "\(result)")
            #endif

            return processor_set_load_info()
        }

        
        var count    = PROCESSOR_SET_LOAD_INFO_COUNT
        let info_out = processor_set_load_info_t.allocate(capacity: 1)
        
        result = info_out.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            processor_set_statistics(pset,
                                     PROCESSOR_SET_LOAD_INFO,
                                     $0,
                                     &count)
        }

        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = "
                        + "\(result)")
            }
        #endif


        // This is isn't mandatory as I understand it, just helps keep the ref
        // count correct. This is because the port is to the default processor
        // set which should exist by default as long as the machine is running
        mach_port_deallocate(mach_task_self_, pset)

        let data = info_out.move()
        info_out.deallocate()
        
        return data
    }
    
    
    /**
    64-bit virtual memory statistics. This should apply to all Mac's that run
    10.9 and above. For iOS, iPhone 5S, iPad Air & iPad Mini 2 and on.
    
    Swift runs on 10.9 and above, and 10.9 is x86_64 only. On iOS though its 7
    and above, with both ARM & ARM64.
    */
    fileprivate static func VMStatistics64() -> vm_statistics64 {
        var size     = HOST_VM_INFO64_COUNT
        let hostInfo = vm_statistics64_t.allocate(capacity: 1)
        
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics64(machHost,
                              HOST_VM_INFO64,
                              $0,
                              &size)
        }

        let data = hostInfo.move()
        hostInfo.deallocate()
        
        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = "
                    + "\(result)")
            }
        #endif
        
        return data
    }
}
